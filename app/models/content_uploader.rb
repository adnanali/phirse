require 'carrierwave'
class ContentUploader < CarrierWave::Uploader::Base
  storage :file
end
