module EasyAuth::Password::Routes
  def easy_auth_password_routes
    get  '/sign_in'  => 'sessions#new',                           :as => :sign_in,        :defaults => { :identity => :password }
    post '/sign_in'  => 'sessions#create',                                                :defaults => { :identity => :password }

    get  '/password_reset' => 'password_reset#new',               :as => :password_reset, :defaults => { :identity => :password }
    post '/password_reset' => 'password_reset#create',                                    :defaults => { :identity => :password }
    get  '/password_reset/:reset_token' => 'password_reset#edit', :as => :edit_password,  :defaults => { :identity => :password }
    put  '/password_reset/:reset_token' => 'password_reset#update',                       :defaults => { :identity => :password }
  end
end
