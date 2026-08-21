# coldstart-minimal

A harness for Claude Code that fits in one file you can read in a minute.

Its whole job: **you should not have to re-explain your project at the start of every session.**

## Install

```
git clone https://github.com/TimTGelhard/coldstart-minimal.git
cd coldstart-minimal && ./install.sh /path/to/your/project
```

One command, nothing to build, no runtime dependencies. `./install.sh --uninstall <dir>`
takes it back out and leaves your notes alone.

## What lands in your project

```
CLAUDE.md       the harness. Read every session. 1,388 bytes.
PROGRESS.md     what you are doing, what is open, what happened last
DECISIONS.md    one dated line per decision, newest at the top
.claude/
  settings.json           registers the two hooks
  commands/done.md        /done - close the session
  hooks/floor.sh          refuses four things, never speaks otherwise
  hooks/session-start.sh  prints your pointer into the session, so you type nothing
```

That is the entire harness. Three files you own, four the installer owns.

## How it works

**Opening.** The session-start hook prints the "Now" block of `PROGRESS.md` into the
session before you say anything. That is why there is no `/coldstart` command: a command
would be a worse version of a thing that already happens for free.

**Working.** `CLAUDE.md` carries five rules that cost about 1.4 KB and change every turn:
be a collaborator and push back, state the goal in one sentence, grep `DECISIONS.md`
before re-deciding something, verify instead of self-reporting, and stop and ask when the
spec is ambiguous.

**Closing.** `/done` rewrites the pointer, adds one line to the log, and appends any
decision you made. `PROGRESS.md` stays short by construction: the log keeps five lines and
older ones are deleted, because git is the archive. `DECISIONS.md` is the one file allowed
to grow, and it stays cheap because the rule is to grep it, never to read it whole.

## The safety floor

`hooks/floor.sh` blocks four things and is silent otherwise: deleting a root path
recursively, printing a `.env` file into the transcript, piping a download straight into a
shell, and force-pushing. It denies, it never injects, so it costs zero context.

It is coarse on purpose. It pattern-matches the raw tool payload, so it can occasionally
refuse something harmless that mentions one of those strings. That trade is deliberate: a
floor that is slightly too eager is worth more than one that is subtly unreachable.

Run `bash tests/floor-test.sh` to watch all four denials actually fire. This exists because
the harness this one was cut down from shipped a `.env` deny that was silently unreachable
for months, and nobody noticed by reading it.

## What it costs

About 1,466 bytes of harness in your context at every session start, plus roughly 250 bytes
of your own pointer. For scale, the full ColdStart tree it was cut down from carries 38,616
bytes and 1,065 files.

## What it is not

There is no scoring here. Nothing in this repo proves the harness makes the model better,
because the benchmark that would prove it does not exist yet. The byte count is a
measurement; the benefit is an argument. The argument is that a session which reads its own
notes beats one that starts from nothing, and you can judge that in a week of use.

## License

MIT.

## Bigger siblings

`coldstart-standard` adds a real plan surface: three index files with topic-clustered
folders behind them, and a script that regenerates the indexes by scanning, so they cannot
go stale. `coldstart` is the full tree. This one is the floor.
