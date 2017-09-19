require 'json'
require 'sinatra'

PUBLIC = File.join(Dir.pwd, 'public')
PHOTOS = File.join(Dir.pwd, 'photos')

set :bind, '0.0.0.0'

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

get '/photos/:filename/prints' do
  `sh #{Dir.pwd}/print.sh #{File.join(PHOTOS, params['filename'])} &`
end
