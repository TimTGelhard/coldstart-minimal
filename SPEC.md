# coldstart-minimal — SPEC

> Written before the build, per the family contract (`../../CHARTER.md`).
> Status: **scoped, not built.** 2026-08-19.

> **UNPARKED — 2026-08-21 (Tim).** The two lean harnesses are not experiments waiting on a
> benchmark; they are the product, and they ship. The parking argument still stands on its own
> terms — no comparator exists, so nothing here can be *scored* — and the consequence is stated
> rather than hidden: `minimal` ships unmeasured. Every byte figure below is a census of what
> is written, not evidence that it works. The ColdStart-side card
> (`/Users/macbook/coldstart/docs/deepseek-transfer/decisions/program-parked.md`) still says
> parked and still points at a stale path; it is owed a superseding entry.

## The job

The leanest thing that still measurably beats a bare agent with no harness at all.

The test it has to pass is not "is it good." It is: **does removing it make the agent
worse?** If a bare agent scores the same, this harness is 100% overhead and should not
exist. That is a real possible outcome and the program should be willing to publish it.

## Who it is for

Someone who will not read the manual, will not maintain a warehouse, and wants one command.
Also: every new project of Tim's that does not justify the full tree.

## Declared budget

- **Resident: under 2,000 B.** Hard ceiling. For scale, ColdStart's floor is 38,616 B and
  its project `CLAUDE.md` alone is 8,015 B.
- **Install: one file fetched, one command, under 10 seconds.**
- **Runtime dependencies: none.** No Python, no `jq`, no network after install.
- **Files: target under 10.** If it needs a directory tree it is not minimal.

## What it deliberately omits

Every one of these is in ColdStart and is being left out on purpose. The omission is the
experiment; if the score drops, the component earned its bytes.

| Omitted | ColdStart carries |
|---|---|
| Warehouse / knowledge rooms | 364 documents under `docs/` |
| Lifecycle state + projections | `LIFECYCLE.json` + generated `PROGRESS.md`, `MAP.md` |
| Capability library + routing | 50 cards, facet-map, `facet_search.py` — **and the evidence is already in**: facet-map recall@3 0.9429 vs a bag-of-words baseline at 0.9714. It loses to the dumb version. Drop it first. |
| Chapters | 84 files |
| Verify | 30 check-classes, 65 test files |
| Skills | 17 routers |
| Commands | 8 wrappers |
| Python tools | 75 modules |

## What it probably keeps

Scoped now — **resolved by the feature ledger below**, which supersedes this list. The
candidates, in the order they earn their bytes:

1. **A safety floor.** The one thing that is a defect if skipped rather than a judgment
   call. Today's flip found the env-leak `deny` was silently unreachable on this machine
   for months — prose would never have caught that. Strongest candidate for the single hook.
2. **A "state the goal in one sentence" rule.** The cheapest discipline in the whole tree.
3. **A "verify, don't self-report" rule.** The highest-value one.

Everything else has to argue for itself against the 2,000 B ceiling.

## The open question this harness answers

Is ColdStart's value in its *content* (the accumulated 84 chapters of hard-won discipline)
or in its *enforcement* (the 4 hooks and 30 checks that make a few things non-optional)?

`minimal` keeps enforcement and throws away content. If it scores close to `standard`, the
content is mostly ballast and the whole family should be rebuilt around enforcement. If it
collapses, the chapters are the product and the byte cost is the price of admission.

That single result should decide the shape of every other harness in this folder.

## The feature ledger

> Scoped 2026-08-19, against a live census of ColdStart's **rendered** surface, not its
> file list. Command: `verify --only floor-growth`, plus `wc -c` on the three injected
> markdown files the floor guard does not census.

### Where ColdStart's resident bytes actually are

| Item | Bytes | Note |
|---|---|---|
| 17 `cs-*` router descriptions | 12,121 | avg **713 B each** — the largest single item by a wide margin |
| project `.claude/CLAUDE.md` | 8,181 | |
| profile, injected verbatim | 5,222 | |
| global `~/.claude/CLAUDE.md` | 4,358 | |
| 8 command wrappers | 1,959 | avg 245 B |
| facet-map dock | 1,750 | |
| 3 agent definitions | 989 | |

Two findings fall out before any feature argument. Router descriptions average 713 B; at
250 B each the same 17 routers cost 4,250 B instead of 12,121 B — **count is not the only
dial, and nobody has turned the other one**. And the profile is the second-largest resident
item in the tree, and no chapter, check or decision has ever questioned its weight.

### Keeps — the whole of `minimal`

> Measured 2026-08-21 against the drafts in `draft/`, not estimated. `wc -c` on each file;
> for the command wrapper, only the `description:` line is resident (the body loads on
> invocation), matching how ColdStart's floor guard counts its eight.

| Feature | Resident | Why it survives the ceiling |
|---|---|---|
| PreToolUse safety floor hook | **0 B** | It fires; it does not inject. The 2026-08-19 flip found the env-leak `deny` silently unreachable machine-wide for months — prose would never have caught that |
| One `CLAUDE.md`: the collaborator line, the session-open routine, four working rules, the closing routine, and the profile-lite block | **1,656 B** | Measured. Carries the behaviour lines, the whole memory protocol and the user calibration in one file — profile-lite became a `## You` section rather than a second file with an import mechanism |
| `/done` wrapper | **~78 B** | Description line only; the procedure lives in `CLAUDE.md`, so the wrapper is a trigger and nothing else |
| SessionStart hook | 0 B harness | It injects the pointer block from `PROGRESS.md` (~250 B of *project* state), which is what makes `/coldstart` unnecessary here: the resume happens without anyone typing anything |

