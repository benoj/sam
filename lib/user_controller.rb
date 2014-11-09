require 'sinatra/base'
require 'models/user'
require 'slim'

module Sam
  module User
    class Login < Sinatra::Base

      get '/' do
        success_url = URI(params['success'] || '/pages').path
        slim :login, locals: {login_failed: false, redirect_url: success_url}
      end

      post '/' do
        user = Sam::Model::User.where(email: params['email']).first
        if user and BCrypt::Password.new(user.password) == params['password']
          session[:user] = {email: user.email, type: user.user_type}
          redirect params['url']
        else
          slim :login, locals: {login_failed: true, redirect_url: params['url']}
        end
      end
    end
  end
end