class Tweet < ApplicationRecord
  belongs_to :user

  def is_owned_by(current_user_id)
  	user_id == current_user_id
  end
end
