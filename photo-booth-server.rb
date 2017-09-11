require 'json'
require 'sinatra'

LIBRARY = ENV['LIBRARY'] || "#{Dir.pwd}/library"
PHOTOS = File.join(LIBRARY, 'photos')

set :public_folder, LIBRARY

get '/photos' do
  JSON.generate(Dir["#{PHOTOS}/*.jpg"].map { |f| File.basename(f) })
end

get '/photos/:filename/prints' do
  `sh #{Dir.pwd}/print.sh #{PHOTOS}/#{params['filename']} &`
end
