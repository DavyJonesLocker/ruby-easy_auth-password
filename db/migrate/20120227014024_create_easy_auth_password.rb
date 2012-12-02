class CreateEasyAuthPassword < ActiveRecord::Migration
  def change
    add_column :identities, :remember_token_digest, :string
    add_column :identities, :reset_token_digest, :string
  end
end
