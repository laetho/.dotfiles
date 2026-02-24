import { tool } from "@opencode-ai/plugin/tool";

// IPv4 private ranges for SSRF protection
// Note: RFC1918 private ranges only - excludes 0.0.0.0/8 (reserved for "this network")
const PRIVATE_IPV4_RANGES = [
  { start: "10.0.0.0", end: "10.255.255.255" },
  { start: "172.16.0.0", end: "172.31.255.255" },
  { start: "192.168.0.0", end: "192.168.255.255" },
  { start: "127.0.0.0", end: "127.255.255.255" },
  { start: "169.254.0.0", end: "169.254.255.255" },
];

// IPv6 private ranges for SSRF protection
// Note: fec0::/10 (site-local) is deprecated per RFC4291 and fe80::/10 (link-local)
// can be used for local service discovery, so they are not currently enforced.
// Only ULA (fc00::/7) and loopback (::1) are checked.
const PRIVATE_IPV6_RANGES = [
  "fc00::/7",
  "::1/128",
];

// SearxNG endpoint - must be a local instance
// Can be overridden via environment variable SEARXNG_ENDPOINT
// Default uses HTTP for local development; production should use HTTPS
// Note: HTTP is allowed for localhost; production deployments should configure HTTPS
const SEARCH_ENDPOINT = process.env.SEARXNG_ENDPOINT || "http://localhost:49217/search";

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
      (a === 169 && b === 254)
    );
  }

  const ipv6Lower = ip.toLowerCase();
  
  // Validate IPv6 structure before checking prefixes
  const ipv6Regex = /^([0-9a-f]{0,4}:){2,7}[0-9a-f]{0,4}$/i;
  if (!ipv6Regex.test(ipv6Lower) && ipv6Lower !== "::" && ipv6Lower !== "::1") {
    return false;
  }
  
  return (
    ipv6Lower.startsWith("fc") ||
    ipv6Lower.startsWith("fd") ||
    ipv6Lower === "::1"
  );
}

/**
 * Checks if a hostname resolves to a private/internal IP address
 */
async function isInternalIP(hostname) {
  // Special handling for localhost - must actually resolve to loopback
  if (hostname === "localhost" || hostname === "127.0.0.1" || hostname === "::1" || hostname === "0:0:0:0:0:0:0:1") {
    try {
      const { resolve4, resolve6 } = await import("dns");
      const addresses4 = await resolve4(hostname).catch(() => []);
      const addresses6 = await resolve6(hostname).catch(() => []);
      const allAddresses = [...addresses4, ...addresses6];
      
      // Verify that localhost resolves to loopback addresses only
      for (const ip of allAddresses) {
        if (!isPrivateIP(ip)) {
          return false;
        }
      }
      // Must have resolved to at least one IP
      return allAddresses.length > 0;
    } catch {
      // If DNS resolution fails for localhost, be conservative
      return false;
    }
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

export default async function searxngPlugin(input) {
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
          
          // Sanitize search query - remove control characters and invalid UTF-8
          const sanitizedQuery = args.query.trim().replace(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/g, '');
           if (sanitizedQuery.length === 0) {
             throw new Error("Invalid search query - cannot be empty after sanitization");
           }
           
           // Parse and validate the endpoint URL once for canonicalization
           let endpointUrl;
           try {
             endpointUrl = new URL(SEARCH_ENDPOINT);
           } catch {
             throw new Error("Invalid SearxNG endpoint configuration");
           }

           // Enforce https for production-like setups; http only for localhost
           if (endpointUrl.protocol !== "https:" && endpointUrl.hostname !== "localhost" && endpointUrl.hostname !== "127.0.0.1" && endpointUrl.hostname !== "::1") {
             throw new Error("SearxNG endpoint must use HTTPS or be localhost");
           }
           
            // Build search URL using the validated endpoint URL
            const url = new URL(endpointUrl.href);
            url.searchParams.set("format", "json");
            url.searchParams.set("q", sanitizedQuery);

           // SSRF protection: ensure endpoint is localhost
           const isPrivate = await isInternalIP(endpointUrl.hostname);
           if (!isPrivate) {
             throw new Error("SearxNG endpoint must be a local instance for security");
           }

           // Use AbortController for timeout (30 seconds, consistent with ytt plugin)
          const abortController = new AbortController();
          const timeoutId = setTimeout(() => abortController.abort(), 30000);

           // Check if context.abort is already aborted before starting
           if (context?.abort?.aborted) {
             throw new Error("SearxNG request aborted by context");
           }

           // Validate abort signal type before using it
           const abortSignal = (context?.abort instanceof AbortSignal) ? context.abort : abortController.signal;

           let response;
           try {
             response = await fetch(url, { 
               signal: abortSignal,
              headers: { 'User-Agent': 'opencode-plugin/1.0' },
              // Disable automatic redirect following to prevent SSRF via redirects
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
            // Check if it's a redirect error (which we prevent)
            if (response.status >= 300 && response.status < 400) {
              throw new Error("SearxNG endpoint must not redirect - this could be a security issue");
            }
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
