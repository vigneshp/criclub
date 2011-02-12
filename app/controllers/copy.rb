class FbController < ApplicationController
  def show
   if current_facebook_user # never true
         @fb_id = current_facebook_user.id
         current_facebook_user.fetch
        @fb_email = current_facebook_user.email
        @fb_name = current_facebook_user.first_name
    end

  end

end
