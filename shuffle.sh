#!/usr/bin/env bash
# The Playlist Shuffler: your playlist in a new order every time.
# Run it as:
#   ./shuffle.sh            every song, shuffled
#   ./shuffle.sh chill      only one mood's songs, shuffled
#   ./shuffle.sh --pick     one song, picked at random
#   ./shuffle.sh --moods    how many minutes of music each mood has
#
# The songs are in playlist.txt, and the functions this script uses are in lib/playlist.sh.
# Seven jobs: job 1 is in this file, jobs 2 to 7 are in lib/playlist.sh.

# 1. Keep the folder this script is saved in, in a variable called here. Use dirname and
#    ${BASH_SOURCE[0]}, so the shuffler finds its library and its playlist from any folder.


source "$here/lib/playlist.sh"
load_songs "$here/playlist.txt"

# Done for you: prints the songs in a random order, numbered from 1.
# Given a mood, such as chill, it prints only that mood's songs.
shuffle_songs() {
  local mood=$1
  local order=() i j swap n
  # The slot numbers of the songs to play, in playlist order.
  for i in "${!titles[@]}"; do
    if [[ $mood == "" || ${moods[$i]} == "$mood" ]]; then
      order+=("$i")
    fi
  done
  # Shuffle them: from the last slot down to the second, swap each with a random slot
  # at or before it. Every order is equally likely.
  i=$(( ${#order[@]} - 1 ))
  while [[ $i -gt 0 ]]; do
    j=$((RANDOM % (i + 1)))
    swap=${order[$i]}
    order[$i]=${order[$j]}
    order[$j]=$swap
    i=$((i - 1))
  done
  # Print them, numbered.
  n=0
  for i in "${order[@]}"; do
    n=$((n + 1))
    echo "$n. $(describe_song "$i")"
  done
}

case $1 in
  --pick)
    pick_song
    ;;
  --moods)
    mood_minutes
    ;;
  "")
    shuffle_songs
    echo "$(song_count) songs, $(total_minutes) minutes"
    ;;
  *)
    if has_mood "$1"; then
      shuffle_songs "$1"
    else
      echo "No $1 songs in the playlist."
      exit 1
    fi
    ;;
esac
