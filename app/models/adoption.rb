class Adoption < ApplicationRecord
  belongs_to :animal
  belongs_to :user

  validates :animal, presence: true
  validates :user, presence: true
end
# This model represents the adoption of an animal by a user.
# It establishes a many-to-many relationship between animals and users.