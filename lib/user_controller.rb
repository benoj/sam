require 'sinatra/base'
require 'models/user'
require 'models/user_request'
require 'rfc822'
require 'bcrypt'
require 'slim'

module Sam
  module User

    class Users < Sinatra::Base

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
        hashed_password =  BCrypt::Password.create(params['password'])
        email = params['email']
        if Model::User.count == 0
          Model::User.create(email: email, password: hashed_password,user_type: :administrator)
        else
          Model::UserRequest.create(email: email,password: hashed_password)
        end
      end
    end

    class Login < Sinatra::Base

      get '/' do
        success_url = URI(params['success'] || '/pages' ).path
        slim :login, locals: {login_failed: false, redirect_url: success_url}
      end

      post '/' do
        user = Sam::Model::User.where(email: params['email']).first
        if user and BCrypt::Password.new(user.password) == params['password']
          session[:user] = { email: user.email, type: user.user_type}
          redirect params['url']
        else
          slim :login, locals: {login_failed: true, redirect_url: params['url']}
        end
      end



    end
  end
end