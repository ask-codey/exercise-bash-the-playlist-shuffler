#!/usr/bin/env bats
# Checks your Playlist Shuffler (shuffle.sh and lib/playlist.sh) by running it for real.
# Each check copies the shuffler into a throwaway folder with a test playlist of its own, then
# runs the app, or loads the library and calls one function. Nothing in this folder is changed,
# and your own playlist.txt is never read.
# Run it from this folder with:  bats check.bats
# You don't need to change this file.

setup() {
  cd "$BATS_TEST_DIRNAME"
  app="$BATS_TEST_TMPDIR/app"
  lib="$app/lib/playlist.sh"
  mkdir -p "$app/lib"
  [[ -f shuffle.sh ]] && cp shuffle.sh "$app/shuffle.sh"
  [[ -f lib/playlist.sh ]] && cp lib/playlist.sh "$lib"
  # The test playlist: 8 songs, 34 minutes, with a note line and a blank line to skip.
  printf '%s\n' '# The test playlist.' 'chill 4 Highway Tea' 'upbeat 3 Paper Lanterns' \
    'chill 5 Window Down' 'upbeat 4 Gas Station Sunrise' '' 'singalong 5 Rainy Tuesday' \
    'chill 6 Last Exit Waltz' 'upbeat 3 Home by Dark' 'singalong 4 All the Way to the Coast' \
    > "$app/playlist.txt"
  songs=(
    "Highway Tea (4 min, chill)" "Paper Lanterns (3 min, upbeat)" "Window Down (5 min, chill)"
    "Gas Station Sunrise (4 min, upbeat)" "Rainy Tuesday (5 min, singalong)"
    "Last Exit Waltz (6 min, chill)" "Home by Dark (3 min, upbeat)"
    "All the Way to the Coast (4 min, singalong)"
  )
}

# Loads the library in a new bash, loads the test playlist, then runs the code given.
with_songs() {
  bash -c "source '$lib' && load_songs '$app/playlist.txt' && $1" 2>&1
}

# Runs the shuffler from the root folder, by its full path, with the arguments given.
shuffle() {
  (cd / && bash "$app/shuffle.sh" "$@") 2>&1
}

# Fails with a hint when the shuffler can't find its library yet.
need_library() {
  if [[ "$output" == *"No such file"* ]]; then
    echo "shuffle.sh can't find lib/playlist.sh yet, so it can't play anything. Finish job 1 first. It printed:"
    echo "$output" | head -n 2
    return 1
  fi
}

# Is this line one of the test playlist's songs, as describe_song prints them?
is_song() {
  local s
  for s in "${songs[@]}"; do
    [[ "$1" == "$s" ]] && return 0
  done
  return 1
}

@test "shuffle.sh and lib/playlist.sh are here, and bash can read them" {
  for f in shuffle.sh lib/playlist.sh; do
    if [[ ! -f "$f" ]]; then
      echo "$f is missing. Download the exercise again to get it back."
      return 1
    fi
    if ! errors="$(bash -n "$f" 2>&1)"; then
      echo "bash can't read $f. Its first error:"
      echo "$errors" | head -n 1
      echo "Look at the line it names: a quote or a { that's opened and never closed is the usual cause."
      return 1
    fi
  done
}

@test "1) shuffle.sh finds its library and playlist from any folder" {
  if ! grep -qE '^[^#]*BASH_SOURCE' shuffle.sh; then
    echo "shuffle.sh doesn't use \${BASH_SOURCE[0]} yet. Job 1: here=\$(dirname \"\${BASH_SOURCE[0]}\")"
    return 1
  fi
  output="$(shuffle --moods)" || true
  if [[ "$output" == *"No such file"* ]]; then
    echo "Run from another folder, shuffle.sh couldn't find a file. It printed:"
    echo "$output" | head -n 2
    echo "Job 1: here must be the folder shuffle.sh is saved in, from dirname and \${BASH_SOURCE[0]}."
    return 1
  fi
}

