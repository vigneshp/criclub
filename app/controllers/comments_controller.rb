class CommentsController < ApplicationController
  before_filter :global_vars 

  def global_vars
   @app_id = "138505499545847"
   @app_secret = "703cb69c29c98ce621e01ee7b3c23e17"
   @app_url =  "http://apps.facebook.com/vickipedia"
   @redirect_url = "http://localhost:3000/comments/"
  # @redirect_url = "http://sociopath.railsplayground.net/session/create"
   @perms = "read_stream"
   @authorize_url = "https://www.facebook.com/dialog/oauth?client_id=138505499545847&redirect_uri=#{@redirect_url}&scope=#{@perms}&display=page"
  end

def session_login
    logger.info("Inside session login..........")
    session[:at]=nil
    respond_to do |format|
      format.html # index.html.erb
      format.rss
    end    
end 

def session_new
    logger.info("inside session_new")
    session[:at]=nil
    render :controller => "comment", :action => "session_login" and return
end

def session_authenticator
    
    @authenticator ||= Mogli::Authenticator.new(@app_id,
                                         @app_secret,
                                         @redirect_url)
end

def session_create
    #session[:at] = nil
    if params[:code].nil? and session[:at].nil?
    # logger.info("hello............." )
     session_new
    else
    if !session[:at].nil?
     return #  index #     render :controller=>"comment" , :action => "index"
    else
    logger.info("create inside..............................." + params[:code])
    mogli_client = Mogli::Client.create_from_code_and_authenticator(params[:code],session_authenticator)
    logger.info("inside creae")
    session[:at]=mogli_client.access_token
    @access_tok = session[:at]
    logger.info("inside creae.............." + session[:at])
     #index
    end
    end
end 

def index
    #session[:at]=nil
    logger.info("index..............")
    #session_create
    if params[:code].nil? and session[:at].nil?
    # logger.info("hello............." )
    session[:at]=nil
    render :controller => "comment", :action => "session_login" and return
  else
    if session[:at].nil?
      #  index #     render :controller=>"comment" , :action => "index"

      logger.info("create inside..............................." + params[:code])
      mogli_client = Mogli::Client.create_from_code_and_authenticator(params[:code],session_authenticator)
      logger.info("inside creae")
      session[:at]=mogli_client.access_token
      @access_tok = session[:at]
      logger.info("inside creae.............." + session[:at])
      #index
      redirect_to @app_url and return
    end
  end
  #session_create   
    logger.info("iiiiiindex.............")
   if(!session[:at])
    redirect_to "/comments/session_login" and return
   end
    logger.info("entered index :) ...." + session[:at])
    user = Mogli::User.find("me",Mogli::Client.new(session[:at]))
    @user = user
   @comments = Comment.all
    respond_to do |format|
      format.html # index.html.erb
      format.rss
    end
end
  
def create
    @comment = Comment.create!(params[:comment])
    flash[:notice] = "Thanks for commenting!"
    respond_to do |format|
      format.html { redirect_to comments_path }
      format.js 
    end
end
  
def destroy
     @comment = Comment.find(params[:id])
     @comment.destroy
     respond_to do |format|
       format.html { redirect_to comments_path }
       format.js 
     end
   end
  
end
