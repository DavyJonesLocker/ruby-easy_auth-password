class LandingController < ApplicationController
  before_filter :redirect_to_dashboard_if_signed_in

  private

  def redirect_to_dashboard_if_signed_in
    if account_signed_in?
      redirect_to dashboard_url
    end
  end
end
