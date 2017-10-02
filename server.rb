require 'json'
require 'sinatra'

PUBLIC = File.join(File.dirname(__FILE__), 'public')
PHOTOS = File.join(File.dirname(__FILE__), 'photos')

set :bind, '0.0.0.0'

def command(cmd, async: true)
  puts cmd
  pid = spawn(cmd)
  async ? Process.detach(pid) : Process.wait(pid)
end

post '/photos' do
  `/usr/bin/ruby #{File.join(File.dirname(__FILE__), 'capture.rb')}`
end

get '/photos' do
  content_type :json
  Dir[File.join(PHOTOS, "*.jpg")].sort.reverse.map { |f|
    {
      filename: File.basename(f),
      thumbnail: File.join("thumbnails", File.basename(f))
    }
  }.to_json
end

get '/photos/:filename' do
  send_file open(File.join(PUBLIC, params['filename'])),
    type: 'image/jpeg',
    disposition: 'inline'
end

get '/photos/thumbnails/:filename' do
  send_file open(File.join(PUBLIC, File.join('thumbnails', params['filename']))),
    type: 'image/jpeg',
    disposition: 'inline'
end

post '/photos/:filename/prints' do
  command("/bin/sh #{File.dirname(__FILE__)}/print.sh #{File.join(PHOTOS, params['filename'])}")
end
