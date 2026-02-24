# YouTube Transcript Plugin (ytt)

A plugin for OpenCode that adds a tool to fetch YouTube video transcripts.

## Installation

The plugin is automatically loaded from `~/.config/opencode/plugins/ytt/` when OpenCode starts.

Dependencies are managed in `~/.config/opencode/plugins/ytt/package.json`.

### System Dependencies

This plugin requires `yt-dlp` to be installed on your system:

```bash
# Verify installation
yt-dlp --version

# Ubuntu/Debian
sudo apt install yt-dlp

# macOS with Homebrew
brew install yt-dlp

# Windows with Chocolatey
choco install yt-dlp

# Or download from https://github.com/yt-dlp/yt-dlp/releases
```

### Plugin Setup

1. Ensure you're in the plugin directory:
   ```bash
   cd ~/.config/opencode/plugins/ytt
   ```

2. Install Node.js dependencies:
   ```bash
   npm install
   ```

3. Build the plugin (if TypeScript source is present):
   ```bash
   npm run build
   ```

4. Restart OpenCode to load the plugin

## Security Considerations

The plugin implements multiple security measures to protect against common attacks:

- **Command Injection Prevention**: All arguments passed to yt-dlp are validated and sanitized. Language codes are checked against a whitelist of valid 2-letter codes.
- **SSRF Protection**: Hostnames are resolved and checked for private IP addresses. Internal network addresses are blocked.
- **Path Traversal Protection**: File paths are normalized and validated to ensure they remain within the temporary directory.
- **Symlink Attack Prevention**: Temporary directories use cryptographically random names to prevent attackers from pre-creating symlinks.
- **Input Validation**: All user inputs are validated for type, length, and format before processing.

## Usage

The plugin adds a `ytt` tool that can be called by the OpenCode agent with a YouTube URL or video ID.

### Triggering the Plugin

The ytt plugin is automatically loaded by OpenCode from `~/.config/opencode/plugins/ytt/`. When you ask a question that requires a YouTube transcript, the OpenCode agent will recognize this and use the `ytt` tool.

**How to use:**
- Simply ask for a YouTube transcript by providing a URL or video ID
- The agent will use `ytt(url="...")` automatically when appropriate
- Example prompts that trigger the plugin:
  - "Get the transcript for https://youtu.be/dQw4w9WgXcQ"
  - "What is in this video: https://www.youtube.com/watch?v=ABC123"
  - "Fetch the English transcript for video ID dQw4w9WgXcQ"

### Example calls (when the agent uses the tool):

```
ytt(url="https://youtu.be/dQw4w9WgXcQ")

ytt(url="dQw4w9WgXcQ")

# With language parameter
ytt(url="https://www.youtube.com/watch?v=dQw4w9WgXcQ", lang="es")
```

## Supported URL formats

- `https://www.youtube.com/watch?v=VIDEO_ID`
- `https://www.youtube.com/shorts/VIDEO_ID`
- `https://www.youtube.com/embed/VIDEO_ID`
- `https://youtu.be/VIDEO_ID`
- Video ID directly (11 character alphanumeric string)

**Note:** The plugin uses `yewtu.be` as a privacy-focused proxy internally when fetching transcripts.

## Language selection

Use the optional `lang` parameter to fetch transcripts in a specific language:

```
ytt(url="https://www.youtube.com/watch?v=VIDEO_ID", lang="es")
```

Common language codes: `en` (English), `es` (Spanish), `fr` (French), `de` (German), `ja` (Japanese), `zh` (Chinese)

Supported formats: Simple codes (e.g., `en`, `es`) or region variants (e.g., `pt-BR`, `zh-Hans`)

## Output format

Transcripts are returned as markdown code blocks:

```markdown
[transcript text here]
```

## Error handling

- **No transcript available**: Thrown when the video has no captions enabled
- **Invalid YouTube URL**: Thrown when the URL format is not recognized
- **Invalid video ID**: Thrown when the video ID format is incorrect

## API Reference

### Tool: `ytt`

**Arguments:**
- `url` (string, required): YouTube video URL or video ID
- `lang` (string, optional): Language code (e.g., 'en', 'es')

**Returns:**
- Markdown code block containing transcript text

