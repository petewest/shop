module SessionsHelper
  def sign_in(user, remember_forever=false)
    #hybrid auth section, will store user id in a session variable and a remmeber token in the db if the user ticked "remember"
    #this way we can use the session variable if it's there, or populate from the db if not
    #to give us a way to have persistent and semi-persistent sessions
    remember_token = Session.new_remember_token
    #Create a new session for this user
    this_session=user.sessions.new(ip_addr: request.remote_ip.to_s, remember_token: Session.encrypt(remember_token))
    return nil unless this_session.save
    if remember_forever
      #If we're to remember this user forever then store the permanent token in a cookie
      cookies.permanent[:remember_token] = remember_token
    else
      #Otherwise we'll just store it for this session
      session[:remember_token]=remember_token
    end
    self.current_user=user
  end
  
  def current_user=(user)
    @current_user=user
  end

  def signed_in?
    !current_user.nil?
  end
  
  def current_user
    @current_user||=current_session.try(:user)
  end
  
  def current_user?(user)
    user==current_user
  end

  def current_session
    if @current_session.nil?
      if session[:remember_token]
        self.current_session=Session.find_by(remember_token: Session.encrypt(session[:remember_token]))
        #In case the login session has been cleared from another login, we'll remove the token
        #from the session if we're still nil at this point
        session.delete(:remember_token) if @current_session.nil?
      elsif cookies[:remember_token]
        self.current_session=Session.find_by(remember_token: Session.encrypt(cookies[:remember_token]))
        cookies.delete(:remember_token) if @current_session.nil?
      end
      #Refresh the timestamp if it's over an hour old
      @current_session.touch if @current_session and @current_session.updated_at<1.hour.ago
    end
    @current_session
  end

  def current_session=(new_session)
    @current_session=new_session
  end
  
  def current_session?(session_check)
    session_check==current_session
  end
  
  #Sign out
  def sign_out
    current_session.destroy
    self.current_session=nil
    #Remove current_user
    self.current_user=nil
    #Tidy up any session vars or cookies
    session.delete(:remember_token) if session[:remember_token]
    cookies.delete(:remember_token) if cookies[:remember_token]
  end
  
  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end
  def store_location
    session[:return_to] = request.url if request.get?
  end
  
  def signed_in_user
    unless signed_in?
      store_location
      redirect_to signin_url, notice: "Please sign in."
    end
  end
end
