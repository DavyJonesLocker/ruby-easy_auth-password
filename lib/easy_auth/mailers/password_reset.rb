module EasyAuth::Mailers::PasswordReset
  def self.included(base)
    base.clear_action_methods!
  end

  def reset(id, unencrypted_reset_token)
    @identity = EasyAuth.find_identity_model(:identity => :password).find(id)
    @url = edit_password_reset_url(:id => id, :reset_token => unencrypted_reset_token)
    mail :to => @identity.account.email, :subject => 'Password reset'
  end
end
