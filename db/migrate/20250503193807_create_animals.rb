class CreateAnimals < ActiveRecord::Migration[8.0]
  def change
    create_table :animals do |t|
      t.string :name
      t.string :type
      t.integer :age
      t.string :race

      t.timestamps
    end
  end
end
