require 'sinatra'
class Content 
    validate :check

    def check
      errors.add(:content_original_language, "can't be empty") if self['content']['original_language'].blank?
      errors.add(:content_author, "can't be empty") if self['content']['author'].blank?
    end

    def slugify
      if self['slug'].blank?
        self['slug'] = 'text/' + title.downcase.gsub(/[^a-z0-9]/,'-').squeeze('-').gsub(/^\-|\-$/,'')
        #self['slug'] = "#{type}-#{self['slug']}" if type != 'post' && type != 'page'
      end
    end

    def pre_customize
      #puts "SELF\n"
      #puts self.to_yaml
      #self['content'] = {:body => self.body} unless self.body.nil?
      #self.body = nil
      #self['processed_content'] = Sinatra::Erb::EventContext::erb :"#{content_view(self.type, 'show')}", :locals => {:content => self}, :layout => false
    end 

    def store_customize
      self.content[:body]
    end 
end

