class CommentsController < ApplicationController
  before_filter :global_vars 

  def global_vars
    @app_id = "138505499545847"
    @app_secret = "703cb69c29c98ce621e01ee7b3c23e17"
    @app_url =  "http://apps.facebook.com/vickipedia"
    @redirect_url = "http://localhost:3000/"
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
        #     logger.info("create inside..............................." + params[:code])
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

        #  logger.info("create inside..............................." + params[:code])
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
   
    if(!session[:at])
      redirect_to "/comments/session_login" and return
    end
    logger.info("entered index :) ...." + session[:at])
    begin
      user = Mogli::User.find("me",Mogli::Client.new(session[:at]))
    rescue Mogli::Client::OAuthException => exc
      logger.error("Message for the log file #{exc.message}")
      session[:at]=nil;
      redirect_to(:action => 'index') and return

    end
    @user = user
    logger.info("iiiiiindex.............ha ha")
    unless User.exists?(:extra2 => @user.id)
      User.create(:name => @user.name ,:access_token => session[:at] , :email => @user.name , :extra1 => @user.square_image_url, :extra2 => @user.id)
     
    end
  
    @comments = Comment.find(:all, :order =>'created_at' , :limit => 20)

    if @comments.nil?
      @last_comment_time =0;
      @first_comment_time =0;
    else
      @last_comment_time=@comments.last.created_at;
      @first_comment_time = @comments.first.created_at ;
    end
    #  logger.info(@last_comment_time)
    #  logger.info(@first_comment_time)
    
    #logger.info(@last_comment.created_at.to_s);
    
    respond_to do |format|
      format.html # index.html.erb
      format.rss
    end
  end
  
  def create
    @tempuser = User.where(:extra2 => params[:comment][:user_id])

    ## CHECK FOR BLOCKED TIME AND CURRENT TIME ##
    if @tempuser.first.blocked == "1" #and @tempuser.first.blocked_time+@tempuser.first.blocked_period  <
      #blocked users
      flash[:notice] = "sorry you have been blocked" and return
    else
      if params[:comment][:content].lstrip.rstrip == ""
        flash[:notice] = "No Blank commenting"
      else
        if Comment.find(:first , :conditions => ["user_id = ?",params[:comment][:user_id]] , :order => 'created_at desc').content == params[:comment][:content].lstrip.rstrip
          flash[:notice] = "Your Last comment was also same"
      else
        @comment = Comment.create!(:content => params[:comment][:content].lstrip.rstrip , :user_id => params[:comment][:user_id])
        @user = Mogli::User.find("me",Mogli::Client.new(session[:at]))
        # @user_id = (User.where(:extra2 => params[:comment][:user_id])).first.name
        # logger.info(@user1.first.name+"////////////////////////////");
        #logger.info("--------------------------")
        flash[:notice] = "Thanks for commenting!"
      end
      end
    end

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


  #add we should not take the comments posted by him coz it ll already be present there
  def update
    logger.info(params[:comment][:last_time])
    @user = Mogli::User.find("me",Mogli::Client.new(session[:at]))
    if params[:comment][:last_time]== "0"
      @comments = Comment.find(:all,:conditions => ["user_id != ?",@user.id] ,:order =>'created_at' , :limit => 20)
      logger.info("last_comment_time")
      if @comments.nil?
        @last_comment_time = "0";
        logger.info(@last_comment_time)
      else
        @last_comment_time=@comments.last.created_at;
        logger.info(@last_comment_time)
      end
      logger.info("|||||||||||||||||||")
    else
      @last_time = Time.parse(params[:comment][:last_time])
      logger.info(@last_time)
      logger.info("++++++++++")
      #   @comments = Comment.all

      ## SORT BY CREATEDAT ##
      #@comments = Comment.where('created_at > ?',@last_time)
      @comments = Comment.find(:all, :conditions => ["created_at > ? and user_id != ?",@last_time,@user.id] ,:order => 'created_at')
      @last_comment_time = @comments.last.created_at
    end
    respond_to do |format|
      format.html { redirect_to comments_path }
      format.js
    end
  end

  def more
    logger.info(params[:comment][:first_time])
    @user = Mogli::User.find("me",Mogli::Client.new(session[:at]))
    if params[:comment][:first_time]== "0"
      @comments = Comment.find(:all,:conditions => ["user_id != ?",@user.id] ,:order =>'created_at desc' , :limit => 20)
      logger.info("first_comment_time")
      if @comments.nil?
        @first_comment_time = "0";
        logger.info(@first_comment_time)
      else
        @first_comment_time=@comments.first.created_at;
        logger.info(@first_comment_time)
      end

      logger.info("|||||||||||||||||||")
    else
      @last_time = Time.parse(params[:comment][:first_time])
      logger.info(@first_time)
      logger.info("++++++++++")
      #   @comments = Comment.all

      ## SORT IN REVERSE ##
      #@comments = Comment.where('created_at < ?',@last_time)
      @comments = Comment.find(:all, :conditions => ["created_at < ? and user_id != ?",@first_time,@user.id] ,:order => 'created_at desc' ,:limit => 20)
      @last_comment_time = @comments.first.created_at
    end
    
    respond_to do |format|
      format.html { redirect_to comments_path }
      format.js
    end
  end

 
end
