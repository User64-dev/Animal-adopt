class FixPasswordDigestColumn < ActiveRecord::Migration[8.0]
  def change
    # Make sure password_digest column exists and has the correct type
    # If the column doesn't exist yet, add it
    unless column_exists?(:users, :password_digest)
      add_column :users, :password_digest, :string
    end
    
    # If the column exists but with wrong type, change it
    change_column :users, :password_digest, :string if column_exists?(:users, :password_digest)
  end
end