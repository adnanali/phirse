class Main
  get '/' do
    @contents = Content.all(:conditions => {:ctype => ["post"], :public => true}, :order => 'published_at desc', :limit => 5)

    #content = Content.create({:title => "hello"})
    #content.save
    erb :index
  end

  get '/texts/?' do 
    @texts = Content.all(:conditions => {:ctype => ["text"], :public => true}, :order => 'published_at desc')

    erb :'content/text'
  end

  get '/archives/?' do 
    @texts = Content.all(:conditions => {:ctype => ["post"], :public => true}, :order => 'published_at desc')

    erb :'content/text'
  end

  get '/requests/?' do 
    @requests = Content.all(:conditions => {:ctype => ["request"], :public => true}, :order => 'published_at desc')

    erb :'content/requests'
  end
end
