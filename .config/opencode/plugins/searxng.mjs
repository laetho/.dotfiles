import { tool } from "@opencode-ai/plugin/tool";

const PRIVATE_IPV4_RANGES = [
  { start: "10.0.0.0", end: "10.255.255.255" },
  { start: "172.16.0.0", end: "172.31.255.255" },
  { start: "192.168.0.0", end: "192.255.255.255" },
  { start: "127.0.0.0", end: "127.255.255.255" },
  { start: "169.254.0.0", end: "169.255.255.255" },
  { start: "127.0.0.0", end: "127.255.255.255" },
  { start: "169.254.0.0", end: "169.254.255.255" },
];
const PRIVATE_IPV6_RANGES = [
  "fc00::/7",
  "::1/128",
];
const SEARCH_ENDPOINT = process.env.SEARXNG_ENDPOINT || "http://localhost:49217/search";

function isPrivateIP(ip) {
  const ipv4Regex = /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/;
  const match = ip.match(ipv4Regex);
  if (match) {
    const octets = match.slice(1, 5).map(Number);
    if (octets.some(o => o > 255)) return false;
    const [a, b, c, d] = octets;
    return (
      a === 10 ||
      (a === 172 && b >= 16 && b <= 31) ||
      (a === 192 && b === 168) ||
      a === 127 ||
      (a === 169 && b === 254)
    );
  }
  const ipv6Lower = ip.toLowerCase();
  const ipv6Regex = /^([0-9a-f]{0,4}:){2,7}[0-9a-f]{0,4}$/i;
  if (!ipv6Regex.test(ipv6Lower) && ipv6Lower !== "::" && ipv6Lower !== "::1") return false;
  return (
    ipv6Lower.startsWith("fc") ||
    ipv6Lower.startsWith("fd") ||
    ipv6Lower === "::1"
  );
}

async function isInternalIP(hostname) {
  if (hostname === "localhost" || hostname === "127.0.0.1" || hostname === "::1" || hostname === "0:0:0:0:0:0:0:1" || hostname === "0.0.0.0" || hostname === "::") {
    return true;
  }
  try {
    const { resolve4, resolve6 } = await import("dns");
    const addresses4 = await resolve4(hostname).catch(() => []);
    const addresses6 = await resolve6(hostname).catch(() => []);
    const allAddresses = [...addresses4, ...addresses6];
    for (const ip of allAddresses) {
      if (isPrivateIP(ip)) {
        return true;
      }
    }
  } catch {
    return false;
  }
  return false;
}

export default async function searxngPlugin(input) {
  return {
    tool: {
      searxng_web_search: tool({
        description: "Search the web using a local SearxNG instance",
        args: {
          query: tool.schema.string().describe("Search query"),
        },
        async execute(args, context) {
          if (!args.query || typeof args.query !== 'string' || args.query.length === 0 || args.query.length > 1000) {
            throw new Error("Invalid search query - must be between 1 and 1000 characters");
          }
          const sanitizedQuery = args.query.trim().replace(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/g, '');
          if (sanitizedQuery.length === 0) {
            throw new Error("Invalid search query - cannot be empty after sanitization");
          }
          let endpointUrl;
          try {
            endpointUrl = new URL(SEARCH_ENDPOINT);
          } catch {
            throw new Error("Invalid SearxNG endpoint configuration");
          }
          if (endpointUrl.protocol !== "https:" && endpointUrl.hostname !== "localhost" && endpointUrl.hostname !== "127.0.0.1" && endpointUrl.hostname !== "::1") {
            throw new Error("SearxNG endpoint must use HTTPS or be localhost");
          }
          const url = new URL(endpointUrl.href);
          url.searchParams.set("format", "json");
          url.searchParams.set("q", sanitizedQuery);
          const isPrivate = await isInternalIP(endpointUrl.hostname);
          if (!isPrivate) {
            throw new Error("SearxNG endpoint must be a local instance for security");
          }
          const abortController = new AbortController();
          const timeoutId = setTimeout(() => abortController.abort(), 30000);
          if (context?.abort?.aborted) {
            throw new Error("SearxNG request aborted by context");
          }
          const abortSignal = (context?.abort instanceof AbortSignal) ? context.abort : abortController.signal;
          let response;
          try {
            response = await fetch(url, { 
              signal: abortSignal,
              headers: { 'User-Agent': 'opencode-plugin/1.0' },
              redirect: "error"
            });
            clearTimeout(timeoutId);
          } catch (error) {
            clearTimeout(timeoutId);
            if (error.name === "AbortError") {
              throw new Error("SearxNG request timed out");
            }
            throw error;
          }
          if (!response.ok) {
            if (response.status >= 300 && response.status < 400) {
              throw new Error("SearxNG endpoint must not redirect - this could be a security issue");
            }
            throw new Error("SearxNG request failed: " + response.status + " " + response.statusText);
          }
          try {
            const data = await response.json();
            return JSON.stringify({
              status: 'success',
              timestamp: Date.now(),
              results: data.results?.length || 0,
            });
          } catch {
            return JSON.stringify({
              status: 'error',
              timestamp: Date.now(),
              message: 'Failed to parse search results - the SearxNG instance returned an unexpected response format.',
            });
          }
        },
      }),
    },
  };
}
