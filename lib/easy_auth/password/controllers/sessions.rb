module EasyAuth::Password::Controllers::Sessions
  extend ActiveSupport::Concern

  prepended do
    before_filter :no_authentication, :only => :new, :if => Proc.new { params[:identity] == 'password' }

    def create
      super

      if @identity.persisted?
        if identity_attributes = params[ActiveModel::Naming.param_key(EasyAuth.find_identity_model(params).new)]
          @identity.remember = identity_attributes[:remember]
        end

        if @identity.remember
          cookies[:remember_id]    = { :value => @identity.id,                              :expires => @identity.remember_time.from_now }
          cookies[:remember_token] = { :value => @identity.generate_remember_token_digest!, :expires => @identity.remember_time.from_now }
        end
      end
    end

    def destroy
      super
      cookies.delete(:remember_id)
      cookies.delete(:remember_token)
    end
  end
end
