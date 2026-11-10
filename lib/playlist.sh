# lib/playlist.sh: the Playlist Shuffler's library. Functions only: shuffle.sh loads this
# file with source, so it needs no #! line, and nothing in it runs by itself.
#
# Every song is kept in three arrays, in the same slot number:
#   moods=(chill upbeat ...)   minutes=(4 3 ...)   titles=("Highway Tea" "Paper Lanterns" ...)
# so ${moods[2]}, ${minutes[2]} and ${titles[2]} are all about the third song.
moods=()
minutes=()
titles=()

# Example, done for you. describe_song N prints the song in slot N (counted from 0) as one line:
#   Highway Tea (4 min, chill)
describe_song() {
  local i=$1
  echo "${titles[$i]} (${minutes[$i]} min, ${moods[$i]})"
}

# 2. load_songs FILE: read FILE line by line. Each line is a mood, the minutes, then the title:
#      chill 4 Highway Tea
#    Add each part to the end of its array with +=. Skip blank lines and lines starting with #.
#    Read the minutes into a variable called length: minutes is already the name of an array.
load_songs() {
  : # Your lines go here, in place of this one. (: does nothing.)
}

# 3. song_count: print how many songs there are, and nothing else.
song_count() {
  : # Your lines go here, in place of this one. (: does nothing.)
}

# 4. total_minutes: print every song's minutes added up, and nothing else.
#    Make every variable it uses local, the loop's variable too.
total_minutes() {
  : # Your lines go here, in place of this one. (: does nothing.)
}

# 5. has_mood MOOD: answer yes (return 0) when at least one song has that mood, and no
#    (return 1) when none has. Print nothing.
has_mood() {
  : # Your lines go here, in place of this one. (: does nothing.)
}

# 6. pick_song: print one song, picked at random with $RANDOM, as describe_song prints it.
pick_song() {
  : # Your lines go here, in place of this one. (: does nothing.)
}

# 7. mood_minutes: print the minutes of music each mood has, one line a mood, sorted by mood:
#      chill: 15 minutes
#    Add them up in an associative array made with declare -A.
mood_minutes() {
  : # Your lines go here, in place of this one. (: does nothing.)
}
