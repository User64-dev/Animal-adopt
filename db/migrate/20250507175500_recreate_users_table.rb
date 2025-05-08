class RecreateUsersTable < ActiveRecord::Migration[8.0]
  def change
    # Only recreate if there are issues with the current users table
    if table_exists?(:users)
      # Create a temporary backup table if needed
      create_table :users_backup do |t|
        t.string :username
        t.string :email
        t.string :password_digest
        t.boolean :admin, default: false
        t.timestamps
      end
      
      # Copy data if the original table has the required columns
      begin
        execute("INSERT INTO users_backup (id, username, email, password_digest, admin, created_at, updated_at) 
                 SELECT id, username, email, password_digest, admin, created_at, updated_at FROM users")
      rescue => e
        puts "Error copying user data: #{e.message}"
      end
      
      # Drop and recreate the users table
      drop_table :users
      create_table :users do |t|
        t.string :username
        t.string :email
        t.string :password_digest
        t.boolean :admin, default: false
        t.timestamps
      end
      
      # Copy data back
      begin
        execute("INSERT INTO users (id, username, email, password_digest, admin, created_at, updated_at) 
                 SELECT id, username, email, password_digest, admin, created_at, updated_at FROM users_backup")
      rescue => e
        puts "Error restoring user data: #{e.message}"
      end
      
      # Drop the backup table
      drop_table :users_backup
    end
  end
end