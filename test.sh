#!/bin/sh
# Self-check: sh test.sh  (run under dash too: dash test.sh)
set -eu
T=$(cd "$(dirname "$0")" && pwd)/todone
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export TODONE_HOME="$tmp/home" NO_COLOR=1 HOME="$tmp"
mkdir -p "$tmp/proj/sub" "$tmp/blog"
cd "$tmp"
t() { sh "$T" "$@"; }
fail() { echo "FAIL: $*"; exit 1; }
has() { grep -qF -- "$2" "$1" || fail "$1 missing: $2"; }

t n 'buy milk' >/dev/null
t n 'back\slash & $dollar' >/dev/null
has home/inbox.md '- [ ] buy milk'
has home/inbox.md '- [ ] back\slash & $dollar'
t x 1 >/dev/null; has home/inbox.md '- [x] buy milk'
t x 1 >/dev/null; has home/inbox.md '- [ ] buy milk'
t e 2 'renamed' >/dev/null; has home/inbox.md '- [ ] renamed'
t d 1 >/dev/null; ! grep -q milk home/inbox.md || fail delete
t d 9 2>/dev/null && fail 'deleting missing task should fail'
t x abc 2>/dev/null && fail 'non-number should fail'

(cd blog && t n 'draft post' >/dev/null)
has home/blog.md '- [ ] draft post'
t -w inbox n 'from anywhere' >/dev/null; has home/inbox.md 'from anywhere'
t -w ../evil n x 2>/dev/null && fail 'path in list name should fail'
t s | grep -q 'blog' || fail 'lists'
t -w gone n 'temp' >/dev/null && t -w gone D >/dev/null
[ ! -e home/gone.md ] || fail 'D should remove the list'
ls .Trash/todone-gone-*.md >/dev/null 2>&1 || fail 'D should move the list to the Trash'

(cd blog && t init >/dev/null && has TODO.md '- [ ] draft post')
[ ! -e home/blog.md ] || fail 'init should move the list'
cd proj && t init >/dev/null
printf 'notes stay\n' >>TODO.md
cd sub && t n 'local task' >/dev/null && cd ..
has TODO.md '- [ ] local task'
has TODO.md 'notes stay'
t l | grep -q '1 \[ \] local task' || fail 'local list'

# TUI smoke test through a pseudo-terminal (macOS `script`).
pty() { script -q /dev/null "$@"; }
export TODONE_HOME="$tmp/tui"
cd "$tmp"
keys() { for k in "$@"; do sleep 0.3; printf '%b' "$k"; done; sleep 0.3; }
# new, add-many, tick, undo, re-tick, edit, esc, open "work", click tab 1,
# find+delete, click marker to untick, close tab
# The pty reports 0x0, so the TUI lays out at 80x24: tab 1 sits at columns 9-19
# of row 24, and task 1's marker at column 4 of row 3.
click() { printf '\\033[<0;%s;%sM\\033[<0;%s;%sm' "$1" "$2" "$1" "$2"; }
keys n 'one\n' N 'two\n' 'three\n' '\n' g x z x e ' more\n' n zzz '\033' s wo rk '\n' n 'ship\n' \
	"$(click 10 24)" / ree '\n' d "$(click 4 3)" 2 c q |
	pty sh "$T" >/dev/null 2>&1 || true
has tui/inbox.md '- [ ] one more'
! grep -q zzz tui/inbox.md || fail 'esc should cancel'
has tui/inbox.md '- [ ] two'
! grep -q three tui/inbox.md || fail 'tui delete'
has tui/work.md '- [ ] ship'
[ "$(cat tui/.tabs)" = inbox ] || fail "tabs: $(cat tui/.tabs)"

# Undo must not clobber a change made outside the TUI.
export TODONE_HOME="$tmp/undo"
mkdir -p "$TODONE_HOME"
printf -- '- [ ] keep\n' >"$TODONE_HOME/inbox.md"
{ keys x; sleep 0.3; printf -- '- [ ] outside\n' >>"$TODONE_HOME/inbox.md"; keys z q; } | pty sh "$T" >/dev/null 2>&1 || true
has undo/inbox.md '- [x] keep'
has undo/inbox.md '- [ ] outside'

# D deletes the list and closes its tab; z brings both back.
printf 'inbox\nwork\n' >"$TODONE_HOME/.tabs"
printf -- '- [ ] w\n' >"$TODONE_HOME/work.md"
keys 2 D q | pty sh "$T" >/dev/null 2>&1 || true
[ ! -e undo/work.md ] || fail 'tui D'
[ "$(cat undo/.tabs)" = inbox ] || fail "D tabs: $(cat undo/.tabs)"
printf 'inbox\nwork\n' >"$TODONE_HOME/.tabs"
printf -- '- [ ] w\n' >"$TODONE_HOME/work.md"
keys 2 D z q | pty sh "$T" >/dev/null 2>&1 || true
has undo/work.md '- [ ] w'
grep -qx work undo/.tabs || fail 'z should reopen the tab'

echo ok
