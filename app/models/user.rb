class User < ActiveRecord::Base
  attr_accessible :email, :password, :username, :valid_token, :token_rotation_count, :created_at
end
