json.extract! animal, :id, :name, :type, :age, :race, :created_at, :updated_at
json.url animal_url(animal, format: :json)
