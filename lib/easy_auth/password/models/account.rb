module EasyAuth::Password::Models::Account
  extend EasyAuth::ReverseConcern

  reverse_included do
    # Attributes
    attr_accessor   :password
    attr_accessible :password, :password_confirmation

    # Validations
    validates :password, :presence => { :on => :create, :if => :run_password_identity_validations? }, :confirmation => true
    validates identity_username_attribute, :presence => true, :if => :run_password_identity_validations?

    # Callbacks
    before_create :setup_password_identity,  :if => :run_password_identity_validations?
    before_update :update_password_identity, :if => :run_password_identity_validations?
  end

  def password_identity
    identities.select{ |identity| EasyAuth.password_identity_model === identity }.first
  end

  def run_password_identity_validations?
    (self.new_record? && self.password.present?) || self.password_identity.present?
  end

  private

  def setup_password_identity
    self.identities << EasyAuth.password_identity_model.new(password_identity_attributes)
  end

  def update_password_identity
    self.password_identity.update_attributes(password_identity_attributes)
  end

  def password_identity_attributes
    { :username => self.identity_username_attribute, :password => self.password, :password_confirmation => self.password_confirmation }
  end
end
