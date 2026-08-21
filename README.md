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
CLAUDE.md       the harness. Read every session. 1,656 bytes.
PROGRESS.md     the work queue. Only the top block is ever loaded
DECISIONS.md    one dated line per decision, newest at the top
.claude/
  settings.json           registers the two hooks
  commands/done.md        /done - close the session
  hooks/floor.sh          refuses six things, never speaks otherwise
  hooks/session-start.sh  prints your pointer into the session, so you type nothing
```

That is the entire harness. Three files you own, four the installer owns. It also adds
the secret-file rules to your `.gitignore`, or writes one if you have none.

## How it works

**Opening.** The session-start hook prints the top block of `PROGRESS.md` into the session
before you say anything. That is why there is no `/coldstart` command: a command would be a
worse version of a thing that already happens for free.

`PROGRESS.md` is a queue. The active block sits at the top, a `---` marks the end of it, and
everything below is planned work waiting its turn. The hook reads to the marker and stops, so
a block can be four lines or forty and the boundary is still right. A line offset would be
wrong for every session, since sessions are not the same size. `CLAUDE.md` then tells the
model to open that file only to write, never to catch up, which is what keeps the rest of the
queue out of context rather than merely out of the printout.

The effect: the queue can hold fifty planned sessions and still cost you one block.

**Working.** `CLAUDE.md` carries five rules that cost about 1.4 KB and change every turn:
be a collaborator and push back, state the goal in one sentence, grep `DECISIONS.md`
before re-deciding something, verify instead of self-reporting, and stop and ask when the
spec is ambiguous.

**Closing.** `/done` deletes the finished block and promotes the next one from the queue
into its place, adds one line to the log, and appends any decision you made. `PROGRESS.md` stays short by construction: the log keeps five lines and
older ones are deleted, because git is the archive. `DECISIONS.md` is the one file allowed
to grow, and it stays cheap because the rule is to grep it, never to read it whole.

## The safety floor

`hooks/floor.sh` blocks six things and is silent otherwise: deleting a root path
recursively, printing a secret file into the transcript, piping a download straight into a
shell, force-pushing, staging a secret file into git, and staging everything while an
unignored secret file is sitting in the tree. It denies, it never injects, so it costs zero
context.

The last two are a different exposure from the rest. A secret printed into a transcript
stays on your machine. A secret that reaches a remote is public from that moment and stays
public after you delete the commit, because the object survives in forks, clones and
caches, so the only real remedy is rotating the credential. The floor is the fast half of
that protection and the `.gitignore` line the installer writes is the durable half: a hook
can be unregistered, an ignore rule travels with the repo. Neither one helps if the file is
already tracked, which needs `git rm --cached` and a new credential.

It is coarse on purpose. It pattern-matches the raw tool payload, so it can occasionally
refuse something harmless that mentions one of those strings. That trade is deliberate: a
floor that is slightly too eager is worth more than one that is subtly unreachable.

Run `bash tests/floor-test.sh` to watch every denial actually fire, and the allow cases with
them. This exists because the harness this one was cut down from shipped a secret-file deny
that was silently unreachable for months, and nobody noticed by reading it.

## What it costs

About 1,734 bytes of harness in your context at every session start, plus one work block,
which runs 200 to 600 bytes depending on how much the task needs. For scale, the full ColdStart tree it was cut down from carries 38,616
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