@test "2) load_songs fills the three arrays, skipping the note and the blank line" {
  output="$(with_songs 'echo "${#titles[@]} ${#minutes[@]} ${#moods[@]}"')" || true
  if [[ "$output" != "8 8 8" ]]; then
    echo "After load_songs, the test playlist's 8 songs should be in each array, but the counts of titles, minutes and moods are: $output"
    echo "Job 2: add each line's three parts with titles+=(\"\$title\"), and skip a line whose first word is empty or starts with #, with continue."
    echo "Read the minutes into length, not minutes: minutes is the array's own name."
    return 1
  fi
  output="$(with_songs 'echo "${titles[0]}|${minutes[0]}|${moods[0]}"; echo "${titles[7]}|${minutes[7]}|${moods[7]}"')" || true
  if [[ "$output" != $'Highway Tea|4|chill\nAll the Way to the Coast|4|singalong' ]]; then
    echo "The first and last songs should be Highway Tea, 4, chill and All the Way to the Coast, 4, singalong, but they came out as:"
    echo "$output"
    echo "Job 2: read -r mood length title puts the first word in mood, the second in length, and the rest of the line in title."
    return 1
  fi
}

@test "3) song_count prints how many songs there are" {
  output="$(with_songs 'song_count')" || true
  if [[ "$output" != "8" ]]; then
    echo "With the test playlist's 8 songs, song_count should print 8, but it printed: $output"
    echo "Job 3: \${#titles[@]} is how many items the titles array holds."
    return 1
  fi
}

@test "4) total_minutes adds up every song's minutes, with its variables kept local" {
  output="$(with_songs 'total_minutes')" || true
  if [[ "$output" != "34" ]]; then
    echo "The test playlist's songs add up to 34 minutes, but total_minutes printed: $output"
    echo "Job 4: start a local sum at 0, add each of \"\${minutes[@]}\" with \$(( )), and echo it after the loop."
    return 1
  fi
  output="$(with_songs 'compgen -v | sort > "'"$BATS_TEST_TMPDIR"'/before"; total_minutes > /dev/null; compgen -v | sort > "'"$BATS_TEST_TMPDIR"'/after"; comm -13 "'"$BATS_TEST_TMPDIR"'/before" "'"$BATS_TEST_TMPDIR"'/after" | tr "\n" " "')" || true
  if [[ -n "${output// /}" ]]; then
    echo "After total_minutes ran, the script had a new variable it didn't have before: $output"
    echo "Job 4: make it local, as in local sum=0 m, so the function can't change the script's variables."
    return 1
  fi
}

@test "5) has_mood answers yes for a mood in the playlist, and no for one that isn't" {
  output="$(with_songs 'has_mood chill && echo yes || echo no; has_mood party && echo yes || echo no; has_mood Chill && echo yes || echo no')" || true
  if [[ "$output" != $'yes\nno\nno' ]]; then
    echo "has_mood chill should answer yes, and has_mood party and has_mood Chill no. It answered:"
    echo "$output"
    echo "Job 5: loop over \"\${moods[@]}\", return 0 as soon as one matches, and return 1 after the loop."
    return 1
  fi
  status=0
  output="$(shuffle party)" || status=$?
  need_library
  if [[ "$output" != "No party songs in the playlist." || $status -ne 1 ]]; then
    echo "./shuffle.sh party should say \"No party songs in the playlist.\" and stop with exit code 1. It printed: $output"
    return 1
  fi
}

@test "6) pick_song picks one song at random" {
  output="$(with_songs 'for n in {1..40}; do pick_song; done')" || true
  local line picks=() count
  while IFS= read -r line; do
    if ! is_song "$line"; then
      echo "pick_song should print one song as describe_song prints it, such as \"Highway Tea (4 min, chill)\", but it printed: $line"
      echo "Job 6: pick a slot number with \$((RANDOM % \${#titles[@]})), then describe_song \"\$pick\"."
      return 1
    fi
    picks+=("$line")
  done <<< "$output"
  if [[ ${#picks[@]} -ne 40 ]]; then
    echo "Called 40 times, pick_song should print 40 lines, but it printed ${#picks[@]}."
    echo "Job 6: pick_song prints one song each time, with describe_song."
    return 1
  fi
  count="$(printf '%s\n' "${picks[@]}" | sort -u | wc -l)"
  if [[ $count -lt 3 ]]; then
    echo "In 40 picks, pick_song chose only $count of the 8 songs. It should pick at random."
    echo "Job 6: \$RANDOM is a new number each time; % \${#titles[@]} turns it into a slot number."
    return 1
  fi
}

@test "7) mood_minutes adds up each mood's minutes, sorted by mood" {
  if ! grep -qE '^[^#]*declare -A' lib/playlist.sh; then
    echo "lib/playlist.sh doesn't make an associative array yet. Job 7: declare -A total"
    return 1
  fi
  output="$(with_songs 'mood_minutes')" || true
  if [[ "$output" != $'chill: 15 minutes\nsingalong: 9 minutes\nupbeat: 10 minutes' ]]; then
    echo "With the test playlist, mood_minutes should print chill: 15 minutes, singalong: 9 minutes and upbeat: 10 minutes, in that order. It printed:"
    echo "$output"
    echo "Job 7: add each song's minutes to total[\$mood] with \$(( )), then loop over \"\${!total[@]}\" and pipe the loop to sort."
    return 1
  fi
  printf '%s\n' 'workout 7 Stairs at Dawn' 'workout 8 One More Lap' 'chill 4 Highway Tea' >> "$app/playlist.txt"
  output="$(with_songs 'mood_minutes')" || true
  if [[ "$output" != $'chill: 19 minutes\nsingalong: 9 minutes\nupbeat: 10 minutes\nworkout: 15 minutes' ]]; then
    echo "With three more songs, two of them a new mood, workout, mood_minutes printed:"
    echo "$output"
    echo "Job 7: the moods must come from the playlist, never from a list written into the function."
    return 1
  fi
}

@test "the whole shuffler plays every song once, numbered, in a new order each time" {
  local run line n orders=()
  for run in 1 2 3 4 5 6; do
    output="$(shuffle)" || true
    need_library
    n=0
    while IFS= read -r line; do
      n=$((n + 1))
      if [[ $n -le 8 ]]; then
        if [[ "$line" != "$n. "* ]] || ! is_song "${line#"$n. "}"; then
          echo "Line $n of ./shuffle.sh should be a numbered song, such as \"$n. Highway Tea (4 min, chill)\", but it is: $line"
          return 1
        fi
      fi
    done <<< "$output"
    if [[ $n -ne 9 || "$(printf '%s\n' "$output" | head -n 8 | cut -d' ' -f2- | sort -u | wc -l)" -ne 8 ]]; then
      echo "./shuffle.sh should print each of the 8 songs once, then a total line. It printed:"
      echo "$output"
      return 1
    fi
    if [[ "$(printf '%s\n' "$output" | tail -n 1)" != "8 songs, 34 minutes" ]]; then
      echo "The last line of ./shuffle.sh should be \"8 songs, 34 minutes\", but it is: $(printf '%s\n' "$output" | tail -n 1)"
      echo "That line uses song_count and total_minutes (jobs 3 and 4)."
      return 1
    fi
    orders+=("$(printf '%s\n' "$output" | head -n 8 | tr '\n' '|')")
  done
  if [[ "$(printf '%s\n' "${orders[@]}" | sort -u | wc -l)" -lt 2 ]]; then
    echo "Six runs of ./shuffle.sh played the songs in the same order every time. The shuffle is done for you in shuffle.sh: check that it's still there."
    return 1
  fi
}

@test "the whole shuffler plays only one mood's songs when given a mood" {
  output="$(shuffle chill)" || true
  need_library
  if [[ "$(printf '%s\n' "$output" | wc -l)" -ne 3 || "$output" == *"upbeat"* || "$output" == *"singalong"* ]]; then
    echo "./shuffle.sh chill should play the test playlist's 3 chill songs and nothing else. It printed:"
    echo "$output"
    echo "Jobs 2 and 5: the moods array and has_mood decide which songs are played."
    return 1
  fi
}
