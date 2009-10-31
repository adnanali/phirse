class Article
  include MongoMapper::Document

  unique_id :slug

  key :date, Date # or Time
  key :slug, String
  key :title, String
  key :tags, Array

  timestamps!

  before_save :generate_slug_from_title
  validates_uniqueness_of :slug

  def generate_slug_from_title
    self['slug'] = title.downcase.gsub(/[^a-z0-9]/,'-').squeeze('-').gsub(/^\-|\-$/,'') if new?
  end
end
