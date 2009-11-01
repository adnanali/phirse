class Content
  include MongoMapper::Document

  key :ctype, String, :required => true

  key :title, String, :required => true
  key :slug, String

  key :content, Hash
  key :body, String

  key :published_at, Time
  key :user_id, String
  key :public, Boolean

  validate :unique_slug

  timestamps!

  before_validation :req_custom
  before_validation :customize
  before_validation :slugify
  before_save :set_published_date

  belongs_to :user

  protected

  def unique_slug
    return unless self['public']
    u = Content.find_by_slug(self['slug'])
    puts "Slug: '#{self['slug']}' UNIQ: #{u.to_yaml}"
    if u
      return if not self.id.blank? and u.id == self.id 
      errors.add(:slug, 'is not unique')
    end
    
  end

  def slugify
    if self['slug'].blank?
      self['slug'] = title.downcase.gsub(/[^a-z0-9]/,'-').squeeze('-').gsub(/^\-|\-$/,'')
      #self['slug'] = "#{type}-#{self['slug']}" if type != 'post' && type != 'page'
    end
  end

  def set_published_date
    #RAILS_DEFAULT_LOGGER.info self['public'].type
    puts "The time is now:"
    puts Time.now
    self['published_at'] = Time.now if self['public'] and self['published_at'].blank?
  end

  def req_custom
    require "#{ROOT_DIR}/app/content_types/#{self['ctype']}/lib/customize.rb"
  end

  def customize
    pre_customize
  end 

end
