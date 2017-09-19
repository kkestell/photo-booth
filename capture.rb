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
    take_photo
  end
end

loop do
  command = gets.strip
  take_photos if command == 'capture'
end
