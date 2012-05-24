$: << File.expand_path('../../lib', __FILE__)

require 'bundler'
Bundler.require


if ENV['RACK_ENV']
  mongo_url = "mongodb://#{ENV['MONGO_USER']}:#{ENV['MONGO_PASS']}@staff.mongohq.com:10051/app4788146"
else
  mongo_url = "mongodb://localhost:27017/pabume-#{ENV['RACK_ENV'] || 'development'}"
end
uri = URI.parse(mongo_url)
database = uri.path.gsub('/', '')
MongoMapper.connection = Mongo::Connection.new(uri.host, uri.port, {})
MongoMapper.database = database
if uri.user.present? && uri.password.present?
  MongoMapper.database.authenticate(uri.user, uri.password)
end

require 'document'
require 'find_faces'
require 'pabufy'

#include Magick

set :public_folder, Pathname(File.expand_path('../..', __FILE__) + '/static')

get '/' do
  erb :index
end

post '/pabuplan' do
  document = Document.create!(:url => params[:url], :faces => false)
  Qu.enqueue(FindFaces, document.id)
  document.id.to_s
end

get '/planstatus/:id' do
  document = Document.find(params[:id])
  if document.faces
    content_type 'application/json'
    document.to_json
  else
    'false'
  end
end

post '/pabufy'  do
  document = Document.find(params[:id])
  # update document with desired position and sizes
  Qu.enqueue(Pabufy, document.id)
  document.id.to_s
end

get '/pabufystatus/:id' do
  document = Document.find(params[:id])
  if document.pabufied
    content_type 'application/json'
    document.to_json
  else
    'false'
  end
end

get '/pabufied/:id' do
  document = Document.find(params[:id])
  content_type 'image/gif'
  document.image.as_json['str']
end

