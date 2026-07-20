# data_source

Retrofit/Dio and JSON data-layer plumbing shared across app flavors — API contracts, generated REST clients, DTOs/models, parsing, and DI wiring (`data_source_micro.dart`). Local persistence stays behind the storage seam in `core`.

Dependency path: `apps/main -> modules/data_source -> core -> plugins`; the app also depends directly on `core`.

See [`AGENTS.md`](../../AGENTS.md) and [`.agents/skills/fl-data-layer/SKILL.md`](../../.agents/skills/fl-data-layer/SKILL.md) for conventions.
