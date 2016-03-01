if File.exist?(Rails.root.join("controllers/application_controller"))
  require "application_controller"
end

class SessionsController < (defined?(ApplicationController) ? ApplicationController : ActionController::Base)
  before_action :destroy_session, except: :create

  # GET /login
  # GET /sign-in
  def new
    @session = Challah::Session.new(request)
  end

  # POST /login
  # POST /sign-in
  def create
    @session = Challah::Session.new(request, params[:session])
    @session.ip = request.remote_ip

    if @session.save
      redirect_to return_to_path
    else
      redirect_to signin_path, alert: I18n.translate('sessions.create.failed_login')
    end
  end

  # GET /logout
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
