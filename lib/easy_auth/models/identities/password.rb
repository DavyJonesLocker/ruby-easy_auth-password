require 'scrypt'

module EasyAuth::Models::Identities::Password
  include EasyAuth::TokenGenerator
  extend ActiveSupport::Concern

  included do
    # Attributes
    attr_reader     :password
    alias_attribute :password_digest, :token

    # Validations
    _validators[:uid].delete_at(_validators[:uid].index { |v| v.instance_of?(ActiveRecord::Validations::UniquenessValidator) })
    _validators[:token].delete_at(_validators[:token].index { |v| v.instance_of?(ActiveRecord::Validations::PresenceValidator) })
    validates :uid, uniqueness: { case_sensitive: false }
    validates :password_digest, presence: true
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
    token_value = send("#{token_name}_digest")
    return false unless token_value
    SCrypt::Password.new(token_value) == unencrypted_token && self
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
