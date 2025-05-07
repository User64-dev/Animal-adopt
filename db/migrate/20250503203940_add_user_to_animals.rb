class AddUserToAnimals < ActiveRecord::Migration[8.0]
  def change
    add_reference :animals, :user, null: false, foreign_key: true
  end
end
