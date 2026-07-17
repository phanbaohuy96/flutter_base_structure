# data_source

Retrofit/Dio, Hive, and JSON data-layer plumbing shared across app flavors — API clients, storage models, and DI wiring (`data_source_micro.dart`).

Sits between `core` and `plugins` in the dependency chain: `apps/main -> core -> modules/data_source -> plugins`.

See [`AGENTS.md`](../../AGENTS.md) and [`.agents/skills/fl-data-layer/SKILL.md`](../../.agents/skills/fl-data-layer/SKILL.md) for conventions.
