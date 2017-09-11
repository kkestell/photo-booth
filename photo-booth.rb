require 'curses'

include Curses

init_screen
noecho
nodelay = true

$buffer = []

def debug(str)
  $buffer.push(str)
  $buffer.shift if $buffer.length >= lines
  clear
  l = 0
  $buffer.each do |line|
    setpos(l, 0)
    addstr(line)
    l = l + 1
  end
  refresh
end

def gphoto_command
  "gphoto2 --capture-image-and-download --keep --keep-raw --filename library/photos/#{Time.now.to_i}.jpg"
end

def take_photo
  cmd = gphoto_command
  debug(cmd)
  `#{cmd}`
end

def take_photos
  3.times do
    take_photo
    sleep(3)
  end
  debug('done')
end

begin
  loop do
    take_photos if getch == ' '
  end
ensure
  close_screen
end
