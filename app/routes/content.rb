class Main
  # content 
  get '/content/?' do
    @contents = Content.all
    erb :'content/index'
  end

  get '/content/:ctype/new' do
    need_login

    # verify the type here
    @title = "New #{params[:ctype]} Content"

    erb :"#{content_view(params[:ctype], 'new')}", :locals => {:content => @content}
  end

  post '/content/create' do
    need_login
    content_type('text/javascript', :charset => 'utf-8');
    puts "Entering this"
    puts current_user.id
    @content = current_user.contents.create(params[:content])
    erb :"#{content_view(params[:content][:ctype], 'create.js')}", :locals => {:content => @content}, :layout => false
  end

  get '/content/:id' do
    @content = Content.find(params[:id])
    erb :"#{content_view(@content.ctype, 'show')}", :locals => {:content => @content}
  end

  post '/content/:id' do
    content_type('text/javascript', :charset => 'utf-8');
    # update the content
    @content = Content.find(params[:id])
    @content.update_attributes(params[:content])
    erb :"#{content_view(@content.ctype, 'update.js')}", :locals => {:content => @content}, :layout => false
  end

  get '/content/:id/edit' do
    @content = Content.find(params[:id])
    erb :"#{content_view(@content.ctype, 'edit')}", :locals => {:content => @content}
  end

end
