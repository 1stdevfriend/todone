# Sourced by demo.tape: a throwaway home with a few lists, so recording never touches real data.
export PATH="$PWD:$PATH" HOME=/tmp/todone-demo TODONE_HOME=/tmp/todone-demo/.todone
rm -rf /tmp/todone-demo
mkdir -p "$TODONE_HOME" "$HOME/repos/website"
printf -- '- [ ] Write the about page\n- [x] Pick a font pair\n- [ ] Set up analytics\n' >"$TODONE_HOME/website.md"
printf -- '- [ ] Call the dentist\n- [ ] Renew passport\n' >"$TODONE_HOME/inbox.md"
printf -- '- [ ] Outline post on tiny tools\n- [x] Draft intro\n- [ ] Find cover photo\n' >"$TODONE_HOME/blog.md"
printf 'website\ninbox\n' >"$TODONE_HOME/.tabs"
alias t=todone
cd "$HOME/repos/website"
PS1='\[\e[38;5;150m\]~/repos/website\[\e[0m\] $ '
