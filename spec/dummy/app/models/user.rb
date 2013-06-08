class User < ActiveRecord::Base
  $T = true
  include EasyAuth::Models::Account
end
