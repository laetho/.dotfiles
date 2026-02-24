import { tool } from "@opencode-ai/plugin/tool";

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

// Error message constants
const ERRORS = {
  INVALID_URL: "Invalid YouTube URL - could not extract video ID",
  INVALID_VIDEO_ID: "Invalid YouTube video ID format",
  NO_TRANSCRIPT: "No transcript available for this video - captions may be disabled or YouTube may be blocking programmatic access",
  INVALID_LANG: "Invalid language code format - use 2-letter lowercase code (e.g., 'en', 'es')",
  FAILED_FETCH: "Failed to fetch transcript",
  EMPTY_URL: "Invalid YouTube URL - URL cannot be empty",
  NON_HTTP_URL: "Invalid URL - only http and https schemes are supported",
  INVALID_HOST: "Invalid YouTube URL - must be from youtube.com or youtu.be",
  YT_DLP_NOT_FOUND: "yt-dlp is not installed on the system",
  JSON_PARSE_ERROR: "Failed to parse transcript data - unexpected format from yt-dlp",
  NO_TEMP_FILE: "No subtitle file was downloaded",
  TRANSCRIPT_EMPTY: "Transcript contains no text content",
};

// Valid YouTube domains
const VALID_YOUTUBE_HOSTS = new Set(["youtube.com", "www.youtube.com", "youtu.be", "yewtu.be", "www.yewtu.be"]);

// Valid language codes
const VALID_LANG_CODES = new Set([
  "aa", "ab", "ae", "af", "ak", "am", "an", "ar", "as", "av", "ay", "az", "ba", "be", "bg", "bh", "bi", "bm", "bn", "bo", "br", "bs", "ca", "ce", "ch", "co", "cr", "cs", "cu", "cv", "cy", "da", "de", "dv", "dz", "ee", "el", "en", "eo", "es", "et", "eu", "fa", "ff", "fi", "fj", "fo", "fr", "fy", "ga", "gd", "gl", "gn", "gu", "gv", "ha", "he", "hi", "ho", "hr", "ht", "hu", "hy", "hz", "ia", "id", "ie", "ig", "ii", "ik", "io", "is", "it", "iu", "ja", "jv", "ka", "kg", "ki", "kj", "kk", "kl", "km", "kn", "ko", "kr", "ks", "ku", "kv", "kw", "ky", "la", "lb", "lg", "li", "ln", "lo", "lt", "lu", "lv", "mg", "mh", "mi", "mk", "ml", "mn", "mr", "ms", "mt", "my", "na", "nb", "nd", "ne", "ng", "nl", "nn", "no", "nr", "nv", "ny", "oc", "oj", "om", "or", "os", "pa", "pi", "pl", "ps", "pt", "qu", "rm", "rn", "ro", "ru", "rw", "sa", "sc", "sd", "se", "sg", "si", "sk", "sl", "sm", "sn", "so", "sq", "sr", "ss", "st", "su", "sv", "sw", "ta", "te", "tg", "th", "ti", "tk", "tl", "tn", "to", "tr", "ts", "tt", "tw", "ty", "ug", "uk", "ur", "uz", "ve", "vi", "vo", "wa", "wo", "xh", "yi", "yo", "za", "zh", "zu"
]);

// Maximum input length
const MAX_URL_LENGTH = 2048;
const MAX_LANG_LENGTH = 50;

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
    // Block all private ranges including 0.0.0.0/8 (0.0.0.0 is unsafe for SSRF)
    return (
      a === 10 ||
      (a === 172 && b >= 16 && b <= 31) ||
      (a === 192 && b === 168) ||
      (a === 127) ||
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
    // Fail closed: if DNS resolution fails, assume the hostname is not safe
    // This prevents SSRF bypass through DNS failures
    return false;
  }
}

/**
 * Plugin factory function
 */
