class UsersController < ApplicationController
	before_action :find_user

  def show
  end

  def follow
  	if current_user.followings.include?(@user)
  		flash[:alert] = 'Already following'
  	else
  		Follow.create(follower_id: current_user.id, followed_user_id: @user.id)
  		flash[:notice] = "Now you are following #{@user.email}"
  	end
  	render :show
    #redirect_to show_user_path(@user.id)
  end

  private

  def find_user
  	@user = User.find(params[:user_id])
  end
end
