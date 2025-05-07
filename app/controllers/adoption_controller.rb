# app/controllers/adoption_controller.rb
  class AdoptionController < ApplicationController
    # Assumes you have routes like:
    # POST /animals/:animal_id/adopt/:user_id => 'adoption#adopt_animal'
    # DELETE /animals/:animal_id/remove_adoption/:user_id => 'adoption#remove_adoption'
    # Or perhaps better, using nested resources or custom member/collection routes.

    # Consider adding before_actions to set @animal and @user
    # before_action :set_animal_and_user, only: [:adopt_animal, :remove_adoption]

    def adopt_animal
      # Get the current animal from the route parameter
      @animal = Animal.find(params[:id]) # Using :id from the member route

      # Use the current logged-in user instead of from params for security
      @user = current_user

      if !logged_in?
        flash[:alert] = "You must be logged in to adopt an animal."
        redirect_to login_path
      elsif @animal.user.present?
        flash[:alert] = "This animal is already adopted."
        redirect_to animal_path(@animal)
      else
        @animal.user = @user
        if @animal.save
          flash[:notice] = "Animal adopted successfully!"
          redirect_to user_path(@user)
        else
          flash[:alert] = "Failed to adopt the animal. #{@animal.errors.full_messages.join(', ')}"
          redirect_to animal_path(@animal)
          redirect_to animal_path(@animal) # Or render 'animals/show' if you set necessary variables
        end
      end
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Animal or User not found."
      redirect_to animals_path # Or root_path
    end

    def remove_adoption
      @animal = Animal.find(params[:id]) # Using :id from the member route
      @user = current_user

      if !logged_in?
        flash[:alert] = "You must be logged in to remove an adoption."
        redirect_to login_path
      elsif @animal.user != @user
        flash[:alert] = "You are not the adopter of this animal or the animal is not adopted."
        redirect_to animal_path(@animal)
      else
        @animal.user = nil
        if @animal.save
          flash[:notice] = "Adoption removed successfully!"
          redirect_to user_path(@user)
        else
          flash[:alert] = "Failed to remove adoption. #{@animal.errors.full_messages.join(', ')}"
          redirect_to animal_path(@animal)
        end
      end
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = "Animal not found."
      redirect_to animals_path
    end
    
  private
  
    def set_animal_and_user
      @animal = Animal.find(params[:id])
      @user = current_user
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