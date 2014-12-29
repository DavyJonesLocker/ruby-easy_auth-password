module EasyAuth::Controllers::PasswordReset
  def self.included(base)
    base.instance_eval do
      before_filter :find_account_from_reset_token, :only => [:edit, :update]
    end
  end

  def new
    @identity = EasyAuth.find_identity_model(params).new
  end

  def create
    if @identity = EasyAuth.find_identity_model(params).where(:uid => params[:identities_password][:uid]).first
      unencrypted_reset_token = @identity.generate_reset_token!
      PasswordResetMailer.reset(@identity.id, unencrypted_reset_token).deliver_now
      after_successful_attempted_password_reset
    else
      @identity = EasyAuth.find_identity_model(params).new(uid: params[:identities_password][:uid])
      after_failed_attempted_password_reset
    end
  end

  def update
    @identity = @account.password_identities.first

    if @account.update_attributes(account_params)
      after_successful_password_reset
    else
      after_failed_password_reset
    end
  end

  def after_successful_password_reset
    session[:identity_id] = @identity.id
    @identity.update_column(:reset_token_digest, nil)
    redirect_to after_successful_password_reset_url, :notice => I18n.t('easy_auth.password_reset.update.notice')
  end

  def after_successful_password_reset_url
    @identity.account
  end

  def after_failed_password_reset
    flash.now[:error] = I18n.t('easy_auth.password_reset.update.error')
    render :edit
  end

  def after_successful_attempted_password_reset
    flash.now[:notice] = I18n.t('easy_auth.password_reset.create.notice')
    render :new
  end

  def after_failed_attempted_password_reset
    after_successful_attempted_password_reset
  end

  private

  def account_params
    params.require(ActiveModel::Naming.param_key(@account)).permit(:password, :password_confirmation)
  end

  def find_account_from_reset_token
    if @account = EasyAuth.find_identity_model(params).authenticate(self, :reset_token).try(:account)
      @account.password_reset = true
    else
      flash[:error] = I18n.t('easy_auth.password_reset.edit.error')
      redirect_to root_path
    end
  end
end
