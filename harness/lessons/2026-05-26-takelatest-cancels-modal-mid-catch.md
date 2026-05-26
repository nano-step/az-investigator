# Lesson: takeLatest cancels the catch-block modal dispatch mid-yield

| | |
|---|---|
| **Date** | 2026-05-26 |
| **Captured by** | Sisyphus |
| **Severity** | data-corrupting |
| **Cost first time** | 60 minutes |
| **Tool / file / quirk** | redux-saga catch + takeLatest interaction |
| **Triggers re-find** | takeLatest cancels catch saga session timeout modal never fires redux-saga |

## What I expected
A 401 caught in a saga's catch block reliably dispatches SET_SESSION_TIMEOUT_MODAL_CONFIG, which opens the session-timeout modal.

## What actually happened
takeLatest cancels the prior worker task when a new action arrives. The catch block has 2 yields before the modal put — a new dispatch within those ~50ms (or longer if network slow) cancels it. With dispatches every 9-13s, the modal NEVER lands.

## Why it surprised me
I read the catch code linearly and assumed yields were instantaneous. Cancellation semantics of takeLatest mid-catch were not in my mental model.

## How I diagnosed it
Code analysis: confirmed takeLatest at saga.js:1393. Confirmed catch block has yield select + yield put before the critical action. Read redux-saga docs on cancellation propagation through yields.

## Generalizable rule
Side effects in catch blocks under takeLatest are unsafe. Use spawn (detached) or putResolve, or switch the watcher to takeEvery.

## Where this belongs (when promoted)
- [x] references/known-quirks.md Q16 + worked-example A in PLAN-v2.md

## Open follow-ups
Verify the hypothesis with a runtime test: tamper a cookie, fire rapid refreshBalance, check whether SET_SESSION_TIMEOUT_MODAL_CONFIG lands in the store.
