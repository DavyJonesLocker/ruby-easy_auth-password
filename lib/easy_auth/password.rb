require 'easy_auth'
require 'easy_auth/password/engine'
require 'easy_auth/password/version'
require 'easy_auth/password/routes'

module EasyAuth

  module Password
    extend ActiveSupport::Autoload
    autoload :Controllers
    autoload :Models
  end

  module Controllers
    autoload :PasswordReset

    module Sessions
      include EasyAuth::Password::Controllers::Sessions
    end
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
