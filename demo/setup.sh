# Sourced by demo.tape: a throwaway home with a few lists, so recording never touches real data.
export PATH="$PWD:$PATH" HOME=/tmp/todone-demo TODONE_HOME=/tmp/todone-demo/.todone
rm -rf /tmp/todone-demo
mkdir -p "$TODONE_HOME" "$HOME/repos/website"
d() { date -v"$1"d +%F; }
printf -- '- [ ] Write the about page ⏱ 2h 📅 %s ⏳ 40m\n  - [x] Outline sections\n  - [ ] Draft the copy ⏱ 1h\n- [x] Pick a font pair\n- [ ] Set up analytics ⏱ 30m 📅 %s\n' "$(d +2)" "$(d -1)" >"$TODONE_HOME/website.md"
printf -- '- [ ] Call the dentist 📅 %s\n- [ ] Renew passport 📅 %s\n' "$(d +0)" "$(d +9)" >"$TODONE_HOME/inbox.md"
printf -- '- [ ] Outline post on tiny tools ⏱ 1h 📅 %s\n- [x] Draft intro\n- [ ] Find cover photo\n' "$(d +5)" >"$TODONE_HOME/blog.md"
printf 'website\ninbox\n' >"$TODONE_HOME/.tabs"
unset -f d
alias t=todone
cd "$HOME/repos/website"
PS1='\[\e[38;5;150m\]~/repos/website\[\e[0m\] $ '
