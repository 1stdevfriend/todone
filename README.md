# todone

A tiny todo list for the macOS terminal. One POSIX `sh` file, no dependencies.
Tasks are plain Markdown checkboxes (`- [ ] task`), so you can read and edit them anywhere.

## Install

```sh
brew install 1stdevfriend/tap/todone
echo "alias t=todone" >> ~/.zshrc
```

Or without Homebrew:

```sh
mkdir -p ~/.local/bin
curl -fsSL https://raw.githubusercontent.com/1stdevfriend/todone/main/todone -o ~/.local/bin/todone
chmod +x ~/.local/bin/todone
echo "alias t=todone" >> ~/.zshrc
```

Make sure `~/.local/bin` is on your `PATH`. macOS only for now.

The tab bar uses a powerline arrow, which needs a Nerd Font or Powerline font. Without one, set `TODONE_SEP=''` (or any character, e.g. `TODONE_SEP='>'`).

## Where tasks live

- **Per directory, automatically:** in `~/repos/blog`, `t` opens the list `blog`, kept in `~/.todone/blog.md`. In `$HOME` it is `inbox`.
- **In the repo:** `t init` creates `./TODO.md` (moving in that directory's existing list, if any); from then on that directory and its subdirectories use it, the way git finds `.git`. Commit it if you want.
- **Any list from anywhere:** `t -w inbox n "call mum"`.

Set `TODONE_HOME` to move `~/.todone`.

## TUI

Run `t` with no arguments. Every list you open becomes a tab in the bottom bar.

| key | action |
|-----|--------|
| `j` `k` / arrows, `g` `G` | move, top, bottom |
| `n` | new task |
| `A` | add many: one task per line, empty line or Esc ends (pasting works) |
| `e` | edit, prefilled with the current text |
| `x` / space | tick / untick |
| `d` | delete (no prompt; `z` brings it back) |
| `z` | undo, as many steps as you like (per session; refuses if the file was changed outside todone) |
| `/` | fuzzy-find a task |
| `s` | fuzzy-open a list with live preview; type a new name to create one |
| `1`–`9`, `Tab` / `Shift-Tab` | jump to a tab, cycle tabs |
| `c` | close tab |
| `E` | open the list in `$EDITOR` |
| `?` | help |
| `q` | quit |

In text boxes: Enter saves, Esc cancels, Backspace, Ctrl-U clears, Ctrl-W deletes a word.

**Mouse:** click a tab to switch, a task to select it, its ○/✓ to tick it, and a selected task again to edit it. The key hints above the tab bar are buttons. In pickers, click a result to open it or click outside to close. The wheel scrolls. While the TUI is open, select text with Shift-drag (Option-drag in iTerm2 / Terminal.app).

## Commands

The same actions as one-shot commands, for scripts and quick capture:

```sh
t n "write the report"   # new
t l                      # list (plain `t` lists too when piped)
t x 1                    # tick / untick
t e 1 "write the draft"  # edit (t e alone opens $EDITOR)
t d 1                    # delete
t s                      # show all lists
```

## Test

```sh
sh test.sh
```

## License

GPL-3.0. You can use, change and share todone; if you distribute a modified version, you must release its source under the GPL too. See [LICENSE](LICENSE).
