class CreateAdoptions < ActiveRecord::Migration[8.0]
  def change
    create_table :adoptions do |t|
      t.references :animal, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :status, default: 0
      t.text :reason
      t.string :home_type
      t.boolean :has_yard, default: false
      t.boolean :has_other_pets, default: false
      t.text :other_pets_description

      t.timestamps
    end
  end
end
