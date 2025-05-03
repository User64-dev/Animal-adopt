class User < ApplicationRecord
  has_many :animals
  validates :age, presence: true, numericality: { greater_than_or_equal_to: 18, only_integer: true }

  # ... other validations and methods ...
end
