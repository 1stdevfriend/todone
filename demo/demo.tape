# Render with: vhs demo/demo.tape  (from the repo root)
Output demo/demo.gif
Output demo/demo.mp4

Set Shell "bash"
Set FontFamily "JetBrainsMono Nerd Font Mono"
Set FontSize 20
Set Width 1280
Set Height 720
Set Padding 24
Set Theme "Catppuccin Mocha"
Set TypingSpeed 55ms

Hide
Type "source demo/setup.sh" Enter
Type "clear" Enter
Show

# Quick capture from the shell: the list is named after the folder
Type "t n 'Write launch post'" Sleep 400ms Enter Sleep 1.2s
Type "t l" Sleep 300ms Enter Sleep 2s

# The TUI
Type "t" Enter Sleep 2s
Type "j" Sleep 400ms Type "j" Sleep 400ms Type "x" Sleep 1.2s
Type "n" Sleep 700ms Type "Fix footer links" Sleep 400ms Enter Sleep 1.2s
Type "N" Sleep 700ms
Type "Compress hero image" Enter Sleep 400ms
Type "Add RSS feed" Enter Sleep 400ms
Type "Check mobile nav" Enter Sleep 400ms
Enter Sleep 1.2s
Type "e" Sleep 900ms Type " on Safari" Sleep 400ms Enter Sleep 1.2s
Type "k" Sleep 400ms Type "d" Sleep 1.2s Type "z" Sleep 1.5s
Type "/" Sleep 700ms Type "rss" Sleep 1.2s Enter Sleep 1.2s

# Fuzzy-open another list with a live preview, then hop between tabs
Type "s" Sleep 900ms Type "blo" Sleep 1.8s Enter Sleep 1.5s
Tab Sleep 1.2s Tab Sleep 1.2s Type "1" Sleep 1.5s

Type "?" Sleep 3s Type " " Sleep 800ms
Type "q" Sleep 1s
