## Level 1: event loop order

Predicted: A, C, B, 6 students
Actual: A, C, fetchStudents #1, (first frame), B, 6 students

Nothing waited for the timer: main() ran to the end, the screen was drawn,
and B / "6 students" came later as events.

### Three calls in a row
fetchStudents #1, #2, #3, B, 6 students, 6 students, then:
DartError: Instance of 'NoConnectionException'
(in Chrome this is the Unhandled Exception). The app kept running as if nothing happened.

Note: at first all three calls failed, because calls was checked after the await,
and by then all three requests had already set calls to 3.
Fix: final n = ++calls; before the await.

### sleep instead of await
With sleep() the first frame did not appear for several seconds:
the event loop was blocked, not waiting.

## Level 2: without mounted
DartError: setState() called after dispose(): _StudentsScreenState#14dec(lifecycle state: defunct, not mounted)

The response arrived at a State that was already gone (I pressed Back during loading).
With `if (!mounted) return;` the console stays clean.

## Level 3: FutureBuilder
Future in a field: flipping the Switch 10 times -> one fetchStudents #1, no flicker.
Future created in build: a spinner on every flip, console #2 #3 #4..., the 3rd one failed.

Server always failing: with hasError first -> error view + Retry.
With hasData first (wrong version) -> spinner forever.

## Level 4: countdown
Version B with cancel(): Back at 7 -> console stops at tick 7.

Version B without cancel(): Back at 5 ->
DartError: setState() called after dispose(): _CountdownBState#98ad0(lifecycle state: defunct, not mounted)
and the console kept printing tick 4, tick 3, tick 2, tick 1, tick 0 with nobody on screen. That is the leak.
The same error as in Level 2, a different messenger.

Version A (StreamBuilder), no cancel in my code: Back at 7 -> console stops.
StreamBuilder cancelled the subscription for me.

## Level 5: save
Un-awaited version: flutter analyze flagged the line (unawaited_futures).
The second Save popped the screen as if it worked, and the console said:
DartError: Bad state: server rejected 6   (in Chrome = Unhandled Exception)
The user saw a success.

Honest version: await + try / on StateError + context.mounted.
The screen pops only on success; on failure a SnackBar shows "server rejected 6".
While saving, the button is disabled and shows a spinner.