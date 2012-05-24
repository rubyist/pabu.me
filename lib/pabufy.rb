require 'open-uri'
require 'rmagick'

class Pabufy
  def self.perform(document_id)
    document = Document.find(document_id)

    # url, geometry, size
    pabu_geometry = '%+d%+d' % [document.pabu_x, document.pabu_y]

    image_data = open(document.url, 'rb').read
    background = Magick::ImageList.new
    background.from_blob(image_data)
    background.geometry = pabu_geometry

    pabu = Magick::ImageList.new(File.dirname(__FILE__) + '/../static/images/pabu.gif')
    pabu.each { |p| p.resize! document.pabu_width, document.pabu_height }

    comp = background.composite_layers(pabu)

    comp.format = 'gif'
    document.image = comp.to_blob
    document.pabufied = true
    document.save!
  end
end