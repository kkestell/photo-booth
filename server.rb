#!/usr/bin/ruby

require 'json'
require 'sinatra'

PUBLIC = File.join(File.dirname(__FILE__), 'public')
PHOTOS = File.join(File.dirname(__FILE__), 'photos')

set :bind, '0.0.0.0'

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

get '/photos/:filename/prints' do
  `sh #{File.dirname(__FILE__)}/print.sh #{File.join(PHOTOS, params['filename'])} &`
end
