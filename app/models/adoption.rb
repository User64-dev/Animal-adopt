class Adoption < ApplicationRecord
  belongs_to :animal
  belongs_to :user

  # Status enum
  enum :status, {
    pending: 0,
    reviewing: 1,
    approved: 2,
    completed: 3,
    rejected: 4
  }, default: :pending
  
  # Callbacks to update animal status
  after_save :update_animal_status_after_save
  after_destroy :update_animal_status_after_destroy

  # Validations
  validates :animal, presence: true
  validates :user, presence: true
  validates :reason, presence: true
  validates :home_type, presence: true
  validates :has_yard, inclusion: { in: [true, false] }
  validates :has_other_pets, inclusion: { in: [true, false] }
  validates :other_pets_description, presence: true, if: :has_other_pets
  
  # Only one pending application per user per animal
  validates :animal_id, uniqueness: { 
    scope: :user_id,
    message: "You already have a pending application for this animal", 
    conditions: -> { where.not(status: [:completed, :rejected]) } 
  }

  private

  def update_animal_status_after_save
    animal.update_status_based_on_adoptions!
  end

  def update_animal_status_after_destroy
    # Ensure animal is not nil, though it should always be present
    # for an existing adoption record being destroyed.
    animal&.update_status_based_on_adoptions!
  end
end
# This model represents the adoption of an animal by a user.
# It establishes a many-to-many relationship between animals and users.