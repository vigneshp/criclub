class FbController < ApplicationController
  def show
     if current_facebook_user # never true initially
        @fb_id = current_facebook_user.id
            
         #newton = Facebooker2::Rails::Controller.new
       #cookiehash = newton.fb_set_cookie(nil,nil,nil)
        current_facebook_user.fetch
        @fb_email = current_facebook_user.email
        @fb_name = current_facebook_user.first_name
        @fb_friends = current_facebook_user.friends
        @fb_likes = current_facebook_user.likes
        @fb_statuses = current_facebook_user.posts

        @access_token = current_facebook_client.access_token
        current_facebook_client.post("#{current_facebook_user.id}/feed","Post",:message => "Hello World!!!!!!");
      #  @new_post = Mogli::Post.new(:name => "Hello World!!",:message => "Testing..")
       # current_facebook_user.feed_create(@newpost)
        #current_facebook_user.
        @fb_last_status = @fb_statuses.last.message
        #@fb_mobile  = @fb_status

        friends
        best_status
    end # if current_facebook_user ends here
  
  end #show method ends here

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
    @most_likes_message = ""

    @fb_statuses.each do |i|
      next if i.likes.nil?
         if !i.likes["count"].nil? && i.likes["count"] > @most_likes
           @most_likes = i.likes["count"]
           @most_likes_message = i.message
         end
    end
  end

end #class ends here


