import { tool } from "@opencode-ai/plugin";

const SEARCH_ENDPOINT = "http://localhost:49217/search";

export default async function searxngPlugin() {
  return {
    tool: {
      searxng_web_search: tool({
        description: "Search the web using a local SearxNG instance",
        args: {
          query: tool.schema.string().describe("Search query"),
        },
        async execute(args, context) {
          const url = new URL(SEARCH_ENDPOINT);
          url.searchParams.set("format", "json");
          url.searchParams.set("q", args.query);

          const response = await fetch(url, { signal: context.abort });
          if (!response.ok) {
            throw new Error(`SearxNG request failed: ${response.status} ${response.statusText}`);
          }

          return await response.text();
        },
      }),
    },
  };
}
