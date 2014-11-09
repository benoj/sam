require 'grape'
require 'models/user'
require 'models/user_request'
require 'rfc822'
require 'bcrypt'

module Sam
  class ValidEmail < Grape::Validations::Validator
    def validate_param!(attr_name, params)
      unless params[attr_name].is_email?
        raise Grape::Exceptions::Validation, params: [params[attr_name]], message: 'is not a valid email address'
      end
    end
  end

  class PasswordsMatch < Grape::Validations::Validator
    def validate_param!(attr_name, params)
      unless params[attr_name] == params['confirm_password']
        raise Grape::Exceptions::Validation, params: [@scope.full_name(attr_name),@scope.full_name('confirm_password')], message: 'should match'
      end
    end
  end

  class UserExists < Grape::Validations::Validator
    def validate_param!(attr_name, params)
      if Model::User.where(email: params[attr_name]).exists?
        raise Grape::Exceptions::Validation, params: [params[attr_name]], message: 'is already in use'
      end
    end
  end


  class API < Grape::API
    resource :users do
      params do
        requires :password, passwords_match: true
        requires :email, valid_email: true, user_exists: false
      end
      post do
        hashed_password = BCrypt::Password.create(params['password'])
        email = params['email']
        if Model::User.count == 0
          Model::User.create(email: email, password: hashed_password, user_type: :administrator)
        else
          Model::UserRequest.create(email: email, password: hashed_password)
        end
      end
    end
  end
end