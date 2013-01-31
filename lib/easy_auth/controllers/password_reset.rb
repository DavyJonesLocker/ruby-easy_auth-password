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
      PasswordResetMailer.reset(@identity.id, unencrypted_reset_token).deliver
    else
      @identity = EasyAuth.find_identity_model(params).new(params[:identities_password])
    end

    flash.now[:notice] = I18n.t('easy_auth.password_reset.create.notice')
    render :new
  end

  def update
    if @account.update_attributes(params[ActiveModel::Naming.param_key(@account)])
      after_successful_password_reset(@account.password_identities.first)
    else
      after_failed_password_reset(@account.password_identities.first)
    end
  end

  private

  def find_account_from_reset_token
    if @account = EasyAuth.find_identity_model(params).authenticate(self, :reset_token).try(:account)
      @account.password_reset = true
    else
      flash[:error] = I18n.t('easy_auth.password_reset.edit.error')
      redirect_to root_path
    end
  end

  def after_successful_password_reset(identity)
    session[:identity_id] = identity.id
    identity.update_column(:reset_token_digest, nil)
    redirect_to after_successful_password_reset_url(identity), :notice => I18n.t('easy_auth.password_reset.update.notice')
  end

  def after_successful_password_reset_url(identity)
    identity.account
  end

  def after_failed_password_reset(identity)
    flash.now[:error] = I18n.t('easy_auth.password_reset.update.error')
    render :edit
  end
end
