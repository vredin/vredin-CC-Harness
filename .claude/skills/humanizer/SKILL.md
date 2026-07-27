---
name: humanizer
description: Remove signs of AI-generated writing. Use as the final pass on human-facing reports to make text sound natural. Fixes sycophancy, promotional language, inflated significance, AI vocabulary, em-dash overuse, rule of three, hedging, filler.
---

# Humanizer — final pass on human-facing text

Applied once to final reports (/report, /docs sync, /self-audit, /gaps, /intent, /decompose). Prose only — keep facts, numbers, code, tables, quotes intact.

Remove: sycophantic openers and chatbot artifacts ("I hope this helps"); promotional language (seamlessly, cutting-edge, renowned, vibrant); inflated significance (testament, pivotal, underscores, "marks a shift"); AI vocabulary (delve, tapestry, landscape, foster, showcase); superficial "-ing" add-ons; rule-of-three padding; negative parallelisms ("not just X, but Y"); vague attributions ("experts argue"); em-dash and boldface overuse; title-case headings; emojis; filler and hedging ("in order to", "it is important to note", "could potentially possibly"); generic upbeat conclusions.

Do instead: simple copulas (is/are/has); varied sentence length; specific details over vague claims; sentence-case headings; straight quotes; opinions where a human would have one.

Credits: @blader — https://github.com/blader/humanizer (MIT), condensed from the Wikipedia "Signs of AI writing" guide.
