# opencode agent configuration

This repository contains opencode agent definitions and configuration for sampling behavior.

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
