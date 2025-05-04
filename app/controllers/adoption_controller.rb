# app/controllers/adoption_controller.rb
  class AdoptionController < ApplicationController
    # Assumes you have routes like:
    # POST /animals/:animal_id/adopt/:user_id => 'adoption#adopt_animal'
    # DELETE /animals/:animal_id/remove_adoption/:user_id => 'adoption#remove_adoption'
    # Or perhaps better, using nested resources or custom member/collection routes.

    # Consider adding before_actions to set @animal and @user
    # before_action :set_animal_and_user, only: [:adopt_animal, :remove_adoption]

    def adopt_animal
      # It might be better to get the current user from authentication (e.g., current_user)
      # instead of relying solely on params[:user_id] for security.
      @animal = Animal.find(params[:animal_id]) # Assuming route provides :animal_id
      @user = User.find(params[:user_id])     # Assuming route provides :user_id

      if @user.age < 18 # Assuming User model has an 'age' attribute
        flash[:error] = "You must be at least 18 years old to adopt an animal."
        # Redirect back or to the animal's page might be better
        redirect_to animals_path # Assumes animals_path helper exists
      elsif @animal.user.present?
        flash[:error] = "This animal is already adopted."
        redirect_to animal_path(@animal) # Assumes animal_path helper exists
      else
        @animal.user = @user
        if @animal.save
          flash[:success] = "Animal adopted successfully!"
          redirect_to user_path(@user) # Assumes user_path helper exists
        else
          flash[:error] = "Failed to adopt the animal. #{@animal.errors.full_messages.join(', ')}"
          # Render the show page of the specific animal might be more appropriate
          redirect_to animal_path(@animal) # Or render 'animals/show' if you set necessary variables
        end
      end
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Animal or User not found."
      redirect_to animals_path # Or root_path
    end

    def remove_adoption
      @animal = Animal.find(params[:animal_id]) # Assuming route provides :animal_id
      # Again, consider using an authenticated current_user
      @user = User.find(params[:user_id])     # Assuming route provides :user_id

      if @animal.user == @user
        @animal.user = nil
        if @animal.save
          flash[:success] = "Adoption removed successfully!"
          redirect_to user_path(@user) # Assumes user_path helper exists
        else
          flash[:error] = "Failed to remove adoption. #{@animal.errors.full_messages.join(', ')}"
          redirect_to animal_path(@animal) # Assumes animal_path helper exists
        end
      else
        flash[:error] = "You are not the adopter of this animal or the animal is not adopted."
        redirect_to animal_path(@animal)
      end
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Animal or User not found."
      redirect_to animals_path # Or root_path
    end

    # Example before_action (optional)
    # private
    #
    # def set_animal_and_user
    #   @animal = Animal.find(params[:animal_id])
    #   @user = User.find(params[:user_id])
    # rescue ActiveRecord::RecordNotFound
    #   flash[:error] = "Animal or User not found."
    #   redirect_to animals_path # Or root_path
    # end
  end