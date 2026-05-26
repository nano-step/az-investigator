# Lesson: az resource list --query on nested properties returns [] silently

| | |
|---|---|
| **Date** | 2026-05-26 |
| **Captured by** | Sisyphus |
| **Severity** | annoying |
| **Cost first time** | 15 minutes |
| **Tool / file / quirk** | az CLI nested property filter |
| **Triggers re-find** | az resource list query InstrumentationKey nested property empty |

## What I expected
az resource list --query "[?properties.InstrumentationKey=='...']" would filter resources.

## What actually happened
Returned empty array even though the matching resource existed.

## Why it surprised me
Azure CLI's JMESPath filter does not always traverse nested properties on this resource type. Silent failure mode.

## How I diagnosed it
Switched to listing all components, then per-component 'az monitor app-insights component show --query instrumentationKey'.

## Generalizable rule
Don't trust nested --query filters in az resource list. List first, then loop with show.

## Where this belongs (when promoted)
- [x] references/known-quirks.md Q6 + scripts/run-kql.sh discovery pattern

## Open follow-ups
Is this fixed in newer az CLI versions? Worth a periodic re-check.
