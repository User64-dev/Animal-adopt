class SessionsController < ApplicationController
  def new
    Rails.logger.info "[SessionsController#new] Rendering login page."
  end
  
  def create
    Rails.logger.info "[SessionsController#create] Attempting login."
    Rails.logger.info "[SessionsController#create] Params: #{params[:session].inspect}"
    
    username_param = params[:session][:username]
    password_param = params[:session][:password]
    Rails.logger.info "[SessionsController#create] Username from params: '#{username_param}'"

    user = User.find_by(username: username_param)
    
    if user
      Rails.logger.info "[SessionsController#create] User found: #{user.username} (ID: #{user.id})"
      if user.authenticate(password_param)
        Rails.logger.info "[SessionsController#create] User authenticated successfully."
        session[:user_id] = user.id
        Rails.logger.info "[SessionsController#create] Session[:user_id] set to: #{session[:user_id]}"
        redirect_to root_path, notice: "Logged in successfully!"
      else
        Rails.logger.info "[SessionsController#create] User authentication failed for username: '#{username_param}'."
        flash.now[:alert] = "Invalid username or password"
        render :new, status: :unprocessable_entity
      end
    else
      Rails.logger.info "[SessionsController#create] User not found with username: '#{username_param}'."
      flash.now[:alert] = "Invalid username or password"
      render :new, status: :unprocessable_entity
    end
  end
  
  def destroy
    Rails.logger.info "[SessionsController#destroy] Logging out user_id: #{session[:user_id]}"
    session[:user_id] = nil
    redirect_to root_path, notice: "Logged out successfully!"
  end
end
