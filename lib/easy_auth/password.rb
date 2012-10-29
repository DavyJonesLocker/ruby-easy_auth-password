require 'easy_auth'
require 'easy_auth/password/engine'
require 'easy_auth/password/version'
require 'easy_auth/password/models/account'
require 'easy_auth/password/routes'

module EasyAuth
  def self.password_identity_model(controller = nil)
    EasyAuth::Identities::Password
  end

  module Controllers
    autoload :PasswordReset
  end

  module Mailers
    autoload :PasswordReset
  end

  module Models
    module Account
      include EasyAuth::Password::Models::Account
    end

    module Identities
      autoload :Password
    end
  end
end

ActionDispatch::Routing::Mapper.send(:include, EasyAuth::Password::Routes)
