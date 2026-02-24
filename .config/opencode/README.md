# opencode agent configuration

This repository contains opencode agent definitions and configuration for sampling behavior.

## Agent Workflow

The agents work together in a coordinated workflow:

1. **plan** - Creates a detailed execution plan with specific tasks and objectives
2. **build** - Executes the approved plan with full tool access
3. **rigormortis** - Performs comprehensive security, correctness, and test coverage reviews

Each agent has specific roles:
- **plan**: Highly deterministic, focused on creating accurate execution strategies
- **build**: Balanced execution with precise implementation
- **rigormortis**: Conservative security review with comprehensive analysis

### Agent Triggering

- **plan**: Automatically invoked when a user submits a request requiring planning
- **build**: Invoked after plan approval to execute the plan
- **rigormortis**: Run manually or after build to review changes

### Error Recovery

If rigormortis finds issues:
1. Review the findings in the output
2. Modify the code as needed based on the recommendations
3. Run rigormortis again to verify fixes

## Plugins

Custom plugins extend OpenCode's functionality by adding tools, hooks, and event handlers.

### Available Plugins

- **ytt** - Fetch YouTube video transcripts in markdown format
  - Location: `plugins/ytt.mjs`
  - Entry point: `plugins/index.mjs`
  - Tool name: `ytt`
  - Usage: Provide a YouTube URL or video ID to get the transcript
  - How it works: The plugin adds a `ytt` tool that is automatically available to all agents. When you ask for a YouTube transcript, the agent will use the `ytt(url="...")` tool.
  - Configuration: Add `"plugin": ["./plugins/index.mjs"]` to `opencode.json`
  - Dependencies: Requires `yt-dlp` installed (`pip install yt-dlp`)
  - Examples:
    - `ytt(url="https://youtu.be/dQw4w9WgXcQ")`
    - `ytt(url="dQw4w9WgXcQ")`
    - `ytt(url="https://www.youtube.com/watch?v=dQw4w9WgXcQ", lang="es")`
  - Troubleshooting:
    - "No subtitles found" - Video may not have captions available
    - "yt-dlp not installed" - Install via `pip install yt-dlp`

- **searxng** - Search the web using a local SearxNG instance
  - Location: `plugins/searxng.mjs`
  - Entry point: `plugins/index.mjs`
  - Tool name: `searxng_web_search`
  - Usage: Search the web using a local SearxNG instance for privacy-focused results
  - Configuration: Ensure a local SearxNG instance is running at `http://localhost:49217`
  - Dependencies: Requires local SearxNG instance (https://github.com/searxng/searxng)
  - Examples:
    - `searxng_web_search(query="search query here")`
  - Troubleshooting:
    - "SearxNG request failed" - Verify SearxNG is running at the configured endpoint
    - "SearxNG endpoint must be a local instance" - Ensure the endpoint is localhost

### Plugin Structure

Plugins are `.mjs` files in the `plugins/` directory. Each plugin exports a default async function that returns a `Hooks` object with tools:

```javascript
import { tool } from "@opencode-ai/plugin/tool";

export default async function myPlugin() {
  return {
    tool: {
      mytool: tool({
        description: "Description of my tool",
        args: {
          arg1: tool.schema.string().describe("Description of arg1"),
        },
        async execute(args) {
          return "Result";
        },
      }),
    },
  };
}
```

## Sampling parameters

The following sampling parameters control how deterministic or exploratory each agent behaves:

- **temperature** (typical range: `0.0–1.0`): Controls randomness. Lower values are more deterministic; higher values are more creative.
- **top_p** (typical range: `0.7–1.0`): Nucleus sampling. The model considers the smallest set of tokens whose cumulative probability is at least `top_p`.
- **top_k** (typical range: `10–100`): Limits sampling to the top `k` tokens by probability. Lower values tighten outputs; higher values increase diversity.

> Note: These ranges are general guidelines. Actual behavior and defaults may vary by provider or model, especially if a parameter is omitted.

## Agent settings and implications

| Agent | temperature | top_p | top_k | Implications |
| --- | --- | --- | --- | --- |
| **plan** | 0.1 | 0.9 | 20 | Highly deterministic planning with limited variance. |
| **build** | 0.3 | 0.9 | 20 | Balanced execution: precise with moderate flexibility. |
| **rigormortis** | 0.1 | 0.9 | 20 | Conservative review behavior for rigor and safety. |
| **researcher** | 0.3 | 0.9 | 40 | More breadth in exploration while staying controlled. |

## Tuning guidance

- **Increase determinism**: lower `temperature` and/or reduce `top_k` (and optionally lower `top_p`).
- **Increase exploration**: raise `temperature` and/or increase `top_k` (and optionally raise `top_p`).
- Keep `plan` and `rigormortis` conservative to reduce variability in critical reasoning steps.
- Use higher `top_k` for `researcher` when you want broader source discovery and idea generation.

## Where to change values

Agent sampling parameters are defined in `agents/*.md` under the `config` section.

## Troubleshooting

### Plugin System Issues

| Error | Cause | Solution |
|-------|-------|----------|
| `yt-dlp not installed on the system` | Missing yt-dlp dependency | Install with `pip install yt-dlp` |
| `No subtitles found` | Video has no captions | Check video has captions enabled on YouTube |
| `SearxNG request failed` | SearxNG endpoint unavailable | Verify SearxNG is running at `http://localhost:49217` |
| `SearxNG endpoint must be a local instance` | Endpoint not localhost | Ensure SearxNG is configured for localhost only |
| `DNS resolution failure` | Network/DNS issues | Verify network connectivity and DNS configuration |

### Security Notes

- Both plugins include SSRF protection to block requests to internal IP ranges
- The `ytt` plugin uses `yewtu.be` (privacy-focused YouTube frontend) to avoid tracking
- The `searxng` plugin only allows localhost connections for security
