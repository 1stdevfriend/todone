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
[ "$(t --version)" = "$(t v)" ] && t --version | grep -q '^todone [0-9]' || fail version
# subtasks, due dates, estimates
t -w sub n 'parent' >/dev/null && t -w sub n 'next' >/dev/null
t -w sub a 1 'child one' >/dev/null && t -w sub a 1 'child two' >/dev/null
[ "$(sed -n 2,3p home/sub.md)" = "$(printf '  - [ ] child one\n  - [ ] child two')" ] || fail "subtasks: $(cat home/sub.md)"
t -w sub l | grep -q '  3   \[ \] child two' || fail 'subtask listing'
t -w sub x 3 >/dev/null; has home/sub.md '  - [x] child two'
t -w sub due 1 2026-11-02 >/dev/null && t -w sub est 1 1.5h >/dev/null
has home/sub.md '- [ ] parent ⏱ 1h30m 📅 2026-11-02'
t -w sub e 1 'renamed parent' >/dev/null; has home/sub.md '- [ ] renamed parent ⏱ 1h30m 📅 2026-11-02'
t -w sub due 1 '' >/dev/null; has home/sub.md '- [ ] renamed parent ⏱ 1h30m'
t -w sub due 1 2026-02-30 2>/dev/null && fail 'bad date should fail'
t -w sub est 1 lots 2>/dev/null && fail 'bad estimate should fail'
[ "$(t -w sub due 1 tom >/dev/null && grep -o '📅 .*' home/sub.md)" = "📅 $(date -v+1d +%F)" ] || fail 'relative due date'
t -w sub d 1 >/dev/null; [ "$(cat home/sub.md)" = '- [ ] next' ] || fail "delete takes subtasks: $(cat home/sub.md)"
# move a task with its subtasks; a subtask moves alone
t -w mv n 'one' >/dev/null && t -w mv a 1 'kid' >/dev/null && t -w mv n 'two' >/dev/null
t -w mv m 1 mv2 >/dev/null; [ "$(cat home/mv2.md)" = "$(printf -- '- [ ] one\n  - [ ] kid')" ] && [ "$(cat home/mv.md)" = '- [ ] two' ] || fail "move: $(cat home/mv.md home/mv2.md)"
t -w mv2 m 2 mv >/dev/null; has home/mv.md '- [ ] kid'
t -w mv m 1 mv 2>/dev/null && fail 'move to the same list should fail'
t -w mv m 1 ../x 2>/dev/null && fail 'move to a bad name should fail'
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
# The pty reports 0x0, so the TUI lays out at 80x24: columns 9-18 of row 24
# are the home tab, tab 1 starts at 19. The list is a centered block from
# column 3; with two tasks its first task sits on row 12.
click() { printf '\\033[<0;%s;%sM\\033[<0;%s;%sm' "$1" "$2" "$1" "$2"; }
keys n '\n' 'one\n' N 'two\n' 'three\n' '\n' g x z x e ' more\n' n zzz '\033' s wo rk '\n' n 'ship\n' \
	"$(click 22 24)" / ree '\n' d "$(click 4 12)" 2 c q |
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
has undo/inbox.md '- [ ] outside'
[ "$(cat undo/.tabs)" = inbox ] || fail "D tabs: $(cat undo/.tabs)"
printf 'inbox\nwork\n' >"$TODONE_HOME/.tabs"
printf -- '- [ ] w\n' >"$TODONE_HOME/work.md"
keys 2 D z q | pty sh "$T" >/dev/null 2>&1 || true
has undo/work.md '- [ ] w'
grep -qx work undo/.tabs || fail 'z should reopen the tab'


# TUI: add a subtask, indent, then focus on the first task for ~31 seconds
# (recorded as 1m spent), switch to a break, finish it with x; open and leave the calendar.
export TODONE_HOME="$tmp/new"
mkdir -p "$TODONE_HOME"
printf -- '- [ ] a ⏱ 2h\n- [ ] b\n' >"$TODONE_HOME/inbox.md"
{ keys a 'a1\n' G '>' g p; sleep 31; keys ' ' x C l '\033' q; } | pty sh "$T" >/dev/null 2>&1 || true
[ "$(cat new/inbox.md)" = "$(printf -- '- [x] a ⏱ 2h ⏳ 1m\n  - [ ] a1\n  - [ ] b')" ] || fail "tui sub/focus: $(cat new/inbox.md)"

# m moves a task to another list (picked by typing its name); one z undoes both files.
export TODONE_HOME="$tmp/mv"
mkdir -p "$TODONE_HOME"
printf -- '- [ ] a\n  - [ ] a1\n- [ ] b\n' >"$TODONE_HOME/inbox.md"
printf -- '- [ ] w\n' >"$TODONE_HOME/work.md"
keys m wor '\n' q | pty sh "$T" >/dev/null 2>&1 || true
[ "$(cat mv/inbox.md)" = '- [ ] b' ] && [ "$(cat mv/work.md)" = "$(printf -- '- [ ] w\n- [ ] a\n  - [ ] a1')" ] || fail "tui move: $(cat mv/*.md)"
keys j m new '\n' z q | pty sh "$T" >/dev/null 2>&1 || true
[ "$(cat mv/inbox.md)" = '- [ ] b' ] && [ ! -e mv/new.md ] || fail "move undo: $(cat mv/*.md)"

# A timer that runs out keeps counting as overtime instead of starting a break.
TODONE_POMO='0.05 1' && export TODONE_POMO
{ keys p; sleep 5; keys '\033' q; } | pty sh "$T" >"$tmp/out" 2>&1 || true
# (the hint reads "space focus" only while on a break)
grep -q 'focus overtime' "$tmp/out" && ! grep -q 'space[^a-z]*mfocus' "$tmp/out" || fail 'focus should not auto-switch'
unset TODONE_POMO

# A folder with no list opens home; New list there starts this folder's list.
export TODONE_HOME="$tmp/fresh-home"
mkdir -p "$tmp/fresh" && cd "$tmp/fresh"
# (click New list: with no lists, the centered block starts on row 3 of 24,
# so the menu starts on row 10)
keys "$(click 40 10)" '\n' 'hello\n' q | pty sh "$T" >/dev/null 2>&1 || true
has "$TODONE_HOME/fresh.md" '- [ ] hello'
grep -qx fresh "$TODONE_HOME/.tabs" || fail 'new list should get a tab'
# D on home deletes the selected list (the only one here).
keys 0 D q | pty sh "$T" >/dev/null 2>&1 || true
[ ! -e "$TODONE_HOME/fresh.md" ] || fail 'home D'
echo ok
