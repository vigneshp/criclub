class ApplicationController < ActionController::Base
 # protect_from_forgery
  include Facebooker2::Rails::Controller
  def current_user
    if session[:at]
      #@current_user ||= User.find_or_create_by_facebook_id(session[:at])
      
      @current_user ||= User.find_or_create_by_facebook_id(session[:at])
      
    #elsif current_facebook_user and @current_user.nil?
    #  @current_user = User.find_or_create_by_facebook_id(current_facebook_user.id)
    #  session[:at] = @current_user.id


    end
  end

end