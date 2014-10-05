require 'sinatra/base'
require 'models/user'
require 'models/user_request'
require 'rfc822'

module Sam
  module User
    class App < Sinatra::Base

      set(:valid_email) { |value| condition { value == params['email'].is_email? } }
      set(:valid_password) { |value| condition {  value == (params['password'] == params['confirm_password']) }}
      set(:user_exists) { |value| condition {  value == Model::User.where(email: params['email']).exists? } }

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
        if Model::User.count == 0
          Model::User.create(email: params['email'],
                             password: params['password'],
                             user_type: :administrator)
        else
          Model::UserRequest.create(email: params['email'],
                                    password: params['password'])
        end
      end

    end
  end
end