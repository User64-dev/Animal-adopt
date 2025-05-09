class User < ApplicationRecord
  has_secure_password
  
  # User can have many animals through adoptions
  has_many :adoptions
  has_many :animals, through: :adoptions
  
  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }, on: :create
end
