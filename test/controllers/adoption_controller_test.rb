require "test_helper"

class AdoptionControllerTest < ActionDispatch::IntegrationTest
  setup do
    @animal = animals(:one)
    @user = users(:one)
    @adoption = adoptions(:one)
  end

  test "should redirect to login when not authenticated" do
    post adopt_animal_path(@animal)
    assert_redirected_to login_path
    assert_equal "You must be logged in to perform this action", flash[:alert]
  end

  test "should quick adopt animal when authenticated" do
    # Simulate login by setting session
    post login_path, params: { session: { username: @user.username, password: "password123" } }
    follow_redirect!
    
    # Make sure animal is available
    @animal.update(status: :available)
    
    post adopt_animal_path(@animal)
    assert_redirected_to animal_path(@animal)
    assert_equal "Animal successfully adopted!", flash[:notice]
    
    @animal.reload
    assert @animal.status_adopted?, "Animal should be adopted"
  end

  test "should not adopt animal if not available" do
    # Simulate login by setting session
    post login_path, params: { session: { username: @user.username, password: "password123" } }
    follow_redirect!
    
    @animal.update(status: :adopted)
    
    post adopt_animal_path(@animal)
    assert_redirected_to animal_path(@animal)
    assert flash[:alert].present?
  end

  test "should create adoption application when authenticated" do
    # Simulate login by setting session
    post login_path, params: { session: { username: @user.username, password: "password123" } }
    follow_redirect!
    
    @animal.update(status: :available)
    
    post animal_adoptions_path(@animal), params: {
      adoption: {
        reason: "I love animals",
        home_type: "House",
        has_yard: true,
        has_other_pets: false
      }
    }
    
    assert_redirected_to adoption_path(Adoption.last)
    assert_equal "Adoption application submitted successfully!", flash[:notice]
  end

  test "should show adoption when authenticated" do
    # Simulate login by setting session
    post login_path, params: { session: { username: @user.username, password: "password123" } }
    follow_redirect!
    
    get adoption_path(@adoption)
    assert_response :success
  end

  test "should get index when authenticated" do
    # Simulate login by setting session
    post login_path, params: { session: { username: @user.username, password: "password123" } }
    follow_redirect!
    
    get adoptions_path
    assert_response :success
  end
end
