module EasyAuth::Password::Controllers::Sessions
  extend EasyAuth::ReverseConcern

  reverse_included do
    before_filter :no_authentication, :only => :new, :if => Proc.new { params[:identity] == :password }
  end

  private

  def after_successful_sign_in_with_password(identity)
  end

  def after_successful_sign_in_url_with_password(identity)
  end

  def after_failed_sign_in_with_password(identity)
  end
end
