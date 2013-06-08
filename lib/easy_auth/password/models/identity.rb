module EasyAuth::Password::Models::Identity
  extend ActiveSupport::Concern

  # Getter for the remember flag
  def remember
    @remember
  end

  # Setter for the remember flag
  #
  # @param [Boolean] value
  def remember=(value)
    @remember = ::ActiveRecord::ConnectionAdapters::Column.value_to_boolean(value)
  end

  # Generates a new remember token and updates it on the identity record
  #
  # @return [String]
  def generate_remember_token_digest!
    remember_token = _generate_token(:remember)
    update_column(:remember_token_digest, SCrypt::Password.create(remember_token))
    remember_token
  end

  # The time used for remembering how long to stay signed in
  #
  # Defaults to 1 year, override in the model to set your own custom remember time
  #
  # @return [DateTime]
  def remember_time
    1.year
  end
end
