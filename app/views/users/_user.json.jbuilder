json.extract! user, :id, :name, :password, :date, :created_at, :updated_at
json.url user_url(user, format: :json)
