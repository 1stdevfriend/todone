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
# rename a list: the file, its tab and its sync state (restarted empty) follow
printf 'inbox\nmv\n' >home/.tabs && mkdir -p home/.sync && printf 'two\t0\t\n' >home/.sync/mv.tsv
t -w mv R moved >/dev/null
has home/moved.md '- [ ] two'
[ ! -e home/mv.md ] && [ "$(cat home/.tabs)" = "$(printf 'inbox\nmoved')" ] || fail "rename: $(ls home) $(cat home/.tabs)"
[ -f home/.sync/moved.tsv ] && [ ! -s home/.sync/moved.tsv ] && [ ! -e home/.sync/mv.tsv ] || fail 'rename sync state'
t -w moved R mv2 2>/dev/null && fail 'rename onto an existing list should fail'
t -w moved R ../x 2>/dev/null && fail 'rename to a bad name should fail'
rm -f home/.tabs
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

# sync: a fake osascript keeps each Reminders list as "title TAB done TAB due" lines.
cd "$tmp" && mkdir -p bin rem
cat >"$tmp/bin/osascript" <<'EOF'
#!/bin/sh
f="$REMDIR/$6.tsv"; touch "$f"
[ "$5" = read ] && exec cat "$f"
eval "${DURING:-}"
printf '%s\n' "$7" | awk -F '\t' -v OFS='\t' -v f="$f" '
	BEGIN { while ((getline l < f) > 0) { split(l, p, "\t"); o[++n] = p[1]; r[p[1]] = l } }
	$1 == "add" { o[++n] = $2 } $1 == "del" { delete r[$2]; next } { r[$2] = $2 OFS $3 OFS $4 }
	END { for (i = 1; i <= n; i++) if (o[i] in r) { print r[o[i]]; delete r[o[i]] } }' >"$f.new"
mv "$f.new" "$f"
EOF
chmod +x "$tmp/bin/osascript"
sy() { REMDIR="$tmp/rem" PATH="$tmp/bin:$PATH" sh "$T" -w sy sync >/dev/null; }
eq() { [ "$(cat "$1")" = "$(printf -- "$2")" ] || fail "$1: $(cat "$1")"; }
printf -- '- [ ] a ⏱ 1h\n- [ ] b\n  - [ ] kid\n- [ ] gone\n' >home/sy.md
sy
eq rem/sy.tsv 'a\t0\t\nb\t0\t\nb › kid\t0\t\ngone\t0\t'
# Reminders: tick a, due date on kid, new subtask under b, new task; here: delete gone, tick b.
printf 'a\t1\t\nb\t0\t\nb › kid\t0\t2026-11-02\nb › kid2\t0\t\ngone\t0\t\nnew\t0\t2026-12-01\n' >rem/sy.tsv
t -w sy d 4 >/dev/null && t -w sy x 2 >/dev/null
sy
eq home/sy.md '- [x] a ⏱ 1h\n- [x] b\n  - [ ] kid 📅 2026-11-02\n  - [ ] kid2\n- [ ] new 📅 2026-12-01'
eq rem/sy.tsv 'a\t1\t\nb\t1\t\nb › kid\t0\t2026-11-02\nb › kid2\t0\t\nnew\t0\t2026-12-01'
# Deleting b in Reminders takes its subtasks here; a second sync changes nothing.
printf 'a\t1\t\nb › kid\t0\t2026-11-02\nb › kid2\t0\t\nnew\t0\t2026-12-01\n' >rem/sy.tsv
sy && sy
eq home/sy.md '- [x] a ⏱ 1h\n- [ ] new 📅 2026-12-01'
eq rem/sy.tsv 'a\t1\t\nnew\t0\t2026-12-01'
# An edit made while Reminders is being updated survives; the next sync catches up.
t -w sy x 2 >/dev/null
DURING='printf -- "- [ ] mid\n" >>"$TODONE_HOME/sy.md"' REMDIR="$tmp/rem" PATH="$tmp/bin:$PATH" sh "$T" -w sy sync >/dev/null 2>&1 && fail 'edit during sync should be kept'
has home/sy.md '- [ ] mid'
sy
eq rem/sy.tsv 'a\t1\t\nnew\t1\t2026-12-01\nmid\t0\t'
# sync all: every synced list, minus deleted ones (which Reminders must not bring back).
printf -- '- [ ] z\n' >home/sy2.md
REMDIR="$tmp/rem" PATH="$tmp/bin:$PATH" sh "$T" -w sy2 sync >/dev/null
printf 'a\t0\t\n' >rem/sy.tsv
t -w sy2 D >/dev/null
REMDIR="$tmp/rem" PATH="$tmp/bin:$PATH" sh "$T" sync all >/dev/null
has home/sy.md '- [ ] a ⏱ 1h'
[ ! -e home/sy2.md ] && [ ! -e home/.sync/sy2.tsv ] || fail 'sync all brought back a deleted list'

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
# R on home renames the selected list.
keys 0 R '\025' 'hi\n' q | pty sh "$T" >/dev/null 2>&1 || true
has "$TODONE_HOME/hi.md" '- [ ] hello'
grep -qx hi "$TODONE_HOME/.tabs" || fail 'home R should rename the tab'
keys 0 R '\025' 'fresh\n' q | pty sh "$T" >/dev/null 2>&1 || true
grep -qx fresh "$TODONE_HOME/.tabs" || fail 'new list should get a tab'
# D on home deletes the selected list (the only one here).
keys 0 D q | pty sh "$T" >/dev/null 2>&1 || true
[ ! -e "$TODONE_HOME/fresh.md" ] || fail 'home D'
echo ok
