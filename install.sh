if [ ! -t 1 ]; then
  # not running in a tty, so start a terminal emulator and run this script inside it
  exec xterm -e "$0" "$@"
fi
