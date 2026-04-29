# Claude Instructions

Shared coding-agent guidance lives in [AGENTS.md](AGENTS.md). Follow it for architecture, implementation patterns, spec-driven development, code generation, localization, testing, and repository-specific conventions.

## Claude Code rules

- Do not edit the template project unless the user explicitly asks.
- Do not commit changes unless the user explicitly asks for a commit.
- Never commit `.env`, credentials, tokens, keystores, or generated secrets.
- Keep `.env.example` files safe and non-secret.
- Prefer the project-standard commands listed in `AGENTS.md` for setup, generation, localization, formatting, and tests.
