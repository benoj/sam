$LOAD_PATH.unshift("#{__dir__}/lib")
require 'sinatra/base'
require 'mongoid'
require 'assets_controller'
require 'admin_controller'
require 'user_controller'
require 'api/users'

Mongoid.load!("mongoid.yml")


use Rack::Session::Cookie, :key => 'rack.session', :path => '/', :secret => "#{ENV['SECRET']}"


map '/' do
  run Sam::Assets::App
end

map '/admin' do
  run Sam::Admin::App
end

map '/api/users' do
  run Sam::API::Users
end

map '/login' do
  run Sam::User::Login
end


