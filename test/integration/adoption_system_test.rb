require "test_helper"

class AdoptionSystemTest < ActionDispatch::IntegrationTest
  test "adoption system updates animal status correctly" do
    # Create test data
    animal = Animal.create!(name: "Test Dog", animal_type: "Dog", age: 2, race: "Labrador", status: :available)
    user = User.create!(username: "testuser", email: "test@example.com", password: "password123")
    
    # Test 1: Animal should start as available
    assert animal.status_available?, "Animal should start as available"
    
    # Test 2: Creating an adoption should make animal pending
    adoption = Adoption.create!(
      animal: animal,
      user: user,
      reason: "I love dogs",
      home_type: "House",
      has_yard: true,
      has_other_pets: false,
      status: :pending
    )
    
    animal.reload
    assert animal.status_pending?, "Animal should be pending after adoption created"
    
    # Test 3: Completing the adoption should make animal adopted
    adoption.update!(status: :completed)
    animal.reload
    assert animal.status_adopted?, "Animal should be adopted after adoption completed"
    
    # Test 4: Destroying the adoption should make animal available again
    adoption.destroy!
    animal.reload
    assert animal.status_available?, "Animal should be available after adoption destroyed"
  end
  
  test "multiple adoptions are handled correctly" do
    # Create test data
    animal = Animal.create!(name: "Test Cat", animal_type: "Cat", age: 1, race: "Persian", status: :available)
    user1 = User.create!(username: "testuser1", email: "testuser1@example.com", password: "password123")
    user2 = User.create!(username: "testuser2", email: "testuser2@example.com", password: "password123")
    
    # Test 1: First adoption makes animal pending
    adoption1 = Adoption.create!(
      animal: animal,
      user: user1,
      reason: "I love cats",
      home_type: "Apartment",
      has_yard: false,
      has_other_pets: false,
      status: :pending
    )
    
    animal.reload
    assert animal.status_pending?, "Animal should be pending with first adoption"
    
    # Test 2: Second adoption should not change status (still pending)
    adoption2 = Adoption.create!(
      animal: animal,
      user: user2,
      reason: "I also love cats",
      home_type: "House",
      has_yard: true,
      has_other_pets: false,
      status: :reviewing
    )
    
    animal.reload
    assert animal.status_pending?, "Animal should still be pending with multiple adoptions"
    
    # Test 3: Rejecting first adoption should keep animal pending (second adoption exists)
    adoption1.update!(status: :rejected)
    animal.reload
    assert animal.status_pending?, "Animal should still be pending after first adoption rejected"
    
    # Test 4: Completing second adoption should make animal adopted
    adoption2.update!(status: :completed)
    animal.reload
    assert animal.status_adopted?, "Animal should be adopted after second adoption completed"
  end
end