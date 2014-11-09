$LOAD_PATH.unshift("#{__dir__}/lib")
require 'sinatra/base'
require 'mongoid'
require 'assets_controller'
require 'admin_controller'
require 'user_controller'

Mongoid.load!("mongoid.yml")


use Rack::Session::Cookie, :key => 'rack.session', :path => '/', :secret => "#{ENV['SECRET']}"


map '/' do
  run Sam::Assets::App
end

map '/admin' do
  run Sam::Admin::App
end

map '/users' do
  run Sam::User::Users
end

map '/login' do
  run Sam::User::Login
end


