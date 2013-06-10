module EasyAuth::Password::Routes
  def easy_auth_password_routes
    get  '/sign_in'  => 'sessions#new',    :defaults => { :identity => 'password' }, :as => :sign_in
    post '/sign_in'  => 'sessions#create', :defaults => { :identity => 'password' }

    get  '/password_reset' => 'password_reset#new',    :defaults => { :identity => 'password' }, :as => :password_reset
    post '/password_reset' => 'password_reset#create', :defaults => { :identity => 'password' }

    get  '/password_reset/:id/:reset_token' => 'password_reset#edit',   :defaults => { :identity => 'password' }, :as => :edit_password_reset
    if Rails.version >= '4.0.0'
      patch  '/password_reset/:id/:reset_token' => 'password_reset#update', :defaults => { :identity => 'password' }
    else
      put  '/password_reset/:id/:reset_token' => 'password_reset#update', :defaults => { :identity => 'password' }
    end
  end
end
