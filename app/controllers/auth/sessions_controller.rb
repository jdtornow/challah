class Auth::SessionsController < ApplicationController
  before_filter :destroy_session, :except => :create
  
  unloadable
  
  # GET /sign-in
  def new
    @session = Auth::Session.new(request)
  end
  
  # POST /sign-in
  def create
    @session = Auth::Session.new(request, params[:session])
    @session.ip = request.remote_ip
    
    if @session.save
      redirect_to return_to_path(@session.default_path)
    else
      redirect_to signin_path, :alert => I18n.translate('auth.sessions.create.failed_sign_in')
    end
  end
  
  # GET /sign-out
  def destroy
    redirect_to signin_path
  end
  
  protected
    def destroy_session
      current_user_session.destroy
    end
  
    def return_to_path(default_path = '/')
      result = session[:return_to]      
      result = nil if result and result == "http://#{request.domain}/"
      result || default_path
    end
end