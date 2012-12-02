module EasyAuth::Models::Identities::Password
  include EasyAuth::TokenGenerator

  def self.included(base)
    base.class_eval do
      has_secure_password

      # Attributes
      attr_accessor   :password_reset
      attr_accessible :username, :password, :password_confirmation, :remember
      alias_attribute :password_digest, :token

      # Relationships
      belongs_to :account, :polymorphic => true

      # Validations
      validates :username, :uniqueness => { :case_sensitive => false }, :presence => true
      validates :password, :presence => { :on => :create }
      validates :password, :presence => { :if => :password_reset }

      def self.authenticate(controller, token_name = :password)
        attributes = send("attributes_for_#{token_name}", controller)
        return nil if attributes.nil?
        where(send("conditions_for_#{token_name}", attributes)).first.try(:authenticate, attributes[token_name], token_name)
      end

      def authenticate(unencrypted_token, token_name = :password)
        BCrypt::Password.new(send("#{token_name}_digest")) == unencrypted_token && self
      end

      private

      def self.attributes_for_password(controller)
        controller.params[:identities_password]
      end

      def self.attributes_for_reset_token(controller)
        controller.params
      end

      def self.attributes_for_remember_token(cookies)
        { :id => cookies[:remember_id], :remember_token => cookies[:remember_token] }
      end

      def self.conditions_for_password(attributes)
        arel_table[:username].matches(attributes[:username].try(&:strip))
      end

      def self.conditions_for_reset_token(attributes)
        { :id => attributes[:id] }
      end

      def self.conditions_for_remember_token(attributes)
        { :id => attributes[:id] }
      end
    end
  end

  def generate_reset_token!
    unencrypted_token = _generate_token(:reset_token)
    update_column(:reset_token_digest, BCrypt::Password.create(unencrypted_token))
    unencrypted_token
  end
end
