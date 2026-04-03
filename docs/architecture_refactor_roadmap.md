# Clippy Architecture Audit & Incremental Refactor Roadmap

## Scope and goals
- Project audited as-is, without redesigning from scratch.
- Existing GetX usage and working screens are preserved.
- Focus is on incremental changes toward a production-ready, offline-first architecture.

## Current architecture snapshot

### Folder structure
- `lib/core`: app shell concerns (`app_router`, theme).
- `lib/features/history`: currently contains **domain**, **data**, and **presentation** for clipboard history.
- `lib/features/favorites` and `lib/features/settings`: presentation-only screens.
- `lib/features/shared`: cross-feature items (`ClipboardController`, bindings, shared widgets).

### Navigation
- App uses `GetMaterialApp`, but top-level navigation is manually handled through a `StatefulWidget` + `IndexedStack` in `AppRouter`.
- Detail navigation is done with `Navigator.push` and `MaterialPageRoute`, not GetX named routes.

### State and dependency management
- Single global `ClipboardController` registered via `ClipboardBinding` and read with `Get.find` across screens.
- Binding registers service/repository/controller with `fenix: true` and static base URL default.
- UI reactivity uses `Obx`, but transient UI state still uses `setState` in pages.

### Data and service layers
- `ClipboardRepository` keeps in-memory lists and seeds data in constructor.
- `ClipboardService` makes network requests for analysis and returns a fallback sample response on non-2xx.
- No explicit local persistence abstraction yet (database/cache layer missing).

## Key inconsistencies and risks
1. **Feature boundaries are blurred**
   - Favorites and settings rely directly on a controller in `features/shared` while core domain/data live in `history`.
   - This creates coupling that will get harder to scale when adding modules.

2. **Mixed navigation paradigms**
   - GetX is used for DI/state, while routing is split between manual tab state and imperative `Navigator.push`.
   - Harder deep-linking, guards, and route-level bindings in the future.

3. **Repository is both mock store and domain access point**
   - In-memory seed logic is embedded in production repository path.
   - Hard to switch to database + sync without touching many call sites.

4. **Offline-first is not yet represented architecturally**
   - No local source of truth, no sync queue, no connectivity-aware orchestration.
   - Current fallback behavior is request-level only.

5. **Controller owns too many responsibilities**
   - Fetching, mutation, searching, favorites, settings (base URL), and analysis coordination are centralized.
   - Increases test surface and regression risk for unrelated changes.

6. **Error and loading states are coarse-grained**
   - One global loading flag for multiple operations.
   - No typed error model or operation-specific status tracking.

## Recommended phased refactor (minimal disruption)

### Phase 0 — Stabilize contracts (no UI breakage)
- Introduce interfaces:
  - `ClipboardRepositoryContract`
  - `ClipboardAnalysisServiceContract`
  - `ClipboardLocalStoreContract` (placeholder)
- Keep current classes but make controller depend on contracts.
- Add result wrapper (`AppResult<T>` or sealed state) for explicit success/failure.

### Phase 1 — Prepare module boundaries
- Create `features/clipboard` as canonical module for clipboard domain.
- Keep existing file paths temporarily with compatibility exports to avoid massive churn.
- Move `ClipboardController` from `features/shared` to module-scoped location (`clipboard/presentation/controllers`).
- Convert favorites/history to consume read-only view models exposed by controller methods.

### Phase 2 — Offline-first foundation
- Add local persistence implementation (e.g., Hive/Isar/SQLite) behind `ClipboardLocalStoreContract`.
- Repository becomes orchestrator:
  - local read/write as source of truth
  - remote sync optional/background
- Add `SyncStatus` fields in entities (pending, synced, failed) and basic retry queue.

### Phase 3 — Navigation and composition cleanup
- Incrementally introduce GetX route table (`getPages`) while preserving existing tabs.
- Replace direct `Navigator.push` calls with route names for detail pages.
- Move tab index state to a lightweight GetX navigation controller (optional but consistent).

### Phase 4 — Reliability and observability
- Add centralized logging and error mapping for service/repository layers.
- Add unit tests for repository orchestration and controller state transitions.
- Add golden/widget tests for core screens before major UI improvements.

## Suggested implementation order (first 2 sprints)
1. Contracts + dependency inversion (Phase 0).
2. Local store abstraction with in-memory adapter parity (Phase 0/2 bridge).
3. Repository orchestration with sync status fields (Phase 2).
4. Route unification for detail page only (small Phase 3 slice).

## Definition of done for this roadmap
- Existing history/favorites/settings screens still work.
- No destructive rewrites or broad file deletions.
- Architecture enables adding persistence and sync without reworking UI code.
