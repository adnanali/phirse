class Main
  get '/user/?' do
    @users = User.all
    erb :'user/index'
  end

  get '/user/:id' do
    @user = User.find(params[:id])
    erb :'user/show'
  end

  post '/user/:id' do
    self_logged?(params[:id]) or need_admin

    content_type('text/javascript', :charset => 'utf-8');
    @user = User.find(params[:id])
    @user.update_attributes(params[:user])
    erb :"user/update.js", :locals => {:user => @user}, :layout => false
  end

  get '/user/:id/edit' do
    self_logged?(params[:id]) or need_admin

    @user = User.find(params[:id])
    erb :'user/edit', :locals => {:user => @user}
  end
end
