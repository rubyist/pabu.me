require 'sinatra'
require 'face'

set :public_folder, File.dirname(__FILE__) + '/static'

post '/pabufy' do
  client = Face.get_client(:api_key => ENV['FACE_KEY'], :api_secret => ENV['FACE_SECRET'])
  data = client.faces_detect(:urls => [params[:url]])

  pic_data = data['photos'][0]
  pic_width = pic_data['width']
  pic_height = pic_data['height']

  head_width = pic_data['tags'][0]['width'] * (pic_width/100)
  head_height = pic_data['tags'][0]['height'] * (pic_height/100)

  nose_x = pic_data['tags'][0]['nose']['x'] * (pic_width/100)
  nose_y = pic_data['tags'][0]['nose']['y'] * (pic_height/100)

  pabu_height = [head_height * 2, pic_height - nose_y].min

  pabu_scale = pabu_height / 270.0
  pabu_width = (550 * pabu_scale).to_i
  pabu_height = pabu_height.to_i

  pabu_x = (nose_x - (pabu_width * 0.25)).to_i
  pabu_y = nose_y.to_i

  pabu_geometry = '%+d%+d' % [pabu_x, pabu_y]

  "convert -size #{pic_width}x#{pic_height} [[src]] null: \\( op.gif -resize #{pabu_width}x#{pabu_height} -coalesce \\) -geometry #{pabu_geometry}  -layers Composite [[dst]]"
end
