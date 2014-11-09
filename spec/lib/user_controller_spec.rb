require 'spec_helper'
require 'user_controller'
require 'bcrypt'

describe Sam::User::Login do

  def app
    Rack::Builder.parse_file('config.ru').first
  end

  context 'GET /login' do
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

  context 'POST /login' do
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

  context 'POST /' do

    context 'with invalid email' do

      invalid_emails = ['user-home', '@home.com', 'user@', 'user@just,wrong.org', 'user@just wrong.org',
                        'wrong,user@home.com', 'wrong-user.@home.com', 'wrong@user@home.com', 'wrong user@home.com',
                        'wrong(user)@home.com']

      invalid_emails.each do |invalid_email|

        it "should return bad request for #{invalid_email}" do
          post('/users', email: invalid_email, password: 'asd123', confirm_password: 'asd123')
          expect(last_response.status).to eq 400
        end

        it "should return message for #{invalid_email}" do
          post('/users', email: invalid_email, password: 'asd123', confirm_password: 'asd123')
          expect(last_response.body).to eq "#{invalid_email} is not a valid email address"
        end


      end


    end
    context 'with valid email' do
      let(:email) { "#{rand(999)}@example.com" }


      context 'passwords do not match' do
        let(:password) { rand(1000).to_s }
        let(:confirm_password) { rand(1000).to_s }

        before do
          post('/users', email: email, password: password, confirm_password: confirm_password)
        end

        it 'returns 400 response code' do
          expect(last_response.status).to eq 400
        end

        it 'tells the user that the passwords do not match' do
          expect(last_response.body).to eq 'Passwords do not match'
        end
      end

      context 'passwords match' do
        context 'when admin user exists in db' do

          before do
            Sam::Model::User.create(email: rand(100).to_s,
                                    password: rand(100).to_s,
                                    user_type: :administrator)
          end

          context 'and email supplied already exists' do
            before do
              Sam::Model::User.create(email: email,
                                      password: rand(100).to_s,
                                      user_type: :editor)
              post('/users', email: email, password: 'asd234', confirm_password: 'asd234')
            end

            it 'returns 400 response code' do
              expect(last_response.status).to eq 400
            end


            it 'tells the user that email is already in use' do
              expect(last_response.body).to eq 'The email supplied is already in use'
            end
          end

          context 'and email supplied does not match existing user' do
            let(:user) { Sam::Model::UserRequest.first }
            let(:password) { rand(100).to_s }
            let(:confirm_password) { password }

            before do
              post('/users', email: email, password: password, confirm_password: confirm_password)
            end

            it 'creates user in the db' do
              expect(Sam::Model::UserRequest.count).to eq 1
            end

            it 'sets the email correctly' do
              expect(Sam::Model::UserRequest.first.email).to eq email
            end

            it 'sets the password correctly and is stored encrypted' do
              unhashed_password = BCrypt::Password.new(Sam::Model::UserRequest.first.password)
              expect(unhashed_password).to eq password
            end

          end
        end

        context 'when no users exist in db' do

          before do
            post('/users', email: email, password: password, confirm_password: confirm_password)
          end

          context 'and email is valid' do
            let(:password) { rand(100).to_s }
            let(:confirm_password) { password }
            let(:email) { "#{rand(999)}@example.com" }

            it 'creates user in the db' do
              expect(Sam::Model::User.count).to eq 1
            end

            it 'sets the profile type to administrator' do
              expect(Sam::Model::User.first.user_type).to eq(:administrator)
            end

            it 'sets the email correctly' do
              expect(Sam::Model::User.first.email).to eq email
            end

            it 'sets the password correctly and is stored encrypted' do
              unhashed_password = BCrypt::Password.new(Sam::Model::User.first.password)
              expect(unhashed_password).to eq password
            end
          end

        end
      end
    end
  end
end
