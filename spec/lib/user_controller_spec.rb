require 'spec_helper'
require 'user_controller'
require 'bcrypt'

describe Sam::User::Login do

  def app
    Rack::Builder.parse_file('config.ru').first
  end

  context 'GET /' do
    before do
      get('/login', {success: url})
    end

    context 'when url is supplied' do

      context 'and is relative' do
        let(:url) { '/test' }
        it 'should render form with redirect url to new url' do
          expect(last_response.body).to include "<input name=\"url\" type=\"hidden\" value=\"#{url}\" />"
        end
      end

      context 'and is full domain' do

        let(:url) { 'http://google.com/test' }
        it 'should render form with redirect url to new url path' do
          expect(last_response.body).to include "<input name=\"url\" type=\"hidden\" value=\"/test\" />"
        end
      end

    end

    context 'when url is not supplied' do

      let(:url) { nil }
      it 'should render form with default url' do
        expect(last_response.body).to include "<input name=\"url\" type=\"hidden\" value=\"/pages\" />"
      end
    end

  end

  context 'POST /' do
    let(:email) { "#{rand(999)}@example.com" }
    let(:user_password) { rand(999).to_s }
    let(:user_type) { rand(100) % 2 == 0 ? :administrator : :editor }
    let(:url) { '/success' }

    context 'when user does not exist' do

      let(:login_password) { rand(999).to_s }

      before do
        post('login', {email: email, password: login_password, url: url})
        expect(last_response.status).to be 200
      end

      it 'shows login page with a warning' do
        expect(last_response.body).to include 'The email supplied either does not exists, or the password does not match.'
      end
    end

    context 'when user exists' do

      before do
        Sam::Model::User.create(email: email, password: BCrypt::Password.create(user_password), user_type: user_type)
        post('/login', {email: email, password: login_password, url: url})
      end

      context 'and passwords do not match' do
        let(:login_password) { rand(999).to_s }

        it 'no user in session' do
          expect(last_request.env['rack.session'][:user]).to be nil
        end

        it 'shows login page with a warning' do
          expect(last_response.status).to be 200
          expect(last_response.body).to include 'The email supplied either does not exists, or the password does not match.'
        end
      end

      context 'and passwords match' do
        let(:login_password) { user_password }

        it 'should add the user email in the session' do
          expect(last_request.env['rack.session'][:user][:email]).to eq email
        end

        it 'should add the user type in the session' do
          expect(last_request.env['rack.session'][:user][:type]).to eq user_type
        end

        it 'should redirect the user to the URL' do
          expect(last_response).to be_redirect
          expect(last_response.location).to include url
        end
      end

    end


  end

end
