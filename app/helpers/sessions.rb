class Main
  helpers do
    def current_user
      return if session[:user_id].blank?
      @current_user ||= User.find(session[:user_id])
    end

    def logged_in?
      not current_user.blank?
    end

    def need_login
      if not logged_in?
        flash[:notice] = "You need to be logged in before you can do that. No worries, go ahead and login now. It won't hurt, I promise."
        session[:return_to] = request.url
        redirect '/login'
        return false
      else
        return true
      end
    end

    def need_admin
      return true if admin?
      flash[:notice] = "Sorry mate, you need to be an admin to do that"
      redirect '/'
      return false
    end

    def self_logged?(id)
      return true if logged_in? and current_user.id == id
    end

    def admin?
      return true if logged_in? and current_user.utype == 'admin'
      return false
    end
  end
end
