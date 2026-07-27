# Service → Secret lookup table

> Used by `/orchestrate` STEP 0 credential-halt + `/decompose` T-000 §1 generation.
> Maps external service names (case-insensitive, Unicode-aware, with aliases) to canonical env var name + acquisition URL.

## Schema

Each entry MUST have:
- `service` — canonical lowercase name
- `aliases` — ≥2 alternative names users actually write (per S4 surgery)
- `env_var` — exact name used in `.env.example` (S4 consistency check enforces)
- `acquire_from` — URL where user obtains the value
- `consumed_by` — typical task types (helps user understand context)

## Drift prevention (S4 surgery)

CI check: every `env_var` value MUST exist as a key in project's `.env.example`. If not — `/orchestrate` halts with "service-secrets.md out of sync with .env.example. Add `<VAR>=` to .env.example or remove from this table."

## Lookup table

```yaml
services:

  - service: monobank
    aliases: [mono, monobank, моно, mono-acquiring, моноbank]
    env_var: MONOBANK_TOKEN
    acquire_from: https://api.monobank.ua/personal/auth
    consumed_by: [sync, webhook, balance-fetch]

  - service: openrouter
    aliases: [openrouter, open-router, or, llm-gateway]
    env_var: OPENROUTER_API_KEY
    acquire_from: https://openrouter.ai/keys
    consumed_by: [llm-categorization, llm-summarization, transcription]

  - service: anthropic
    aliases: [anthropic, claude, claude-api]
    env_var: ANTHROPIC_API_KEY
    acquire_from: https://console.anthropic.com/settings/keys
    consumed_by: [llm-direct, agent-sdk]

  - service: openai
    aliases: [openai, gpt, chatgpt, gpt-4]
    env_var: OPENAI_API_KEY
    acquire_from: https://platform.openai.com/api-keys
    consumed_by: [llm-direct, embeddings, whisper]

  - service: telegram-bot
    aliases: [telegram, bot, telegram-bot, tg-bot, aiogram]
    env_var: TELEGRAM_BOT_TOKEN
    acquire_from: https://t.me/BotFather (use /newbot)
    consumed_by: [bot-handlers, notifications, telegram-ux]

  - service: telegram-mtproto
    aliases: [mtproto, telethon, pyrogram, telegram-client, tg-client]
    env_var: TELEGRAM_API_ID,TELEGRAM_API_HASH,TELEGRAM_SESSION
    acquire_from: https://my.telegram.org/auth (API → app registration)
    consumed_by: [channel-scraping, mtproto-ingestion]

  - service: stripe
    aliases: [stripe, payments]
    env_var: STRIPE_SECRET_KEY
    acquire_from: https://dashboard.stripe.com/apikeys
    consumed_by: [billing, subscriptions, webhooks]

  - service: sendgrid
    aliases: [sendgrid, smtp, email]
    env_var: SENDGRID_API_KEY
    acquire_from: https://app.sendgrid.com/settings/api_keys
    consumed_by: [transactional-email, notifications]

  - service: brevo
    aliases: [brevo, sendinblue]
    env_var: BREVO_SMTP_USER,BREVO_SMTP_PASS
    acquire_from: https://app.brevo.com/settings/keys/smtp
    consumed_by: [transactional-email]

  - service: postgres
    aliases: [postgres, postgresql, pg, database]
    env_var: DATABASE_URL
    acquire_from: docker-compose POSTGRES_PASSWORD or VPS provisioning
    consumed_by: [all backend tasks]

  - service: redis
    aliases: [redis, cache, broker]
    env_var: REDIS_URL
    acquire_from: docker-compose default or hosted Redis URL
    consumed_by: [celery, fsm-state, rate-limiting]

  - service: minio
    aliases: [minio, s3, object-storage]
    env_var: MINIO_ACCESS_KEY,MINIO_SECRET_KEY
    acquire_from: MinIO console settings or AWS IAM
    consumed_by: [file-uploads, audit-worm]

  - service: outline
    aliases: [outline, kb, knowledge-base]
    env_var: OUTLINE_TOKEN
    acquire_from: https://your-outline.example.com/settings/api-keys
    consumed_by: [docs publish, /report, /docs sync]

  - service: tavily
    aliases: [tavily, web-search]
    env_var: TAVILY_API_KEY
    acquire_from: https://app.tavily.com/home
    consumed_by: [research, /general, /intent]

  - service: infisical
    aliases: [infisical, vault, secrets-manager]
    env_var: INFISICAL_TOKEN
    acquire_from: self-hosted Infisical settings → Service Tokens
    consumed_by: [runtime-secrets-fetch, totp-seeds, signing-keys]

  - service: monobank-public
    aliases: [monobank-public, mono-rates, currency-rates]
    env_var: NONE
    acquire_from: public API, no key needed
    consumed_by: [fx-rates]

# Extend per project. Unknown service in spec backlog → /orchestrate emits:
#   "WARN: spec T-NNN mentions <X> but not in service-secrets.md.
#    Verify .env.production has corresponding var. Extend lookup to enforce."
```

## Soft-warn fallback (no entry yet)

If `/orchestrate` STEP 0 scans `docs/specs/T-NNN-*.md` and finds a service-name mention NOT in this lookup → soft warn instead of hard halt:

```
WARN: T-013 mentions "Pipl" — no entry in service-secrets.md.
  Cannot infer canonical env var name.
  Add to docs/rules-references/service-secrets.md to enable enforcement.
  Proceeding (soft warn mode).
```

User can add the entry incrementally; first-time enforcement starts after entry exists.
