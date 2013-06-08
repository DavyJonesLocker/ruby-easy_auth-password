module EasyAuth::Password::Helpers::EasyAuth
  extend ActiveSupport::Concern

  prepended do
    def current_account
      super

      if @current_account.blank?
        if cookies[:remember_id] && cookies[:remember_token]
          begin
            @current_account = EasyAuth.find_identity_model(:identity => :password).authenticate(cookies, :remember_token).account
          rescue => e
            @current_account = nil
            delete_session_data
          end
        end
      end

      @current_account
    end

    private

    def delete_session_data
      super
      cookies.delete(:remember_id)
      cookies.delete(:remember_token)
    end
  end
end
