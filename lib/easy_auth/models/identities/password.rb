require 'scrypt'

module EasyAuth::Models::Identities::Password
  include EasyAuth::TokenGenerator
  extend EasyAuth::ReverseConcern

  reverse_included do
    # Attributes
    attr_reader     :password
    attr_accessible :uid, :password, :remember
    alias_attribute :password_digest, :token

    # Relationships
    belongs_to :account, :polymorphic => true

    # Validations
    validates :uid, :uniqueness => { :case_sensitive => false }, :presence => true
    validates :password_digest, :presence => true
  end

  module ClassMethods
    def authenticate(controller, token_name = :password)
      attributes = send("attributes_for_#{token_name}", controller)
      return nil if attributes.nil?
      where(send("conditions_for_#{token_name}", attributes)).first.try(:authenticate, attributes[token_name], token_name)
    end

    private

    def attributes_for_password(controller)
      controller.params[:identities_password]
    end

    def attributes_for_reset_token(controller)
      controller.params
    end

    def attributes_for_remember_token(cookies)
      { :id => cookies[:remember_id], :remember_token => cookies[:remember_token] }
    end

    def conditions_for_password(attributes)
      arel_table[:uid].matches(attributes[:uid].try(&:strip))
    end

    def conditions_for_reset_token(attributes)
      { :id => attributes[:id] }
    end

    def conditions_for_remember_token(attributes)
      { :id => attributes[:id] }
    end
  end

  def authenticate(unencrypted_token, token_name = :password)
    SCrypt::Password.new(send("#{token_name}_digest")) == unencrypted_token && self
  end

  def password=(unencrypted_password)
    @password = unencrypted_password
    unless unencrypted_password.blank?
      self.password_digest = SCrypt::Password.create(unencrypted_password)
    end
  end

  def generate_reset_token!
    unencrypted_token = _generate_token(:reset_token)
    update_column(:reset_token_digest, SCrypt::Password.create(unencrypted_token))
    unencrypted_token
  end
end