Census: **1,734 B harness-owned**, printed by the installer itself at the end of every run,
plus one work block (200-600 B) the SessionStart hook injects. Roughly 1,950 B against a
2,000 B ceiling, and the headroom is now effectively gone. Every number above is now measured; none is estimated. The headroom is thin, and
the first thing cut if it runs over is the `/done` wrapper, since `CLAUDE.md` already
carries the routine it triggers.

### The memory model — two files, no folders, no script

> Added 2026-08-21 (Tim). The original ledger dropped persistence entirely. That was wrong
> against the family's own stated job: **a harness exists so you do not re-prompt the project
> into every session.** A harness that is only behaviour lines is a personality, not a
> harness — it survives inside a session and carries nothing across the boundary.

This is `standard`'s memory model with the machinery removed, which makes it a clean
one-axis ablation rather than a different design:

| | `standard` | `minimal` |
|---|---|---|
| Index files | 3 (`PROGRESS` / `DECISIONS` / `FIXES`) | 2 (`PROGRESS` / `DECISIONS`) |
| Content folders | 3, clustered by topic | none |
| Index maintenance | derived by `tools/index.py` at `/done` | hand-written, capped by a rule |
| Open work | its own file and folder | a section inside `PROGRESS.md` |

```
PROGRESS.md    Now (pointer) · Open, not now · Log (keep 5)   read every session
DECISIONS.md   append at the top, one dated line each         grepped, never read whole
```

Three rules carry it, all of them in the measured `CLAUDE.md` above:

1. **`PROGRESS.md` is short by construction, not by discipline.** It has three fixed
   sections, the log keeps five lines and older ones are deleted. Git is the archive.
2. **`DECISIONS.md` is append-only and never read whole.** It is the one file allowed to
   grow without bound, and it stays cold because the rule is to grep it before deciding
   something that sounds already settled.
3. **No script, and therefore no drift check.** `standard` derives its indexes by scanning
   folders; `minimal` has no folders to scan, so the files *are* the content. Nothing can
   disagree with anything.

What this buys, and what it costs: it survives the session boundary at roughly 250 B of
resident cost, and it degrades by hand — a user who stops writing the log gets a stale
pointer with nothing to catch it. `standard` spends a Python script to remove exactly that
failure mode. Which of those is worth the machinery is the sharpest question the two
harnesses can answer, and it is answerable by use long before it is answerable by score.

### Abandons — named, so the build cannot quietly re-add them

Warehouse and rooms · `LIFECYCLE.json` and every projection · capability library,
facet-map and dock (**the evidence is already in**: recall@3 0.9429 against a
bag-of-words baseline at 0.9714) · all 84 chapters · the other 16 routers · all 8 command
wrappers · all 30 check-classes · `registry.tsv` · adopt · bucket · the agent roster ·
eval.

### The axis warning

`minimal` as specced differs from `standard` on **four** axes at once: weight,
persistence, routing, and chapters. That breaks the charter's own one-axis rule, so a
score delta between the two endpoints attributes to nothing.

The fix is not to fatten `minimal`. It is to treat `minimal` as an **endpoint** and do the
attribution with ablation runs against `standard` — `standard` minus persistence,
`standard` minus routing — each of which is one dial off a fixed base.

## Status — built and installable, 2026-08-21

Everything in the ledger exists and has been exercised.

| Piece | State |
|---|---|
| `template/CLAUDE.md` | 1,656 B, measured |
| `template/PROGRESS.md` | a marker-delimited queue: active block on top, `---`, then planned blocks that cost nothing. Amended 2026-08-21 (Tim) |
| `template/DECISIONS.md` | written, the shape is fixed |
| `template/.claude/hooks/floor.sh` | **7/7 self-test passing** (`tests/floor-test.sh`): four denials fire, three benign payloads pass |
| `template/.claude/hooks/session-start.sh` | reads to the `---` marker, not to a line count, with a 40-line backstop. Proven on a three-block queue: a 243 B block and a 598 B block both printed whole, and promotion at close surfaced the next one |
| `template/.claude/commands/done.md` | 133 B, description line resident |
| `install.sh` | installs, re-installs without clobbering a user-edited file, and uninstalls cleanly. All three paths run |
| `README.md` | the shipping face |

Verified by running it, not by reading it: a scratch project took the install, kept a
hand-added `DECISIONS.md` line across a second install, printed its pointer from the hook,
and came back to three user files plus `settings.json` after `--uninstall`.

Not done: no git repository or public remote yet, and the `settings.json` merge path writes
a sidecar file for the user to merge by hand rather than merging JSON without a parser —
deliberate, since a JSON merge would cost the "no runtime dependencies" line.

**On the missing benchmark.** The comparison facility this harness's original premise leaned
on still does not exist (W120; see `../../CHARTER.md`), so "beats a bare agent" remains a claim
nobody can currently evaluate — for `minimal`, for `standard`, or for ColdStart's 38,616 B. That
is now a stated limitation rather than a blocker. The harness ships on the argument that a
session which reads its own pointer beats one that does not, and the byte census proves only
what it costs, never what it returns.

**The DeepSeek observation, recorded because it shaped the design.** The transferred harness
added only a handful of lines, one of them a plain instruction not to be afraid to push back.
That is the best byte-for-effect ratio anywhere in this family: roughly 60 B that changes every
turn of every session, against 12,121 B of router descriptions in the control tree. `minimal`
takes the lesson as far as it goes and no further — behaviour lines first, then the two files
that are the difference between a personality and a harness.
