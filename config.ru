$LOAD_PATH.unshift("#{__dir__}/lib")
require 'sinatra/base'
require 'mongoid'
require 'assets_controller'
require 'admin_controller'
require 'user_controller'

Mongoid.load!("mongoid.yml")

map '/' do
  run Sam::Assets::App
  end

map '/admin' do
  run Sam::Admin::App
  end

map '/users' do
  run Sam::User::App
end
