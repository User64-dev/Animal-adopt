class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    # Check if the users table already exists
    if table_exists?(:users)
      # If the table exists and has a date column but not an age column
      if column_exists?(:users, :date) && !column_exists?(:users, :age)
        # Rename date column to age
        rename_column :users, :date, :age
      end
    else
      # Create the users table if it doesn't exist
      create_table :users do |t|
        t.string :name
        t.integer :age
        t.string :password

        t.timestamps null: false
      end
    end
  end
end
