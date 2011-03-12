require "cgi"
class SessionController < CommentsController

  before_filter :global_vars 

  def global_vars
   @app_id = "138505499545847"
   @app_secret = "703cb69c29c98ce621e01ee7b3c23e17"
   @app_url =  "http://apps.facebook.com/vickipedia"
   @redirect_url = "http://localhost:3000/session/create/"
  # @redirect_url = "http://sociopath.railsplayground.net/session/create"
   @perms = "read_stream"
   @authorize_url = "https://www.facebook.com/dialog/oauth?client_id=138505499545847&redirect_uri=#{@redirect_url}&scope=#{@perms}&display=page"
  end
  
  def new
    session[:at]=nil
    render :controller => 'session' , :action => 'login'
    #redirect_to authenticator.authorize_url(:scope => 'publish_stream,offline_access,email,friends_about_me', :display => 'page')
  end

  def create
    #session[:at] = nil
    if params[:code].nil? and session[:at].nil?
    # logger.info("hello............." )
     new
    else
    if !session[:at].nil?
      index #     render :controller=>"comment" , :action => "index"
    else
    logger.info("create inside..............................." + params[:code])
    mogli_client = Mogli::Client.create_from_code_and_authenticator(params[:code],authenticator)
    logger.info("inside creae")
    session[:at]=mogli_client.access_token
    @access_tok = session[:at]
    logger.info("inside creae.............." + session[:at])

    redirect_to @app_url
    #index
    end
    end
  end

=begin
def index
    redirect_to "/session/login" and return unless session[:at]
    logger.info("entered index :) ...." + session[:at])
    user = Mogli::User.find("me",Mogli::Client.new(session[:at]))
    @user = user
    @fb_statuses = user.posts
    @fb_friends =  user.friends
    friends
    best_status
    
    logger.info("Vetriii :) ...." + session[:at])
   # @current_facebook_user = User.find_or_create_by_facebook_id(@access_tok , :name => @user , :email => @user.email)
   #redirect_to "http://apps.facebook.com/criclub"
   # redirect_to :controller => :fb , :action => :show
    session[:at] = nil
  end
=end


  def most_liked_post
    return if @most_likes <= 0
    i = @most_likes_post
    if i.type == "status"
      "status:" + i.message
    elsif i.type == "video"
      "video:" + i.source
    elsif i.type == "picture"
      "picture:" + i.link
    elsif i.type == "link"
      "link:" + i.link
    elsif !i.message.nil?
      i.message
    else
      "post created at:" + i.created_time
    end
    
  end

   def friends
    if @fb_friends.nil?
      return
    end
       @count = 0
       @maxlength = 0
       @maxname = "me"
       @fb_friends.each do |i|
            #i = @fb_friends[2]
            #i.fetch
            @count = @count + 1
             if i.name.length > @maxlength
                @maxname = i.name
                @maxlength = i.name.length
            end

       end
  end

   def best_status
    if @fb_statuses.nil?
      return
    end
    @most_likes = 0
    @most_likes_message = nil

    @fb_statuses.each do |i|
      next if i.likes.nil?
         if !i.likes["count"].nil? && i.likes["count"] > @most_likes
           @most_likes = i.likes["count"]
           @most_likes_post = i
           @most_likes_type = i.type
           @most_liked_post = most_liked_post
         end
    end
  end

  def authenticator
    
    @authenticator ||= Mogli::Authenticator.new(@app_id,
                                         @app_secret,
                                         @redirect_url)
  end



  def login
    session[:at]=nil
  end

  def logout
  end

end
