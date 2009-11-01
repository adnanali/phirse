class Main
  get '/*' do
    slug = params[:splat].join('/')
    # get content using slug
    @content = Content.find_by_slug(slug)
    erb :"#{content_view(@content.ctype, 'show')}", :locals => {:content => @content}
  end
end
