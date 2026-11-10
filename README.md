# Exercise: The Playlist Shuffler

Exercise code for the lesson **Exercise: The Playlist Shuffler** in Bash in Depth on [ask-codey.com](https://www.ask-codey.com).

Finish a small application in two files: `shuffle.sh` plays your playlist in a new order every time, picks one song at random, or plays only one mood's songs, and `lib/playlist.sh` is its library of functions. The shuffle itself is written for you; you write the functions around it. A check script runs your shuffler for real and tells you which jobs are done.

## Before you start

You need a terminal (the Terminal app on a Mac, Ubuntu on Linux or in WSL on Windows) and **bats**, the tool that runs the check. If `bats --version` doesn't print a version yet, install it:

```bash
sudo apt install bats       # Ubuntu, and Ubuntu in WSL
brew install bats-core      # a Mac, with Homebrew
```

The shuffler uses an associative array, which needs bash 4 or newer. On a Mac, `bash --version` should say version 5; if it says 3.2, install bash 5 with `brew install bash`.

On Windows, unzip or clone this folder inside Ubuntu, in your Linux home folder (for example `~/terminal-practice/`), so `chmod` works on it.

## What's here

- `shuffle.sh`: the app. It loads the library, reads the playlist and decides what to play. Job 1 is in it, and the shuffle is done for you.
- `lib/playlist.sh`: the library, functions only. An example is done for you, and jobs 2 to 7 are functions to finish, each with a comment saying what it does.
- `playlist.txt`: the songs, one a line: the mood, the minutes, then the title. Make it yours whenever you like.
- `check.bats`: the check. You don't need to change it.

## Run it

Open a terminal in this folder, make the app runnable, and open the files:

```bash
chmod +x shuffle.sh
nano shuffle.sh
nano lib/playlist.sh
```

Replace the `:` line in each function with your lines, save with Ctrl+O and Enter, and quit with Ctrl+X. Then try the shuffler after each job:

```bash
./shuffle.sh
./shuffle.sh chill
./shuffle.sh --pick
./shuffle.sh --moods
```

When job 1 is done, it works from any folder too: `cd ~` and run it by its full path.

## Check your work

From this folder:

```bash
bats check.bats
```

At first most checks fail: that is expected. Each job you finish turns its check into a ✓. A failing check's message says which job it is and gives a hint. The check copies your shuffler into a throwaway folder with a test playlist of its own, so your `playlist.txt` is never read or changed.

## The rules

- Keep the names the jobs give: the variable `here`, the arrays `moods`, `minutes` and `titles`, and the function names. `shuffle.sh` uses them.
- Functions answer by printing (`song_count`, `total_minutes`, `pick_song`, `mood_minutes`) or with `return` (`has_mood`), and print nothing else.
- Make every variable inside your functions local, the loop's variable too.
- Don't write the songs, the moods or any totals into the functions: everything comes from the playlist.

## Tips

- `here=$(dirname "${BASH_SOURCE[0]}")` is the folder a script is saved in.
- `while read -r mood length title` splits each line: the first word, the second, and the rest of the line.
- `titles+=("$title")` adds one item to the end of an array, and `${#titles[@]}` counts its items.
- `$((RANDOM % ${#titles[@]}))` is a random slot number, from 0 to one less than the number of songs.
- `declare -A total` makes an associative array; `total[$mood]=$(( total[$mood] + minutes[$i] ))` adds to one mood's total, and `"${!total[@]}"` is every mood in it.

## Hand it in

When it works, push your solution to a public repo of your own on GitHub, then paste that repo's address into **Submit your exercise** on the lesson page at [ask-codey.com](https://www.ask-codey.com). That's what completes the lesson. The lesson page shows the Git commands, step by step.