**Errors:**
- `No transcript available for this video` - Video has no captions
- `Invalid YouTube URL` - URL format not recognized
- `Invalid YouTube video ID format` - ID not 11 characters
- `Invalid language code format` - Invalid language code
- `Failed to fetch transcript` - Network/server error
- `yt-dlp is not installed on the system` - yt-dlp binary not found
- `Failed to parse transcript data` - Unexpected format from yt-dlp
- `Transcript contains no text content` - Downloaded file was empty

### Example Response

````markdown
```markdown
Welcome to this tutorial on YouTube transcripts. In this video, we'll learn how to extract transcripts using various methods.
```
````

## Notes

- The plugin uses `yt-dlp` to fetch transcripts via auto-generated captions
- Videos without captions (manually added or auto-generated) will return an error
- **Rate limiting**: Limit requests to 1 per 5 seconds to avoid API throttling

## Limitations

- This plugin can only fetch transcripts for videos that have captions enabled
- Videos without captions will return: "No transcript available for this video - captions may be disabled"
- Some videos may have captions disabled by the creator, making transcripts unavailable
- **Important**: YouTube may block programmatic access to captions for some videos. If you receive a "No transcript available" error for a video you know has captions, it may be due to YouTube's anti-bot protections.

## Security Features

- **URL validation**: Only accepts HTTPS scheme and valid YouTube domains (`youtube.com`, `www.youtube.com`, `youtu.be`, `yewtu.be`, `www.yewtu.be`)
- **SSRF protection**: Hostnames are resolved and checked for private/internal IP addresses to prevent Server-Side Request Forgery attacks
- **Input length limits**: Maximum 2048 characters for URL, 50 for language code
- **Video ID validation**: Only allows 11-character alphanumeric IDs (YouTube video IDs contain only letters and numbers)
- **Language code whitelist**: Language codes are validated against a whitelist of valid codes to prevent command injection
- **Temporary directory security**: Uses `crypto.randomBytes(16)` for strongly random directory names with `fs.mkdtempSync` to prevent symlink attacks
- **Path traversal protection**: Downloaded files are validated to ensure they're within the expected temporary directory using `path.normalize()` and explicit prefix checking
- **No data storage**: Transcripts are fetched and returned transiently - nothing is stored
- **yt-dlp execution**: Uses `spawnSync` with pre-validated arguments passed as separate array elements for secure command execution
- **DNS resolution protection**: Hostnames are resolved via `dns.promises.resolve4/resolve6` to detect and block attempts to resolve to private IP ranges

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| "No transcript available" | Video has captions disabled or YouTube is blocking programmatic access | The video owner needs to enable captions. Check if the video has captions on YouTube first. |
| "Invalid YouTube URL" | URL format not recognized | Ensure URL contains valid youtube.com or youtu.be domain |
| "Invalid video ID format" | ID is not 11 alphanumeric characters | YouTube video IDs are exactly 11 alphanumeric characters (no hyphens or underscores) |
| "Invalid language code format" | Language code doesn't match RFC 5646 | Use 2-letter lowercase code (e.g., 'en', 'es') |
| "Failed to fetch transcript" | Network or server error | Try again later - rate limiting may apply. Limit requests to 1 per 5 seconds. |
| "yt-dlp is not installed" | yt-dlp not found on system | Install yt-dlp via your package manager (see Installation section). Verify with `yt-dlp --version`. |
| "Failed to parse transcript data" | Unexpected format from yt-dlp | Report this issue - the transcript format may have changed |
| "Transcript contains no text content" | Downloaded file was empty | Video may have been removed or captions disabled |

## Security Considerations

- Rate limiting: Avoid making too many requests in a short period. Limit requests to 1 per 5 seconds.
- Privacy: Transcripts contain public video content - no sensitive data is stored locally. Note that YouTube transcripts may contain personally identifiable information (PII) from the video content itself. Always review transcripts for PII before sharing or storing.
- yt-dlp: Uses system-installed yt-dlp for secure video processing

## Plugin Structure

```
ytt/
├── index.ts          # Plugin entry point (exports YoutubeTranscriptPlugin)
├── package.json      # Plugin dependencies
├── README.md         # This file
└── node_modules/     # Installed dependencies
```
