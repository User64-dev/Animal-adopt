class UpdateAnimalRemoveUserAndAddStatus < ActiveRecord::Migration[8.0]
  def change
    # First make the foreign key nullable so we can safely remove it
    change_column_null :animals, :user_id, true
    
    # Remove the index and foreign key
    remove_index :animals, :user_id
    remove_foreign_key :animals, :users
    
    # Remove the user_id column
    remove_column :animals, :user_id
    
    # Add status column for tracking adoption state
    add_column :animals, :status, :integer, default: 0
    
    # Rename type column to avoid conflict with STI
    rename_column :animals, :type, :animal_type
  end
end
