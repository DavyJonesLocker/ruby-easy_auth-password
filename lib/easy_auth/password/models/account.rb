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
    before_save :update_password_identity, :if => :can_update_password_identity?

    # Associations
    has_one :password_identity, :class_name => 'Identities::Password', :as => :account, autosave: true
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
    self.password.present? || self.password_identity.present?
  end

  private

  def can_update_password_identity?
    password.present? || (password_identity.present? && identity_uid_attributes.find { |attribute| send("#{attribute}_changed?") })
  end

  def update_password_identity
    if password_identity.blank?
      self.build_password_identity
    end

    identity_uid_attributes.each do |attribute|
      if index = password_identity.uid.index(send("#{attribute}_was"))
        password_identity.uid[index] = send(attribute)
      else
        password_identity.uid << send(attribute)
      end

      password_identity.uid_will_change!
    end

    password_identity.password = self.password
  end
end
