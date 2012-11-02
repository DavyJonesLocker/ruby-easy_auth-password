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

      def self.authenticate(controller)
        attributes = controller.params[:identities_password]
        return nil if attributes.nil?
        where(arel_table[:username].matches(attributes[:username].try(&:strip))).first.try(:authenticate, attributes[:password])
      end

    end
  end

  def generate_reset_token!
    update_column(:reset_token, URI.escape(_generate_token(:reset).gsub(/[\.|\\\/]/,'')))
    reset_token
  end
end
