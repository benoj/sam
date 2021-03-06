require 'spec_helper'
require 'api/users'
require 'bcrypt'

describe Sam::API do

  def app
    Rack::Builder.parse_file('config.ru').first
  end

  context 'POST /' do

    context 'with invalid email' do

      invalid_emails = ['user-home', '@home.com', 'user@', 'user@just,wrong.org', 'user@just wrong.org',
                        'wrong,user@home.com', 'wrong-user.@home.com', 'wrong@user@home.com', 'wrong user@home.com',
                        'wrong(user)@home.com']

      invalid_emails.each do |invalid_email|

        it "should return bad request for #{invalid_email}" do
          post('/api/users', email: invalid_email, password: 'asd123', confirm_password: 'asd123')
          expect(last_response.status).to eq 400
        end

        it "should return message for #{invalid_email}" do
          post('/api/users', email: invalid_email, password: 'asd123', confirm_password: 'asd123')
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
          post('/api/users', email: email, password: password, confirm_password: confirm_password)
        end

        it 'returns 400 response code' do
          expect(last_response.status).to eq 400
        end

        it 'tells the user that the passwords do not match' do
          expect(last_response.body).to eq 'password, confirm_password should match'
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
              post('/api/users', email: email, password: 'asd234', confirm_password: 'asd234')
            end

            it 'returns 400 response code' do
              expect(last_response.status).to eq 400
            end


            it 'tells the user that email is already in use' do
              expect(last_response.body).to eq "#{email} is already in use"
            end
          end

          context 'and email supplied does not match existing user' do
            let(:user) { Sam::Model::UserRequest.first }
            let(:password) { rand(100).to_s }
            let(:confirm_password) { password }

            before do
              post('/api/users', email: email, password: password, confirm_password: confirm_password)
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
            post('/api/users', email: email, password: password, confirm_password: confirm_password)
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
