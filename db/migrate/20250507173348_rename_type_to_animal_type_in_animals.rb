class RenameTypeToAnimalTypeInAnimals < ActiveRecord::Migration[8.0]
  def change
    rename_column :animals, :type, :animal_type
  end
end
