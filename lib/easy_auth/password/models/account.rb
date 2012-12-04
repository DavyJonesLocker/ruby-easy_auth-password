module EasyAuth::Password::Models::Account
  extend EasyAuth::ReverseConcern
  class  NoIdentityUsernameError < StandardError; end

  reverse_included do
    # Attributes
    attr_accessor   :password
    attr_accessible :password, :password_confirmation

    # Validations
    validates :password, :presence => { :on => :create, :if => :run_password_identity_validations? }, :confirmation => true
    identity_username_attributes.each do |attribute|
      validates attribute, :presence => true, :if => :run_password_identity_validations?
    end

    # Callbacks
    before_create :setup_password_identities,  :if => :run_password_identity_validations?
    before_update :update_password_identities, :if => :run_password_identity_validations?

    # Associations
    has_many :password_identities, :class_name => 'Identities::Password', :foreign_key => :account_id
  end

  module ClassMethods
    # Will attempt to find the username attributes of :username and :email
    # Will return an array of any defined on the model
    # If neither are defined an exception will be raised
    #
    # Override this method with an array of symbols for custom attributes
    #
    # @return [Symbol]
    def identity_username_attributes
      attributes = (['email', 'username'] & column_names).map(&:to_sym)

      if attributes.empty?
        raise EasyAuth::Password::Models::Account::NoIdentityUsernameError, 'your model must have either a #username or #email attribute. Or you must override the .identity_username_attribute class method'
      else
        attributes
      end
    end
  end

  def identity_username_attributes
    self.class.identity_username_attributes
  end

  def run_password_identity_validations?
    (self.new_record? && self.password.present?) || self.password_identities.present?
  end

  private

  def setup_password_identities
    identity_username_attributes.each do |attribute|
      self.identities << EasyAuth.find_identity_model(:identity => :password).new(password_identity_attributes(attribute))
    end
  end

  def update_password_identities
    identity_username_attributes.each do |attribute|
      if send("#{attribute}_changed?")
        identity = password_identities.find { |identity| identity.username == send("#{attribute}_was") }
      else
        identity = password_identities.find { |identity| identity.username == send(attribute) }
      end
      identity.update_attributes(password_identity_attributes(attribute))
    end
  end

  def password_identity_attributes(attribute)
    { :username => send(attribute), :password => self.password, :password_confirmation => self.password_confirmation }
  end
end
