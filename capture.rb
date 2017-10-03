require 'rubyserial'

LOG = File.join(File.join(File.dirname(__FILE__), 'logs'), 'photo-booth.log')
PUBLIC = File.join(File.dirname(__FILE__), 'public')
PHOTOS = File.join(File.dirname(__FILE__), 'photos')

puts 'Enumerating serial devices'

$serial = Serial.new("/dev/#{`ls /dev | grep ttyUSB`.strip}")
sleep(1)

puts 'Serial communication initialized'

def start_preview
  cmd = 'raspivid -o - -i 10 -b 600000 -t 0 -n -w 640 -h 480 -fps 30 --flush | gst-launch-1.0 -v fdsrc ! h264parse ! rtph264pay config-interval=10 pt=96 ! udpsink host=10.0.0.2 port=5006'
  $preview_pid = spawn(cmd, out: [LOG, 'a'])
  Process.detach($preview_pid)
end

def end_preview
  Process.kill($preview_pid)
end

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
  pid = spawn(cmd, out: [LOG, 'a'])
  async ? Process.detach(pid) : Process.wait(pid)
end

def take_photo
  filename = generate_filename
  command(gphoto_command(filename), async: false)
  command(thumbnail_command(filename, File.join('thumbnails', filename), 860, 60))
  command(thumbnail_command(filename, filename, 2560, 80))
end

puts 'Starting preview stream'
start_preview

puts 'Playing introduction'
$serial.write('0')
sleep(10)

puts 'Taking first photo'
$serial.write('1')
sleep(5)
take_photo
sleep(3)

puts 'Taking second photo'
$serial.write('2')
sleep(4)
take_photo
sleep(3)

puts 'Taking third photo'
$serial.write('2')
sleep(4)
take_photo
sleep(5)

puts 'Ending preview stream'
end_preview
