class User < ApplicationRecord
  has_secure_password
  has_many :animals
  validates :name, presence: true, uniqueness: true
  validates :age, presence: true, numericality: { greater_than_or_equal_to: 18, only_integer: true }
  validates :password, presence: true, length: { minimum: 6 }, on: :create
end
