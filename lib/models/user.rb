require 'mongoid'

module Sam
  module Model
    class User
      include Mongoid::Document
      field :email
      field :password
      field :user_type, type:Symbol
    end
  end
end
