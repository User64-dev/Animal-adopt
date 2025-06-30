require "test_helper"

class EndToEndAdoptionTest < ActionDispatch::IntegrationTest
  def setup
    # Create a user and animal for testing
    @user = User.create!(username: "endtoenduser", email: "endtoend@example.com", password: "password123")
    @animal = Animal.create!(name: "Test Pet", animal_type: "Dog", age: 3, race: "Beagle", status: :available)
  end

  test "complete adoption workflow without conflicting status updates" do
    # Step 1: Log in
    post login_path, params: { session: { username: @user.username, password: "password123" } }
    assert_redirected_to root_path
    assert_equal "Logged in successfully!", flash[:notice]
    
    # Step 2: Create an adoption application
    assert_difference 'Adoption.count', 1 do
      post animal_adoptions_path(@animal), params: {
        adoption: {
          reason: "I want to give a good home",
          home_type: "House",
          has_yard: true,
          has_other_pets: false
        }
      }
    end
    
    adoption = Adoption.last
    assert_redirected_to adoption_path(adoption)
    assert_equal "Adoption application submitted successfully!", flash[:notice]
    
    # Step 3: Verify animal status changed to pending automatically
    @animal.reload
    assert @animal.status_pending?, "Animal should be pending after adoption application"
    
    # Step 4: Test quick adopt functionality
    # Reset animal to available for this test
    adoption.destroy!
    @animal.reload
    assert @animal.status_available?, "Animal should be available after adoption destroyed"
    
    # Quick adopt the animal
    post adopt_animal_path(@animal)
    assert_redirected_to animal_path(@animal)
    assert_equal "Animal successfully adopted!", flash[:notice]
    
    # Verify the animal is now adopted
    @animal.reload
    assert @animal.status_adopted?, "Animal should be adopted after quick adopt"
    
    # Verify an adoption record was created with completed status
    completed_adoption = @animal.adoptions.completed.last
    assert_not_nil completed_adoption, "Should have a completed adoption record"
    assert_equal @user, completed_adoption.user
    assert_equal "completed", completed_adoption.status
  end

  test "adoption status remains consistent when multiple operations occur" do
    # Log in
    post login_path, params: { session: { username: @user.username, password: "password123" } }
    
    # Create an adoption application
    post animal_adoptions_path(@animal), params: {
      adoption: {
        reason: "I love pets",
        home_type: "Apartment",
        has_yard: false,
        has_other_pets: false
      }
    }
    
    adoption = Adoption.last
    @animal.reload
    assert @animal.status_pending?, "Animal should be pending after adoption"
    
    # Simulate admin approving the adoption
    adoption.update!(status: :approved)
    @animal.reload
    assert @animal.status_pending?, "Animal should still be pending when adoption is approved"
    
    # Admin completes the adoption
    adoption.update!(status: :completed)
    @animal.reload
    assert @animal.status_adopted?, "Animal should be adopted when adoption is completed"
    
    # Test that destroying the completed adoption makes animal available again
    adoption.destroy!
    @animal.reload
    assert @animal.status_available?, "Animal should be available after completed adoption is destroyed"
  end
end