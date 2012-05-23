class Document
  include MongoMapper::Document
  key :url, String
  key :image_width, Integer
  key :image_height, Integer
  key :pabu_width, Integer
  key :pabu_height, Integer
  key :pabu_x, Integer
  key :pabu_y, Integer
  key :faces, Boolean
end