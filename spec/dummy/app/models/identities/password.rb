class Identities::Password < Identity
  include EasyAuth::Models::Identities::Password

  def self.authenticate(controller, token_name = :password)
    super
  end
end
