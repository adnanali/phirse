class User
  include MongoMapper::Document

  key :utype, String, :required => true

  key :display_name, String, :required => true
  key :name, String

  key :email, String
  key :open_id, String, :required => true

  many :contents

  timestamps!

  before_validation :set_type
  validates_uniqueness_of :display_name

  protected
  def set_type
    self['utype'] = 'user' if self['utype'].blank?
  end

end
