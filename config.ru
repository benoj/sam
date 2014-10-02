$LOAD_PATH.unshift("#{__dir__}/lib")
require 'sinatra/base'
require 'assets_controller'
require 'admin_controller'

map '/' do
  run Sam::Assets::App
  end

map '/admin' do
  run Sam::Admin::App
end
