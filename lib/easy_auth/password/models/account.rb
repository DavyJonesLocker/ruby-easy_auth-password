module EasyAuth::Password::Models::Account
  extend ActiveSupport::Concern
  class  NoIdentityUIDError < StandardError; end

  prepended do
    # Attributes
    attr_accessor :password, :password_reset

    # Validations
    validates :password, :presence => { :if => :password_reset }, :confirmation => true
    identity_uid_attributes.each do |attribute|
      validates attribute, :presence => true, :if => :run_password_identity_validations?
    end

    # Callbacks
    before_save :update_password_identities, :if => :can_update_password_identities?

    # Associations
    has_many :password_identities, :class_name => 'Identities::Password', :as => :account
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
      if table_exists?
        attributes = (['email', 'username'] & column_names).map(&:to_sym)
      else
        attributes = []
      end

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

  private

  def can_update_password_identities?
    password.present? || identity_uid_attributes.detect do |attribute|
      send("#{attribute}_changed?") && password_identities.where(password_identities.arel_table[:uid].matches(send("#{attribute}_was"))).first
    end
  end

  def update_password_identities
    identity_uid_attributes.each do |attribute|
      if send("#{attribute}_changed?")
        identity = password_identities.find { |identity| identity.uid =~ match(send("#{attribute}_was")) }
      else
        identity = password_identities.find { |identity| identity.uid =~ match(send(attribute)) }
      end

      if identity
        identity.update_attributes(password_identity_attributes(attribute))
      else
        self.password_identities.build(password_identity_attributes(attribute))
      end
    end
  end

  def password_identity_attributes(attribute)
    { :uid => send(attribute), :password => self.password }
  end

  def match(value)
    Regexp.new("\\A#{value}\\z", 'i')
  end
end