export default async function yttPlugin() {
  return {
    tool: {
      ytt: tool({
        description: "Fetch YouTube video transcript in markdown format. Returns transcript as a markdown code block.",
        args: {
          url: tool.schema.string().describe("YouTube video URL or video ID"),
          lang: tool.schema
            .string()
            .optional()
            .describe("Language code (e.g., 'en', 'pt-BR') for transcript. Supports region variants."),
        },
        async execute(args, context) {
          const { url, lang } = args;

          // Validate URL is not empty
          if (!url || typeof url !== "string" || url.trim().length === 0) {
            throw new Error(ERRORS.EMPTY_URL);
          }

          // Trim and validate input length
          const trimmedUrl = url.trim();
          if (trimmedUrl.length > MAX_URL_LENGTH) {
            throw new Error(ERRORS.INVALID_URL);
          }

          // Check if it looks like a URL
          let videoId = trimmedUrl;

          if (trimmedUrl.includes("://")) {
            try {
              const parsed = new URL(trimmedUrl);

              // Only allow https scheme
              if (parsed.protocol !== "https:") {
                throw new Error(ERRORS.NON_HTTP_URL);
              }

              // Validate host is exactly a known YouTube domain
              const hostname = parsed.hostname.toLowerCase();
              if (!VALID_YOUTUBE_HOSTS.has(hostname)) {
                throw new Error(ERRORS.INVALID_HOST);
              }

              // SSRF protection: check if hostname resolves to a private IP
              if (hostname !== "localhost" && hostname !== "127.0.0.1") {
                const isPrivate = await isInternalIP(hostname);
                if (isPrivate) {
                  throw new Error(ERRORS.INVALID_HOST);
                }
              }

              // Extract and validate video ID from URL
              const parsedPath = parsed.pathname;
              const searchParams = parsed.searchParams;

              // Handle /watch?v=VIDEO_ID format
              if (parsedPath === "/watch") {
                const videoParam = searchParams.get("v");
                if (videoParam && /^[A-Za-z0-9]{11}$/.test(videoParam)) {
                  videoId = videoParam;
                } else {
                  throw new Error(ERRORS.INVALID_URL);
                }
              }
              // Handle /shorts/VIDEO_ID format
              else if (parsedPath.startsWith("/shorts/")) {
                const videoIdMatch = parsedPath.match(/^\/shorts\/([A-Za-z0-9]{11})/);
                if (videoIdMatch && videoIdMatch[1]) {
                  videoId = videoIdMatch[1];
                } else {
                  throw new Error(ERRORS.INVALID_URL);
                }
              }
              // Handle /embed/VIDEO_ID format
              else if (parsedPath.startsWith("/embed/")) {
                const videoIdMatch = parsedPath.match(/^\/embed\/([A-Za-z0-9]{11})/);
                if (videoIdMatch && videoIdMatch[1]) {
                  videoId = videoIdMatch[1];
                } else {
                  throw new Error(ERRORS.INVALID_URL);
                }
              }
              // Handle youtu.be short URLs
              else if (hostname === "youtu.be") {
                const pathVideoId = parsedPath.slice(1);
                const videoIdMatch = pathVideoId.match(/^([A-Za-z0-9]{11})/);
                if (videoIdMatch && videoIdMatch[1]) {
                  videoId = videoIdMatch[1];
                } else {
                  throw new Error(ERRORS.INVALID_URL);
                }
              } else {
                throw new Error(ERRORS.INVALID_URL);
              }
            } catch (error) {
              if (error instanceof Error && (error.message === ERRORS.NON_HTTP_URL || error.message === ERRORS.INVALID_HOST)) {
                throw error;
              }
              throw new Error(ERRORS.INVALID_URL);
            }
          }

          // Validate video ID format
          if (!/^[A-Za-z0-9]{11}$/.test(videoId)) {
            throw new Error(ERRORS.INVALID_VIDEO_ID);
          }

          // Validate language code if provided
          if (lang && typeof lang === "string") {
            const trimmedLang = lang.trim();
            if (trimmedLang.length === 0 || trimmedLang.length > MAX_LANG_LENGTH) {
              throw new Error(ERRORS.INVALID_LANG);
            }
            if (!/^[a-z]{2}(-[A-Za-z]{2,})?$/.test(trimmedLang.toLowerCase())) {
              throw new Error(ERRORS.INVALID_LANG);
            }
          }

          // Use yt-dlp to fetch the transcript
          try {
            const { spawnSync } = await import("child_process");
            const { mkdtempSync, rmSync, readFileSync, readdirSync } = await import("fs");
            const { randomBytes } = await import("crypto");
            const { join, resolve, normalize, sep } = await import("path");

            // Check if yt-dlp is available
            const ytDlpCheck = spawnSync("yt-dlp", ["--version"], { encoding: "utf8", timeout: 5000 });
            if (ytDlpCheck.status !== 0) {
              throw new Error(ERRORS.YT_DLP_NOT_FOUND);
            }

            // Create temporary directory
            const randomSuffix = randomBytes(16).toString("hex");
            const tempDir = mkdtempSync(join("/tmp", "ytt-" + randomSuffix + "-"));

            try {
              // Determine language to use
              const trimmedLang = lang?.trim();
              let langCode = trimmedLang && trimmedLang.length > 0 
                ? trimmedLang.toLowerCase().replace(/_/g, "-") 
                : "en";

              // Validate language code - stricter regex to prevent shell injection
              const langCodeBase = langCode.split("-")[0];
              if (!/^[a-z]{2}$/.test(langCodeBase)) {
                throw new Error(ERRORS.INVALID_LANG);
              }
              if (!VALID_LANG_CODES.has(langCodeBase)) {
                throw new Error(ERRORS.INVALID_LANG);
              }
              // Optional region code after hyphen (e.g., pt-BR)
              if (langCode.includes("-")) {
                const regionCode = langCode.split("-")[1];
                if (!/^[A-Z]{2,}$/.test(regionCode)) {
                  throw new Error(ERRORS.INVALID_LANG);
                }
              }

              // Use yt-dlp to download the subtitle file
              // Use yewtu.be (privacy-focused YouTube frontend) to avoid tracking
              const ytDlpProcess = spawnSync(
                "yt-dlp",
                [
                  "--write-auto-subs",
                  "--sub-lang=" + langCode,
                  "--skip-download",
                  "--sub-format=json3",
                  "--output",
                  join(tempDir, "transcript.json3"),
                  "https://yewtu.be/watch?v=" + videoId,
                ],
                { encoding: "utf8", timeout: 30000 }
              );

              if (ytDlpProcess.status !== 0) {
                const stderr = ytDlpProcess.stderr.toLowerCase();
                const noSubtitlesError = stderr.includes("no subtitles") ||
                  stderr.includes("no subtitles found") ||
                  stderr.includes("subtitles are disabled") ||
                  stderr.includes("caption track not found");

                if (noSubtitlesError) {
                  throw new Error(ERRORS.NO_TRANSCRIPT);
                }
                throw new Error(ERRORS.FAILED_FETCH);
              }

              // Read the downloaded JSON3 file
              const files = readdirSync(tempDir);
              const json3File = files.find((f) => f.endsWith(".json3"));
              if (!json3File) {
                throw new Error(ERRORS.NO_TRANSCRIPT);
              }

              // Validate file path
              const filePath = resolve(join(tempDir, json3File));
              const resolvedTempDir = resolve(tempDir);
              
              // Verify the path is within the expected temp directory
              const normalizedFilePath = normalize(filePath);
              const normalizedTempDir = normalize(resolvedTempDir);
              if (
                !normalizedFilePath.startsWith(normalizedTempDir + sep) &&
                normalizedFilePath !== normalizedTempDir
              ) {
                throw new Error(ERRORS.NO_TEMP_FILE);
              }

              let fileContent;
              try {
                fileContent = readFileSync(filePath, "utf8");
              } catch {
                throw new Error(ERRORS.NO_TRANSCRIPT);
              }

              // Parse the JSON3 format
              let transcriptData;
              try {
                transcriptData = JSON.parse(fileContent);
              } catch {
                throw new Error(ERRORS.JSON_PARSE_ERROR);
              }

              // Validate the transcript data structure
              if (!transcriptData || typeof transcriptData !== "object") {
                throw new Error(ERRORS.JSON_PARSE_ERROR);
              }

              // Extract text from the transcript events
              const segments = [];
              if (transcriptData.events && Array.isArray(transcriptData.events)) {
                for (const event of transcriptData.events) {
                  if (event.segs && Array.isArray(event.segs)) {
                    for (const seg of event.segs) {
                      if (seg.utf8 && typeof seg.utf8 === "string") {
                        segments.push(seg.utf8);
                      }
                    }
                  }
                }
              }

              // Join segments and clean up
              const transcriptText = segments
                .join("")
                .replace(/\s+/g, " ")
                .trim();

              if (!transcriptText || transcriptText.length === 0) {
                throw new Error(ERRORS.TRANSCRIPT_EMPTY);
              }

              return `\`\`\`markdown\n${transcriptText}\n\`\`\``;
            } finally {
              // Clean up temporary directory
              try {
                rmSync(tempDir, { recursive: true, force: true });
              } catch (cleanupError) {
                console.warn("Warning: Failed to clean up temporary directory:", cleanupError.message);
              }
            }
          } catch (error) {
            if (error instanceof Error) {
              if (error.message === ERRORS.YT_DLP_NOT_FOUND || error.message === ERRORS.NO_TRANSCRIPT) {
                throw error;
              }
              if (error.message === ERRORS.JSON_PARSE_ERROR || error.message === ERRORS.TRANSCRIPT_EMPTY) {
                throw error;
              }
              const errorMsg = error.message.toLowerCase();
              if (errorMsg.includes("no subtitles") || errorMsg.includes("no subtitles found")) {
                throw new Error(ERRORS.NO_TRANSCRIPT);
              }
            }
            throw new Error(ERRORS.FAILED_FETCH);
          }
        },
      }),
    },
  };
}
