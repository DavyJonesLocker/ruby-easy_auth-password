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
        where(arel_table[:username].matches(attributes[:username].try(&:strip))).first.try(:authenticate, attributes[token_name], token_name)
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
    end
  end

  def generate_reset_token!
    unencrypted_token = URI.escape(_generate_token(:reset_token).gsub(/[\.|\\\/]/,''))
    update_column(:reset_token_digest, BCrypt::Password.create(unencrypted_token))
    unencrypted_token
  end
end
