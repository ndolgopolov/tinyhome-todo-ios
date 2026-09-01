# TinyHome To-Do

A SwiftUI client for the TinyHome To-Do API. A Reminders-style task list with due dates, filtering, and sorting.

## Requirements

- Xcode 16 or newer
- An iOS 16.0+ simulator (or a device)

## Running

### Open and run

1. Open `TinyHomeTodo.xcodeproj`.
2. Select an iOS simulator.
3. Run (Cmd+R).

By default the app talks to the backend API at `http://localhost:8090`. If the backend is not running, the list shows a "Couldn't load your tasks" state with a Try Again button.

### Without a backend

To explore the UI with no backend running, open `TinyHomeTodo/App/TinyHomeTodoApp.swift` and change:

```swift
private let environment = AppEnvironment.live
```

to:

```swift
private let environment = AppEnvironment.preview
```

This uses an in-memory repository seeded with sample tasks. Add, edit, complete, and delete all work and persist for the session, then reset on relaunch.

### With backend

1. Start the API and confirm it listens on `http://localhost:8090` (see the backend project for how to run it).
2. The base URL lives in `AppEnvironment.live` (`TinyHomeTodo/App/AppEnvironment.swift`). Change it if your API runs elsewhere.

### Regenerating the project (optional)

The `.xcodeproj` is committed, so XcodeGen is not needed to build. If you edit `project.yml` or add files:

```
brew install xcodegen
xcodegen generate
```

## Features

- Task list with pull to refresh
- Add, edit, and delete tasks
- Mark complete or incomplete from the list or with a swipe
- Optional due date per task, with overdue highlighting
- Filter by completion state (All / Not Completed / Completed)
- Sort by due date or creation date, ascending or descending
- Filter and sort choices persist across launches
- Confirmation before deleting a task
- Custom empty and error states

## Architecture

SwiftUI with MVVM and async/await.

- `Model/` holds value types (`TodoTask`, `TaskQuery`).
- `Data/` holds the `TaskRepository` protocol and two implementations: `APITaskRepository` over `URLSession`, and `SampleTaskRepository`, an in-memory actor used for previews and offline runs.
- `UI/` holds the views and `TaskListViewModel`, an `@MainActor ObservableObject`.
- `App/` holds the entry point and `AppEnvironment`, a composition root that injects the chosen repository into the view.

Filtering and sorting run on the server through query parameters, so the order stays correct once the list grows past a single page. The view model serializes writes per task and coalesces rapid edits, such as fast completion toggles, and rolls back to a fresh fetch if a write fails.

The project builds in the Swift 6 language mode, so data-race safety is checked at compile time. Types that cross the actor boundary are `Sendable`.

## Design notes

- **iOS 16 floor.** iOS 16 introduces `NavigationStack`, which replaces `NavigationView` and its known retain and state problems, and provides native `swipeActions`, `refreshable`, `Menu`, and `toolbar` without availability checks. iOS 17-only APIs such as `@Observable` and `ContentUnavailableView` are avoided so the floor holds. The empty and error states are custom views.
- **Day-level due dates.** The editor picks a date with no time. The value is stored as the end of that day (23:59:59 local) and sent as a full datetime, so a time picker can be added later without a data change.
- **Server-side filter and sort.** Client-side sorting only orders the page already loaded, which breaks under pagination. Sorting on the server keeps one consistent order.

## API

The app targets the running backend, whose contract differs from the provided API specification in a few places:

| | Spec | Backend |
|---|---|---|
| Route | `/tasks` | `/api/tasks` |
| List response | wrapped | bare array |
| Sort parameter | `sort_by=+field` / `-field` | `sort_by=field` / `-field` |
| Delete response | 200 | 204 |

The client does not call `GET /tasks/{id}`. The list returns complete task objects, the editor edits a copy of the selected task, and create and update return the saved task, so no screen needs to re-fetch a single task by id. That endpoint would be the entry point for a future deep link or a standalone detail screen.

The date decoder accepts timestamps with zero to seven fractional-second digits, which is the range the backend emits.

## Tooling

- **XcodeGen** generates the project from `project.yml`, which is the source of truth for the target, build settings, and file layout. The generated `.xcodeproj` would normally be gitignored, but it is committed here only so the app can be opened and run without installing XcodeGen.
- **SwiftLint** runs as a pre-build step with a strict configuration. Install it with `brew install swiftlint`. Without it the build prints a warning and continues.

## Notes

- The API is the source of truth. The in-memory repository is for previews and offline exploration only and does not persist across launches.

## Next steps

- Unit tests. The repository protocol and composition-root injection make the view model, networking, and date decoding straightforward to cover. Tests are deferred for now.
- Relative due dates (Today, Tomorrow) in place of the abbreviated date.
- Local persistence (Core Data or SwiftData) behind the same repository, so the list survives launches without the API.
