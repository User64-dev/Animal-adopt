class AddUserToAnimals < ActiveRecord::Migration[8.0]
  def change
    # Original line: add_reference :animals, :user, null: false, foreign_key: true
    # This line is being bypassed for the following reasons:
    # 1. This migration (20250503203940) runs before the `users` table is created
    #    by 20250503204903_create_users.rb, causing a "no such table" error
    #    when trying to add a foreign key.
    # 2. The `user_id` column and its foreign key on the `animals` table are
    #    removed by a later migration (20250509124010_update_animal_remove_user_and_add_status.rb).
    # Bypassing this operation allows the migration sequence to proceed.
    # If the temporary existence of this `user_id` was critical and used by other
    # subsequent migrations (before its removal), the migration order itself
    # would need to be corrected (e.g., by renaming migration files to adjust timestamps).
    Rails.logger.info "[Migration 20250503203940] Intentionally skipping 'add_reference :animals, :user' due to execution order issues and the column's subsequent removal."
  end
end
