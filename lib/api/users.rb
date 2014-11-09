require 'sinatra/base'
require 'models/user'
require 'models/user_request'
require 'rfc822'
require 'bcrypt'

module Sam
  module API
    class Users < Sinatra::Base
      set(:valid_email) { |value| condition { value == params['email'].is_email? } }
      set(:valid_password) { |value| condition { value == (params['password'] == params['confirm_password']) } }
      set(:user_exists) { |value| condition { value == Model::User.where(email: params['email']).exists? } }

      post '/', valid_password: false do
        halt(400, 'Passwords do not match')
      end

      post '/', valid_email: false do
        halt(400, "#{params['email']} is not a valid email address")
      end


      post '/', user_exists: true do
        halt(400, 'The email supplied is already in use')
      end

      post '/' do
        hashed_password = BCrypt::Password.create(params['password'])
        email = params['email']
        if Model::User.count == 0
          Model::User.create(email: email, password: hashed_password, user_type: :administrator)
        else
          Model::UserRequest.create(email: email, password: hashed_password)
        end
      end
    end
  end
end
