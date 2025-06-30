require "test_helper"

class AdoptionCallbackTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(username: "callbackuser", email: "callback@example.com", password: "password123")
    @animal = Animal.create!(name: "Callback Pet", animal_type: "Cat", age: 2, race: "Siamese", status: :available)
  end

  test "adoption callbacks update animal status correctly without controller interference" do
    # Test the core model callback functionality directly
    
    # Initial state: animal should be available
    assert @animal.status_available?, "Animal should start as available"
    
    # Create a pending adoption
    adoption = Adoption.create!(
      animal: @animal,
      user: @user,
      reason: "I love cats",
      home_type: "Apartment",
      has_yard: false,
      has_other_pets: false,
      status: :pending
    )
    
    # Animal should now be pending (callback triggered by adoption save)
    @animal.reload
    assert @animal.status_pending?, "Animal should be pending after creating adoption"
    
    # Update adoption to completed
    adoption.update!(status: :completed)
    
    # Animal should now be adopted (callback triggered by adoption update)
    @animal.reload
    assert @animal.status_adopted?, "Animal should be adopted after adoption completed"
    
    # Create second adoption for the same animal (testing edge case)
    adoption2 = Adoption.create!(
      animal: @animal,
      user: User.create!(username: "user2callback", email: "user2callback@example.com", password: "password123"),
      reason: "I also love cats",
      home_type: "House",
      has_yard: true,
      has_other_pets: false,
      status: :pending
    )
    
    # Animal should still be adopted (completed adoption takes precedence)
    @animal.reload
    assert @animal.status_adopted?, "Animal should remain adopted even with new pending adoption"
    
    # Destroy the completed adoption
    adoption.destroy!
    
    # Animal should now be pending (because adoption2 still exists and is pending)
    @animal.reload
    assert @animal.status_pending?, "Animal should be pending after completed adoption destroyed but pending adoption remains"
    
    # Destroy the pending adoption
    adoption2.destroy!
    
    # Animal should now be available (no adoptions left)
    @animal.reload
    assert @animal.status_available?, "Animal should be available after all adoptions destroyed"
  end

  test "multiple pending adoptions are handled correctly" do
    # Create multiple pending adoptions
    adoption1 = Adoption.create!(
      animal: @animal,
      user: @user,
      reason: "First application",
      home_type: "House",
      has_yard: true,
      has_other_pets: false,
      status: :pending
    )
    
    @animal.reload
    assert @animal.status_pending?, "Animal should be pending after first adoption"
    
    user2 = User.create!(username: "user2multi", email: "user2multi@example.com", password: "password123")
    adoption2 = Adoption.create!(
      animal: @animal,
      user: user2,
      reason: "Second application",
      home_type: "Apartment",
      has_yard: false,
      has_other_pets: false,
      status: :reviewing
    )
    
    @animal.reload
    assert @animal.status_pending?, "Animal should remain pending with multiple adoptions"
    
    # Reject first adoption
    adoption1.update!(status: :rejected)
    @animal.reload
    assert @animal.status_pending?, "Animal should still be pending (second adoption is still reviewing)"
    
    # Approve second adoption
    adoption2.update!(status: :approved)
    @animal.reload
    assert @animal.status_pending?, "Animal should still be pending (approved adoption not yet completed)"
    
    # Complete second adoption
    adoption2.update!(status: :completed)
    @animal.reload
    assert @animal.status_adopted?, "Animal should be adopted after second adoption completed"
  end
end