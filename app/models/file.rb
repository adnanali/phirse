class FileUpload
  include MongoMapper::Document

  key :user_id, String
  key :filename, String
  key :content_type, String

  belongs_to :user
end
