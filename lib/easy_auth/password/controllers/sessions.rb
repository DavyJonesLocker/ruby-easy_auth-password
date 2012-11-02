module EasyAuth::Password::Controllers::Sessions
  extend EasyAuth::ReverseConcern

  reverse_included do
    before_filter :no_authentication, :only => :new, :if => Proc.new { params[:identity] == :password }
  end
end
