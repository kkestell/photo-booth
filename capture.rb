require 'rubyserial'

$serial = Serial.new("/dev/#{`ls /dev | grep ttyUSB`.strip}")

def generate_filename
  "#{Time.now.to_i}.jpg"
end

def gphoto_command(filename)
  "gphoto2 --capture-image-and-download --keep --keep-raw --filename photos/#{filename}"
end

def thumbnail_command(filename, output, width, quality)
  "epeg -w #{width} -p -q #{quality} photos/#{filename} public/#{output}"
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

def take_photos
  3.times do
    $serial.write('0')
    sleep(3)
    take_photo
  end
end

loop do
  take_photos if $serial.read == '0'
end
