require 'mongo/gridfs'

class Main
  # content 
  get '/content/?' do
    @contents = Content.all
    erb :'content/index'
  end

  post '/content/upload/?' do
    file_upload = FileUpload.create(:user_id => current_user.id, :filename => params['Filedata'][:filename], :content_type => params['Filedata'][:type])
    file = "file_#{file_upload.id}"
    GridFS::GridStore.open(MongoMapper.database, file , 'w') { |f|
      f.write params['Filedata'][:tempfile].read
    }
    file_upload.id
  end

  get '/content/download/:id/?' do
    # check if file exists
    file_upload = FileUpload.find(params[:id])
    halt unless file_upload

    file = "#{ROOT_DIR}/tmp/#{params[:id]}#{File.extname(file_upload.filename)}"

    unless File.exist?(file) 
      f = File.new(file, "w")
      GridFS::GridStore.open(MongoMapper.database, "file_#{file_upload.id}", 'r') { |ff| f.write ff.read }
      f.close
    end
    send_file file, {:filename => file_upload.filename}
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
