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

include Magick

set :public_folder, Pathname(File.expand_path('../..', __FILE__) + '/static')

get '/' do
  erb :index
end

get '/status/:id' do
  document = Document.find(params[:id])
  if document.faces
    content_type 'application/json'
    document.to_json
  else
    'false'
  end
end


post '/pabuplan' do
  document = Document.create!(:url => params[:url], :faces => false)
  Qu.enqueue(FindFaces, document.id)
  document.id.to_s
end

post '/pabufy'  do
  # url, geometry, size
  image_data = open(params[:url], 'rb').read
  background = ImageList.new
  background.from_blob(image_data)
  background.geometry = pabu_geometry

  pabu = ImageList.new(File.dirname(__FILE__) + '/static/pabu.gif')
  pabu.each { |p| p.resize! pabu_width, pabu_height }

  comp = background.composite_layers(pabu)

  content_type 'image/gif'
  comp.format = 'gif'
  comp.to_blob
end
