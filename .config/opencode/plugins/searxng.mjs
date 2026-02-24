import { tool } from "@opencode-ai/plugin";

// IPv4 private ranges for SSRF protection
const PRIVATE_IPV4_RANGES = [
  { start: "10.0.0.0", end: "10.255.255.255" },
  { start: "172.16.0.0", end: "172.31.255.255" },
  { start: "192.168.0.0", end: "192.168.255.255" },
  { start: "127.0.0.0", end: "127.255.255.255" },
  { start: "0.0.0.0", end: "0.255.255.255" },
  { start: "169.254.0.0", end: "169.254.255.255" },
];

// IPv6 private ranges for SSRF protection
const PRIVATE_IPV6_RANGES = [
  "fc00::/7",
  "fec0::/10",
  "fe80::/10",
  "::1/128",
  "::ffff:0:0/96",
];

// SearxNG endpoint - must be a local instance
const SEARCH_ENDPOINT = "http://localhost:49217/search";

/**
 * Checks if an IP address is private/internal
 */
function isPrivateIP(ip) {
  const ipv4Regex = /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/;
  const match = ip.match(ipv4Regex);
  if (match) {
    const octets = match.slice(1, 5).map(Number);
    if (octets.some(o => o > 255)) {
      return false;
    }
    const [a, b, c, d] = octets;
    return (
      a === 10 ||
      (a === 172 && b >= 16 && b <= 31) ||
      (a === 192 && b === 168) ||
      a === 127 ||
      (a === 0) ||
      (a === 169 && b === 254)
    );
  }

  const ipv6Lower = ip.toLowerCase();
  return (
    ipv6Lower.startsWith("fc") ||
    ipv6Lower.startsWith("fd") ||
    ipv6Lower.startsWith("fe80") ||
    ipv6Lower.startsWith("fec0") ||
    ipv6Lower === "::1" ||
    ipv6Lower === "::" ||
    ipv6Lower.startsWith("::ffff:")
  );
}

/**
 * Checks if a hostname resolves to a private/internal IP address
 */
async function isInternalIP(hostname) {
  // Allow localhost for SearxNG
  if (hostname === "localhost" || hostname === "127.0.0.1") {
    return true;
  }
  try {
    const { resolve4, resolve6 } = await import("dns");
    const addresses = await resolve4(hostname).catch(() => []);
    const addresses6 = await resolve6(hostname).catch(() => []);
    const allAddresses = [...addresses, ...addresses6];

    for (const ip of allAddresses) {
      if (isPrivateIP(ip)) {
        return true;
      }
    }
    return false;
  } catch {
    // Fail closed: if DNS resolution fails, assume it's not a safe internal IP
    return false;
  }
}

export default async function searxngPlugin() {
  return {
    tool: {
      searxng_web_search: tool({
        description: "Search the web using a local SearxNG instance",
        args: {
          query: tool.schema.string().describe("Search query"),
        },
        async execute(args, context) {
          // Validate search query length
          if (!args.query || typeof args.query !== 'string' || args.query.length === 0 || args.query.length > 1000) {
            throw new Error("Invalid search query - must be between 1 and 1000 characters");
          }

          // Parse and validate the endpoint URL
          let parsedUrl;
          try {
            parsedUrl = new URL(SEARCH_ENDPOINT);
          } catch {
            throw new Error("Invalid SearxNG endpoint configuration");
          }

          // SSRF protection: ensure endpoint is localhost
          const isPrivate = await isInternalIP(parsedUrl.hostname);
          if (!isPrivate) {
            throw new Error("SearxNG endpoint must be a local instance for security");
          }

          // Build search URL
          const url = new URL(SEARCH_ENDPOINT);
          url.searchParams.set("format", "json");
          url.searchParams.set("q", args.query);

          // Use AbortController for timeout (30 seconds, consistent with ytt plugin)
          const abortController = new AbortController();
          const timeoutId = setTimeout(() => abortController.abort(), 30000);

          const response = await fetch(url, { 
            signal: context.abort || abortController.signal,
            headers: { 'User-Agent': 'opencode-plugin/1.0' }
          }).finally(() => clearTimeout(timeoutId));
          if (!response.ok) {
            throw new Error(`SearxNG request failed: ${response.status} ${response.statusText}`);
          }

          // Parse JSON response for structured output
          try {
            const data = await response.json();
            // Return a safe, structured response
            return JSON.stringify({
              status: 'success',
              timestamp: Date.now(),
              results: data.results?.length || 0,
              query: data.q || args.query,
            });
          } catch {
            // Fallback to safe message if JSON parsing fails
            // Don't return raw response to avoid leaking internal error details
            return JSON.stringify({
              status: 'error',
              timestamp: Date.now(),
              message: 'Failed to parse search results - the SearxNG instance returned an unexpected response format',
            });
          }
        },
      }),
    },
  };
}
