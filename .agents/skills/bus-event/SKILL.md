---
name: bus-event
description: Handles cross-feature BusEvent communication with EventBusManager in the Flutter base template
license: MIT
compatibility: all
metadata:
  audience: flutter-developers
  framework: flutter
  pattern: event-bus
---

# Bus Event Skill

## When to use

- A domain action must notify another BLoC, screen, or feature without direct coupling.
- A use case creates, updates, deletes, reports, follows, shares, or syncs data that may already be shown elsewhere.
- A BLoC needs to stay in sync with background work or actions from another module.
- Adding, publishing, subscribing to, or reviewing `BusEvent` classes.

Do not use bus events for normal parent-child widget callbacks, local UI-only state, route results, or logic that belongs inside one BLoC event/state flow.

## What bus events are for

`BusEvent` is the app-wide notification mechanism for cross-module synchronization. `EventBusManager` wraps the `event_bus` package in `core/lib/common/components/event_bus/event_bus.dart` and exposes:

```dart
Stream<T> on<T extends BusEvent>();
void fire(BusEvent event);
```

`EventBusManager` is registered as a singleton through injectable, so publishers and subscribers receive the same stream instance. Import `package:core/core.dart` to access `BusEvent` and `EventBusManager`.

Representative uses:

- Refresh a list when another feature changed data but the event cannot carry the updated item.
- Remove or replace a list item after an edit/delete operation in another feature.
- Track background task completion, failure, and progress.
- Reload profile-dependent data after profile edits or account switching.

## Principles

1. Events are domain notifications, not commands — name events after what already happened.
2. Publish after successful state changes — fire only after the repository/API/local operation succeeds or the local task state is updated.
3. Keep payloads minimal but sufficient — IDs for removals, full models for in-place replacement, and a change-type enum when one event covers several outcomes.
4. Group related events under an abstract base when listeners often handle the group.
5. Bridge bus events into BLoC events — listener callbacks call `add(...)`; mutate state only inside registered BLoC handlers.
6. Always cancel subscriptions — store every `StreamSubscription`, call `cancel()` in `close()`, and await the returned `Future` when `close()` is async.
7. Avoid broad `on<BusEvent>()` listeners — subscribe to the narrowest event type possible.

## Event location

Put general domain event files under:

```text
apps/main/lib/domain/bus_event/
```

For feature/use-case scoped events, place the file near the owning domain use case and keep the location consistent within that feature:

```text
apps/main/lib/domain/usecases/<feature>/<feature>_bus_event.dart
```

## Event definition patterns

### Single event with change-type enum

Use this when the payload shape is the same and listeners branch by the completed change type.

```dart
import 'package:core/core.dart';

import '../../entities/record/record_history_log.dart';

enum RecordActivityChangeType { created, updated }

class RecordActivityChangedBusEvent extends BusEvent {
  final RecordHistoryLog log;
  final RecordActivityChangeType type;

  RecordActivityChangedBusEvent({
    required this.log,
    required this.type,
  });
}
```

### Abstract base with typed events

Use this when related events have different payloads but subscribers often handle the group.

```dart
import 'package:core/core.dart';

import '../../entities/post/post_model.dart';

abstract class PostBusEvent extends BusEvent {}

abstract class PostUpdatedBusEvent extends PostBusEvent {
  PostModel get post;
}

class PostEditedBusEvent extends PostUpdatedBusEvent {
  @override
  final PostModel post;

  PostEditedBusEvent({required this.post});
}

class PostInteractionUpdatedBusEvent extends PostUpdatedBusEvent {
  @override
  final PostModel post;

  PostInteractionUpdatedBusEvent({required this.post});
}

class PostDeletedBusEvent extends PostBusEvent {
  final String postId;

  PostDeletedBusEvent({required this.postId});
}
```

## Publishing pattern

Inject `EventBusManager` into the use case or BLoC that owns the successful operation, then call `fire()` after the state-changing work succeeds.

```dart
@Injectable(as: DeletePostUsecase)
class DeletePostInteractor implements DeletePostUsecase {
  final PostRepository _repository;
  final EventBusManager _eventBusManager;

  DeletePostInteractor(this._repository, this._eventBusManager);

  @override
  Future<void> deletePost(String postId) async {
    await _repository.deletePost(postId: postId);
    _eventBusManager.fire(PostDeletedBusEvent(postId: postId));
  }
}
```

For background work, fire progress/completion/failure events only when the task meaningfully changes. Use a distinct check, throttling, or batching for high-frequency progress updates.

