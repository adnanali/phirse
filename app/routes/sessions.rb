require 'openid'
require 'openid/extensions/sreg'
require 'openid/extensions/pape'
require 'openid/store/filesystem'

class Main
  get '/login' do
    erb :login
  end

  post '/login' do
    begin
      identifier = params[:openid_identifier]
      if identifier.nil?
        flash[:error] = "Enter an OpenID identifier"
        redirect '/login'
        return
      end
      oidreq = consumer.begin(identifier)
    rescue OpenID::OpenIDError => e
      flash[:error] = "Discovery failed for #{identifier}: #{e}"
      redirect '/login'
      return
    end

    #if params[:use_sreg]
      sregreq = OpenID::SReg::Request.new
      # required fields
      sregreq.request_fields(['email', 'nickname'], true)
      # optional fields
      # sregreq.request_fields(['dob', 'fullname'], false)
      oidreq.add_extension(sregreq)
      oidreq.return_to_args['did_sreg'] = 'y'
    #end
    if params[:use_pape]
      papereq = OpenID::PAPE::Request.new
      papereq.add_policy_uri(OpenID::PAPE::AUTH_PHISHING_RESISTANT)
      papereq.max_auth_age = 2*60*60
      oidreq.add_extension(papereq)
      oidreq.return_to_args['did_pape'] = 'y'
    end
    if params[:force_post]
      oidreq.return_to_args['force_post']='x'*2048
    end
    return_to = root_url + 'complete_openid'
    realm = root_url

    if oidreq.send_redirect?(realm, return_to, params[:immediate])
      redirect oidreq.redirect_url(realm, return_to, params[:immediate])
    else
      render :text => oidreq.html_markup(realm, return_to, params[:immediate], {'id' => 'openid_form'})
    end
  end

  get '/complete_openid' do
    # FIXME - url_for some action is not necessarily the current URL.
    current_url = root_url + 'complete_openid'
    parameters = params #.reject{|k, v|request.path_parameters[k]}
    oidresp = consumer.complete(parameters, current_url)
    case oidresp.status
      when OpenID::Consumer::FAILURE
        if oidresp.display_identifier
          flash[:error] = ("Verification of #{oidresp.display_identifier}"\
                         " failed: #{oidresp.message}")
        else
          flash[:error] = "Verification failed: #{oidresp.message}"
        end
      when OpenID::Consumer::SUCCESS
        flash[:success] = ("Verification of #{oidresp.display_identifier}"\
                         " succeeded.")
          sreg_resp = OpenID::SReg::Response.from_success_response(oidresp)
          sreg_message = "Simple Registration data was requested"
          if sreg_resp.empty?
            sreg_message << ", but none was returned."
          else
            sreg_message << ". The following data were sent:"
            sreg_resp.data.each {|k, v|
              sreg_message << "<br/><b>#{k}</b>: #{v}"
            }
          end
          flash[:sreg_results] = sreg_message
        if params[:did_pape]
          pape_resp = OpenID::PAPE::Response.from_success_response(oidresp)
          pape_message = "A phishing resistant authentication method was requested"
          if pape_resp.auth_policies.member? OpenID::PAPE::AUTH_PHISHING_RESISTANT
            pape_message << ", and the server reported one."
          else
            pape_message << ", but the server did not report one."
          end
          if pape_resp.auth_time
            pape_message << "<br><b>Authentication time:</b> #{pape_resp.auth_time} seconds"
          end
          if pape_resp.nist_auth_level
            pape_message << "<br><b>NIST Auth Level:</b> #{pape_resp.nist_auth_level}"
          end
          flash[:pape_results] = pape_message
        end

        # hey, we should do the login here

        # first let's see if the user is created already

        openid_identity = params[:openid1_claimed_id] || params['openid.identity']
        @user = User.find_by_open_id(openid_identity)

        unless @user
          # create the user
          @user = User.create(:open_id => openid_identity,
            :display_name => params['openid.sreg.nickname'] || "no username",
            :email => params['openid.sreg.email'] || "no email",
            :utype => "user"
          )
        end

        session[:user_id] = @user.id

        flash[:success] = "It worked! You're in."
        if @user.display_name == 'no username'
          @user.display_name = @user.id
          @user.save
          flash[:success] = "#{flash[:success]} BUT, we need to enter a nickname, and if you need us to get in touch with you, please leave an email address as well."
          # FIX
          redirect "/user/#{@user.id}/edit"
          return true
        end  
        if session[:return_to]
          redirect session[:return_to]
          session[:return_to] = nil
          return true
        end
      
      when OpenID::Consumer::SETUP_NEEDED
        flash[:alert] = "Immediate request failed - Setup Needed"
      when OpenID::Consumer::CANCEL
        flash[:alert] = "OpenID transaction cancelled."
      else
    end
    redirect root_url
  end

  get '/logout' do
    session[:user_id] = nil
    flash[:success] = "You have been logged out"
    redirect '/'
  end

  def consumer
    if @consumer.nil?
      dir = Pathname.new(ROOT_DIR).join('db').join('cstore')
      store = OpenID::Store::Filesystem.new(dir)
      @consumer = OpenID::Consumer.new(session, store)
    end
    return @consumer
  end
end
