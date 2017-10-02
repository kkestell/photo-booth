require 'rubyserial'

PUBLIC = File.join(File.dirname(__FILE__), 'public')
PHOTOS = File.join(File.dirname(__FILE__), 'photos')

$serial = Serial.new("/dev/#{`ls /dev | grep ttyUSB`.strip}")
sleep(1)

def generate_filename
  "#{Time.now.to_i}.jpg"
end

def gphoto_command(filename)
  "gphoto2 --capture-image-and-download --keep --keep-raw --filename #{File.join(PHOTOS, filename)}"
end

def thumbnail_command(filename, output, width, quality)
  "epeg -w #{width} -p -q #{quality} #{File.join(PHOTOS, filename)} #{File.join(PUBLIC, output)}"
end

def command(cmd, async: true)
  puts cmd
  pid = spawn(cmd)
  async ? Process.detach(pid) : Process.wait(pid)
end

def take_photo
  filename = generate_filename
  command(gphoto_command(filename), async: false)
  command(thumbnail_command(filename, File.join('thumbnails', filename), 860, 60))
  command(thumbnail_command(filename, filename, 2560, 80))
end

command('timeout 60s raspivid -o - -b 600000 -g 10 -t 0 -n -w 640 -h 480 -fps 30 --flush | gst-launch-1.0 -v fdsrc ! h264parse ! rtph264pay config-interval=10 pt=96 ! udpsink host=10.0.0.2 port=5006')

# Long countdown (10 seconds)
$serial.write('0')
sleep(10)
take_photo

# Short countdown
$serial.write('1')
sleep(3)
take_photo

# Short countdown
$serial.write('1')
sleep(3)
take_photo