```dart
void _updateTask(String taskId, PostingTask task) {
  if (_tasks[taskId] == task) return;

  _tasks[taskId] = task;
  _notifyTasksChanged();
  _eventBusManager.fire(PostingTaskUpdatedBusEvent(task: task));
}
```

## Subscription pattern in BLoCs

Declare a typed subscription, subscribe in the constructor after registering BLoC event handlers, and delegate to a listener method.

```dart
@Injectable()
class RecordsListingBloc
    extends AppBlocBase<RecordsListingEvent, RecordsListingState> {
  final RecordsUsecase _usecase;
  StreamSubscription<RecordActivityChangedBusEvent>? _eventSubscription;

  RecordsListingBloc(
    this._usecase,
    EventBusManager eventBusManager,
  ) : super(RecordsListingInitial(data: const _StateData())) {
    on<GetRecordsEvent>(_onGetRecordsEvent);
    on<ActivityCreatedEvent>(_onActivityCreatedEvent);
    on<ActivityUpdatedEvent>(_onActivityUpdatedEvent);

    _eventSubscription = eventBusManager.on<RecordActivityChangedBusEvent>().listen(
      _recordActivityBusListener,
    );
  }

  void _recordActivityBusListener(RecordActivityChangedBusEvent event) {
    switch (event.type) {
      case RecordActivityChangeType.created:
        add(ActivityCreatedEvent(log: event.log));
        break;
      case RecordActivityChangeType.updated:
        add(ActivityUpdatedEvent(log: event.log));
        break;
    }
  }

  @override
  Future<void> close() async {
    await _eventSubscription?.cancel();
    await super.close();
  }
}
```

If the bloc file does not already import `dart:async`, add it for `StreamSubscription`.

## Handling grouped events

When subscribing to an abstract event group, type-check the handled variants in one listener and add BLoC events for actual state changes.

```dart
StreamSubscription<PostBusEvent>? _postEventBusSubscription;

_postEventBusSubscription = _eventBusManager.on<PostBusEvent>().listen(
  _listenToPostEvents,
);

void _listenToPostEvents(PostBusEvent event) {
  if (event is PostDeletedBusEvent) {
    add(RemovePostEvent(postId: event.postId));
  } else if (event is PostUpdatedBusEvent) {
    add(UpdatePostEvent(post: event.post));
  }
}
```

Prefer separate subscriptions when handlers are unrelated or strongly typed callbacks make the code simpler.

## Payload guidelines

| Scenario | Payload |
|---|---|
| Remove an item | ID only, e.g. `postId`, `adId`, `blockedUserId` |
| Replace/update an item in a list | Full updated model |
| Refresh a list | Small change-type enum or marker event |
| Sync counters/statistics | ID plus updated counter values |
| Background task status | Task entity plus optional result model/error data |
| Profile or account switch | Selected user/profile object or changed field |

Avoid passing UI `BuildContext`, widgets, BLoC instances, repositories, callbacks, or mutable collections through bus events.

## Testing pattern

In tests, construct a real manager with a local event bus unless you need to verify `fire()` calls directly:

```dart
final eventBusManager = EventBusManager(EventBus());
```

For BLoC tests that listen to bus events, fire the event through the same manager instance used by the BLoC, then assert that the BLoC emits the expected state or effect.

## Checklist

- [ ] The new event extends `BusEvent` directly or through a domain-specific abstract base.
- [ ] The event name describes a completed fact, not an imperative command.
- [ ] The event file is in `domain/bus_event/` or beside the owning use case following existing patterns.
- [ ] Publishers call `_eventBusManager.fire(...)` only after successful work or task-state updates.
- [ ] Subscribers use the narrowest practical `on<T>()` type.
- [ ] BLoC listeners call `add(...)` instead of emitting directly from the stream callback.
- [ ] Every `StreamSubscription` is stored and canceled in `close()`.
- [ ] Tests use the same `EventBusManager` instance for publisher and subscriber.

## Common mistakes

- Creating a bus event for state that only one BLoC owns.
- Firing before an API/repository operation succeeds.
- Listening to `on<BusEvent>()` when `on<PostBusEvent>()` or `on<SpecificEvent>()` is enough.
- Updating BLoC state directly in the stream listener instead of adding a BLoC event.
- Forgetting to cancel a subscription in `close()`.
- Passing UI objects, services, or callbacks inside event payloads.
- Using bus events to hide direct dependencies that should be explicit use case calls.

## Related

- [`bloc-pattern`](../bloc-pattern/SKILL.md)
- [`data-layer`](../data-layer/SKILL.md)
- [`testing`](../testing/SKILL.md)
