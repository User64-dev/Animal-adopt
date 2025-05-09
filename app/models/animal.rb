class Animal < ApplicationRecord
  # Animals can have many adoptions but only be adopted by one user
  has_many :adoptions
  has_many :users, through: :adoptions
  
  # Status for tracking if animal is available, pending, or adopted
  enum :status, { available: 0, pending: 1, adopted: 2 }, default: :available
  
  # Validations
  validates :name, presence: true
end
