class SessionsController < ApplicationController
  include EasyAuth::Controllers::Sessions

  private

  def after_successful_sign_in_url_default
    main_app.dashboard_url
  end
end
