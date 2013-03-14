module EasyAuth::Password::Models::Account
  extend EasyAuth::ReverseConcern
  class  NoIdentityUIDError < StandardError; end

  reverse_included do
    # Attributes
    attr_reader     :password
    attr_accessor   :password_reset

    # Validations
    validates :password, :presence => { :if => :password_reset }, :confirmation => true
    identity_uid_attributes.each do |attribute|
      validates attribute, :presence => true, :if => :run_password_identity_validations?
    end

    # Callbacks
    before_update :update_password_identities, :if => :run_password_identity_validations?

    # Associations
    has_many :password_identities, :class_name => 'Identities::Password', :foreign_key => :account_id
  end

  module ClassMethods
    # Will attempt to find the uid attributes of :username and :email
    # Will return an array of any defined on the model
    # If neither are defined an exception will be raised
    #
    # Override this method with an array of symbols for custom attributes
    #
    # @return [Symbol]
    def identity_uid_attributes
      attributes = (['email', 'username'] & column_names).map(&:to_sym)

      if attributes.empty?
        raise EasyAuth::Password::Models::Account::NoIdentityUIDError, 'your model must have either a #username or #email attribute. Or you must override the .identity_uid_attribute class method'
      else
        attributes
      end
    end
  end

  def identity_uid_attributes
    self.class.identity_uid_attributes
  end

  def run_password_identity_validations?
    self.password.present? || self.password_identities.present?
  end

  def password=(password)
    @password = password
    update_password_identities
  end

  private

  def build_password_identity_for_uid(uid)
    self.identities << EasyAuth.find_identity_model(:identity => :password).new(password_identity_attributes(uid))
  end

  def update_password_identities
    identity_uid_attributes.each do |attribute|
      if send("#{attribute}_changed?")
        identity = password_identities.find { |identity| identity.uid == send("#{attribute}_was") }
      else
        identity = password_identities.find { |identity| identity.uid == send(attribute) }
      end

      if identity
        identity.update_attributes(password_identity_attributes(attribute))
      else
        build_password_identity_for_uid(attribute)
      end
    end
  end

  def password_identity_attributes(attribute)
    { :uid => send(attribute), :password => self.password }
  end
end
