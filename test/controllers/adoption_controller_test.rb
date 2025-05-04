require "test_helper"

class AdoptionControllerTest < ActionDispatch::IntegrationTest
  setup do
    @animal = animals(:one)
    @user = users(:one)
  end

  test "should adopt animal" do
    post adopt_animal_url(@animal, user_id: @user.id)
    assert_redirected_to user_url(@user)
    assert_equal "Animal adopted successfully!", flash[:success]
    @animal.reload
    assert_equal @user, @animal.user
  end

  test "should not adopt animal if under 18" do
    @user.update(age: 17)
    post adopt_animal_url(@animal, user_id: @user.id)
    assert_redirected_to animals_url
    assert_equal "You must be at least 18 years old to adopt an animal.", flash[:error]
  end

  test "should not adopt already adopted animal" do
    @animal.update(user: @user)
    post adopt_animal_url(@animal, user_id: users(:two).id)
    assert_redirected_to animal_url(@animal)
    assert_equal "This animal is already adopted.", flash[:error]
  end

  test "should remove adoption" do
    @animal.update(user: @user)
    delete remove_adoption_url(@animal, user_id: @user.id)
    assert_redirected_to user_url(@user)
    assert_equal "Adoption removed successfully!", flash[:success]
    @animal.reload
    assert_nil @animal.user
  end

  test "should not remove adoption if not adopter" do
    @animal.update(user: users(:two))
    delete remove_adoption_url(@animal, user_id: @user.id)
    assert_redirected_to animal_url(@animal)
    assert_equal "You are not the adopter of this animal or the animal is not adopted.", flash[:error]
  end
end
