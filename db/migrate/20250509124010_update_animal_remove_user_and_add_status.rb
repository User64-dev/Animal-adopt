class UpdateAnimalRemoveUserAndAddStatus < ActiveRecord::Migration[8.0]
  def change
    # Check if user_id column exists before trying to modify or remove it
    if column_exists?(:animals, :user_id)
      # First make the foreign key nullable so we can safely remove it
      change_column_null :animals, :user_id, true
      
      # Remove the index and foreign key if they exist
      if index_exists?(:animals, :user_id)
        remove_index :animals, :user_id
      end
      # Note: remove_foreign_key might raise an error if the key doesn't exist.
      # It's safer to check or ensure the foreign key was actually created.
      # However, given the previous migration was skipped, this foreign key likely doesn't exist.
      # We can attempt to remove it, and if it fails, it might not be critical if the column is being removed anyway.
      begin
        remove_foreign_key :animals, :users
      rescue ArgumentError => e
        Rails.logger.warn "[Migration 20250509124010] Attempted to remove foreign key for users on animals, but it might not have existed: #{e.message}"
      end
      
      # Remove the user_id column
      remove_column :animals, :user_id
    else
      Rails.logger.info "[Migration 20250509124010] Column :user_id does not exist on :animals table. Skipping its modification and removal."
    end
    
    # Add status column for tracking adoption state, if it doesn't already exist
    unless column_exists?(:animals, :status)
      add_column :animals, :status, :integer, default: 0
    end
    
    # Rename type column to animal_type to avoid conflict with STI, if it exists and hasn't been renamed
    if column_exists?(:animals, :type) && !column_exists?(:animals, :animal_type)
      rename_column :animals, :type, :animal_type
    elsif column_exists?(:animals, :type) && column_exists?(:animals, :animal_type)
      Rails.logger.info "[Migration 20250509124010] Both :type and :animal_type columns exist on :animals. No rename needed or manual check required."
    elsif !column_exists?(:animals, :type) && column_exists?(:animals, :animal_type)
      Rails.logger.info "[Migration 20250509124010] Column :type already renamed to :animal_type on :animals."
    end
  end
end
