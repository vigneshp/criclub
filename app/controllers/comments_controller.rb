class CommentsController < ApplicationController
  # GET /comments
  # GET /comments.xml
=begin
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

  def session_new
    session[:at]=nil
    render :controller => 'session' , :action => 'login'
    #redirect_to authenticator.authorize_url(:scope => 'publish_stream,offline_access,email,friends_about_me', :display => 'page')
  end

  def session_create
    #session[:at] = nil
    if params[:code].nil? and session[:at].nil?
    # logger.info("hello............." )
     session_new
    else
    if !session[:at].nil?
           index
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
=end
  def index
  #  session_create
    @comments = Comment.all
    redirect_to "/session/login" and return unless session[:at]
    logger.info("entered index :) ...." + session[:at])
    user = Mogli::User.find("me",Mogli::Client.new(session[:at]))
    @user = user
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @comments }
    end

   end


  # GET /comments/1
  # GET /comments/1.xml
  def show
    @comment = Comment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @comment }
    end
  end

  # GET /comments/new
  # GET /comments/new.xml
  def new
    @comment = Comment.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @comment }
    end
  end

  # GET /comments/1/edit
  def edit
    @comment = Comment.find(params[:id])
  end

  # POST /comments
  # POST /comments.xml
  def create
    @comment = Comment.new(params[:comment])

    respond_to do |format|
      if @comment.save
       format.html { redirect_to :controller => "session" , :action => "create" }
       format.js
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /comments/1
  # PUT /comments/1.xml
  def update
    @comment = Comment.find(params[:id])

    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        format.html { redirect_to(@comment, :notice => 'Comment was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.xml
  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to(comments_url) }
      format.xml  { head :ok }
    end
  end
end
