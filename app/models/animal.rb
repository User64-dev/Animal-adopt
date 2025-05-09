class Animal < ApplicationRecord
  # Animals can have many adoptions but only be adopted by one user
  has_many :adoptions, dependent: :destroy
  has_many :users, through: :adoptions
  
  # Status for tracking if animal is available, pending, or adopted
  enum :status, { available: 0, pending: 1, adopted: 2 }, default: :available, prefix: true
  
  # Validations
  validates :name, presence: true
  
  # Additional methods for displaying status
  def status_label
    case status
    when 'available'
      'Available for Adoption'
    when 'pending'
      'Adoption in Progress'
    when 'adopted'
      'Already Adopted'
    else
      'Unknown Status'
    end
  end
  
  # Check if animal is adopted by a specific user
  def adopted_by?(user)
    adoptions.exists?(user: user)
  end

  # Updates the animal\'s status based on its current adoptions.
  # This should be called whenever an adoption related to this animal changes.
  def update_status_based_on_adoptions!
    if adoptions.completed.exists?
      update!(status: :adopted) unless status_adopted?
    elsif adoptions.where(status: [:pending, :reviewing, :approved]).exists?
      update!(status: :pending) unless status_pending?
    else
      update!(status: :available) unless status_available?
    end
  end
end
