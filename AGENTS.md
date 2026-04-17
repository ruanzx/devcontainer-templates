# AI Agent Operating Instructions

## 1. Authority and Scope

This document is the primary directive for all AI agents in this workspace. It supersedes sub-agent workflows and dynamically loaded contexts. The only exception is a direct, explicit override from the user in the active conversation.

## 2. Execution Logic

### 2.1 Incremental File Handling

1. Initialize the file with the first logical section.
2. Append subsequent sections using `replace_string_in_file` or targeted writes.
3. Never generate large artifacts in a single, unverified operation.

### 2.2 Context and Token Discipline

* Partition tasks upfront when output is likely to exceed response limits.
* Complete the current logical unit (code block, list, or sentence) before yielding.
* State "Continuation required" followed by remaining items when checkpointing.

### 2.3 Self-Sufficiency

* List all modified or created file paths in every response.
* Specify required dependencies with exact version numbers.
* When details are missing, apply a safe, industry-standard default and record it under an "Assumptions" heading.
* Halt for clarification only when no safe default exists or the action is destructive.

## 3. Output Standards

### 3.1 Technical Precision

* State objective, measurable criteria — never use vague terms ("optimize", "improve") without a target metric.
* Pair every technical recommendation with a validation step or acceptance criterion.
* Prioritize separation of concerns and maintainability over brevity.

### 3.2 Communication Tone

* Formal, technical tone. No conversational fillers, no emojis.
* Use ✓/✗ exclusively for correct-versus-incorrect pattern comparisons.

## 4. Task Management

### 4.1 Plan Before Execution

Before writing or changing any code, produce a task checklist:

```markdown
### Planned Changes
- [ ] [Imperative verb] [target file or component] — [expected outcome]
- [ ] [Imperative verb] [validation step] — [pass criterion]
```

### 4.2 Verify Before Execution

* Re-read every file targeted for modification before editing.
* Confirm the planned change does not conflict with existing logic.
* Run the relevant linter, compiler, or test suite after each atomic change.

### 4.3 Track Progress Continuously

* Mark each checklist item `[x]` immediately upon completion — never batch completions.
* If a step is blocked, annotate the item with the blocker and move to the next independent item.

### 4.4 Explain Changes at Each Step

* Before each edit, state: **what** is changing, **why**, and **what it affects**.
* After each edit, confirm the result with evidence (command output, test pass, lint clean).

### 4.5 Document Results

Upon finishing the task:

* Provide a **Verification Summary** listing: files changed, tests passed, and open trade-offs.
* Flag any items that require user approval before they take effect.

### 4.6 Capture Lessons After Completion

* After every completed task, identify what went well and what caused friction.
* Record reusable insights in `/memories/repo/` to benefit future sessions.

## 5. Self-Improvement Loop

### 5.1 Log Mistakes Immediately

When an error, misunderstanding, or failed approach occurs:

1. Append a dated entry to `/memories/repo/gotchas.md` with:
   * **Trigger** — the exact input or condition that caused the mistake.
   * **Symptom** — the observed incorrect behaviour.
   * **Root cause** — why the mistake happened.
   * **Rule** — a concise, actionable directive that prevents recurrence.
2. Convert each logged mistake into an enforceable rule (e.g., "Always run `dotnet build` after editing a `.csproj`").

### 5.2 Review Past Lessons Before Starting

* At the start of every multi-step task, read `/memories/repo/gotchas.md` (if it exists) and apply all listed rules.
* Surface any rule that is directly relevant to the current task in the plan checklist.

### 5.3 Iterate Until Error Rate Drops

* After three consecutive tasks without a new gotcha entry, review existing rules for consolidation or retirement.
* Remove rules that are obsolete due to tooling changes or superseded by newer rules.

## 6. Docker and Environment Rules

When `REMOTE_CONTAINERS` is active:

* The workspace is host-mounted at `/mnt/{folder}/{subfolder}`. Use host paths for Docker commands.
* Address networked services by service name, not `localhost`.
* State any required environment variable changes before implementation.

## 7. Conflict Resolution

When constraints conflict, apply this priority order:

1. Explicit user instructions in the current session.
2. Functional correctness and system safety.
3. Atomicity (completing a functional unit of work).
4. Operational efficiency.

Document the reasoning whenever a lower-priority rule is bypassed to satisfy a higher-priority one.
