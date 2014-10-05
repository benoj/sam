require 'mongoid'


module Sam
  module Model
    class UserRequest
      include Mongoid::Document
      field :email
      field :password
    end
  end
end
