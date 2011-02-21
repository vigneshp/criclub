require "cgi"
class SessionController < ApplicationController

  #before_filter :new , :only => :create

  def new

    session[:at]=nil
    render :controller => 'session' , :action => 'login'
    #redirect_to authenticator.authorize_url(:scope => 'publish_stream,offline_access,email,friends_about_me', :display => 'page')
  end

  def create
    
    if params[:code].nil? and session[:at].nil?
     logger.info("hello............." )
     new
    else
    if !session[:at].nil?
      #redirect_to "http://apps.facebook.com/criclub"
     index
    else
    logger.info("create inside..............................." + params[:code])
    mogli_client = Mogli::Client.create_from_code_and_authenticator(params[:code],authenticator)
    logger.info("inside creae")
    session[:at]=mogli_client.access_token
    @access_tok = session[:at]
    logger.info("inside creae.............." + session[:at])
    redirect_to "http://apps.facebook.com/criclub"
    #index
    end
    end
  end

  def index
    redirect_to "/session/login" and return unless session[:at]
    logger.info("entered index :) ...." + session[:at])
    user = Mogli::User.find("me",Mogli::Client.new(session[:at]))
    @user = user
    @posts = user.posts
    logger.info("Vetriii :) ...." + session[:at])
    @current_facebook_user = User.find_or_create_by_facebook_id(@access_tok , :name => @user , :email => @user.email)
    #redirect_to "http://apps.facebook.com/criclub"
   # redirect_to :controller => :fb , :action => :show

  end

  def authenticator
    
    @authenticator ||= Mogli::Authenticator.new('138505499545847',
                                         '703cb69c29c98ce621e01ee7b3c23e17',
                                         "http://localhost:3000/session/create/")
  end

  def login
    session[:at]=nil
  end

  def logout
  end

end
