# Render with: vhs demo/demo.tape  (from the repo root)
Output demo/demo.gif
Output demo/demo.mp4

Set Shell "bash"
Set FontFamily "JetBrainsMono Nerd Font Mono"
Set FontSize 20
Set Width 1280
Set Height 760
Set Padding 24
Set Theme "Catppuccin Mocha"
Set TypingSpeed 55ms

# Only the full-screen app is recorded; the sample tasks are added off camera.
Hide
Type "source demo/setup.sh" Enter
Type "t n 'Write launch post' && t due 6 fri && t est 6 1h30m" Enter
Type "clear && t" Enter
Sleep 1.5s
Show

# The list view: subtasks, due dates, estimates
Sleep 1.5s
Screenshot demo/list.png
Type "j" Sleep 400ms Type "j" Sleep 400ms Type "x" Sleep 1.2s
Type "G" Sleep 600ms Type "a" Sleep 700ms Type "Write the post body" Sleep 400ms Enter Sleep 1.2s
Type "h" Sleep 700ms Type "45m" Sleep 400ms Enter Sleep 1.2s
Type "N" Sleep 700ms
Type "Compress hero image" Enter Sleep 400ms
Type "Add RSS feed" Enter Sleep 400ms
Enter Sleep 1s
Type "t" Sleep 700ms Type "tom" Sleep 400ms Enter Sleep 1.2s
Type "e" Sleep 900ms Type " and Atom" Sleep 400ms Enter Sleep 1.2s
Type "d" Sleep 1.2s Type "z" Sleep 1.5s

# Focus on one task: the time spent is recorded on it
Type "g" Sleep 600ms Type "p" Sleep 3s
Screenshot demo/focus.png
Space Sleep 2.5s Space Sleep 1.5s
Escape Sleep 1.5s

# Calendar of everything due, across lists
Type "C" Sleep 1.5s
Screenshot demo/calendar.png
Type "l" Sleep 600ms Type "l" Sleep 600ms Type "l" Sleep 1s Type "t" Sleep 1s
Escape Sleep 1.2s

# Home: every list at a glance
Type "0" Sleep 1.5s
Screenshot demo/home.png
Sleep 1s

# Fuzzy-open another list with a live preview, hop tabs
Type "s" Sleep 900ms Type "blo" Sleep 1.8s Enter Sleep 1.5s
Tab Sleep 1s Tab Sleep 1.2s

Type "?" Sleep 3s Type " " Sleep 800ms
Type "q" Sleep 1s
