require 'maruku'

class Main
  helpers do
  include Rack::Utils
  alias_method :h, :escape_html

    def root_url
      @root_url ||= settings(:root_url)
    end

    def markdown(text)
      Maruku.new(text).to_html
    end

    def content_view(content, view)
      type = content.is_a?(String) ? content : content.ctype;
      "../content_types/#{type}/views/#{view}"
    end
    def gfm(text)
      # Extract pre blocks
      extractions = {}
      text.gsub!(%r{<pre>.*?</pre>}m) do |match|
        md5 = Digest::MD5.hexdigest(match)
        extractions[md5] = match
        "{gfm-extraction-#{md5}}"
      end 

      # prevent foo_bar_baz from ending up with an italic word in the middle
      text.gsub!(/(^(?! {4}|\t)\w+_\w+_\w[\w_]*)/) do |x| 
        x.gsub('_', '\_') if x.split('').sort.to_s[0..1] == '__'
      end 

      # in very clear cases, let newlines become <br /> tags
      text.gsub!(/^[\w\<][^\n]*\n+/) do |x| 
        x =~ /\n{2}/ ? x : (x.strip!; x << "  \n")
      end 

      # Insert pre block extractions
      text.gsub!(/\{gfm-extraction-([0-9a-f]{32})\}/) do
        "\n\n" + extractions[$1]
      end 

      text  
    end 

      # Your helpers go here. You can also create another file in app/helpers with the same format.
      # All helpers defined here will be available across all the application.
      #
      # @example A helper method for date formatting.
      #
      #   def format_date(date, format = "%d/%m/%Y")
      #     date.strftime(format)
      #   end
  end
end
