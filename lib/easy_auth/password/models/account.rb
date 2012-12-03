module EasyAuth::Password::Models::Account
  extend EasyAuth::ReverseConcern
  class  NoIdentityUsernameError < StandardError; end

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

    # Associations
    has_one :password_identity, :class_name => 'Identities::Password', :foreign_key => :account_id
  end

  module ClassMethods
    # Will attempt to find the username attribute
    #
    # First will check to see if #identity_username_attribute is already defined in the model.
    #
    # If not, will check to see if `username` exists as a column on the record
    # If not, will check to see if `email` exists as a column on the record
    #
    # @return [Symbol]
    def identity_username_attribute
      if respond_to?(:super)
        super
      elsif column_names.include?('username')
        :username
      elsif column_names.include?('email')
        :email
      else
        raise EasyAuth::Password::Models::Account::NoIdentityUsernameError, 'your model must have either a #username or #email attribute. Or you must override the .identity_username_attribute class method'
      end
    end
  end

  def identity_username_attribute
    self.send(self.class.identity_username_attribute)
  end

  def run_password_identity_validations?
    (self.new_record? && self.password.present?) || self.password_identity.present?
  end

  private

  def setup_password_identity
    self.identities << EasyAuth.find_identity_model(:identity => :password).new(password_identity_attributes)
  end

  def update_password_identity
    self.password_identity.update_attributes(password_identity_attributes)
  end

  def password_identity_attributes
    { :username => self.identity_username_attribute, :password => self.password, :password_confirmation => self.password_confirmation }
  end
end
