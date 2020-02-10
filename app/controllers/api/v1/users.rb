# frozen_string_literal: true

module API
  module V1
    class Users < API::V1::Base
      include API::Defaults

      resource :users do
        desc 'Get a user profile',
             headers: {
               'Authorization' => { description: 'Authorization Header', required: true }
             }
        get '/:id' do
          @user = User.find(params[:id])
          respond(200, {id: @user.id, email: @user.email, followers: @user.followers, followings: @user.followings})
        end

        desc 'Get tweets from users one follows',
             headers: {
               'Authorization' => { description: 'Authorization Header', required: true }
             }
        get '/:id/tweets' do
          user = User.find(params[:id])
          followings_ids = user.followings.pluck(:id)
          @tweets = Tweet.where(user_id: followings_ids)
        end

        desc 'Follow a user',
             headers: {
               'Authorization' => { description: 'Authorization Header', required: true }
             }
        params do
          requires :follower_id, type: Integer, desc: 'Follower User Id'

        end
        post '/:id/follow' do
          user = User.find(params[:id])
          respond_error(422, 'Already following') if user.followers.pluck(:id).include?(params[:follower_id])
          follow = Follow.new(follower_id: params[:follower_id], followed_user_id: params[:id])
          if follow.save
            respond(200, 'Following successfully')
          else
            respond_error(422)
          end
        end

        desc 'Unfollow a user',
             headers: {
               'Authorization' => { description: 'Authorization Header', required: true }
             }
        params do
          requires :follower_id, type: Integer, desc: 'Follower User Id'

        end
        post '/:id/unfollow' do
          user = User.find(params[:id])
          respond_error(422, 'Not following') unless user.followers.pluck(:id).include?(params[:follower_id])
          follow = Follow.find(follower_id: params[:follower_id], followed_user_id: params[:id])
          if follow.destroy
            respond(204)
          else
            respond_error(422)
          end
        end

      end
    end        
  end
end
