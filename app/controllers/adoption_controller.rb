# app/controllers/adoption_controller.rb
# This controller handles the adoption process for animals in the system.
#
# @note Requires user authentication for all actions
#
# Actions:
# - index: Lists all adoptions for the current user
# - show: Displays details of a specific adoption
# - new: Initiates a new adoption application if animal is available
# - create: Processes and saves a new adoption application
# - destroy: Withdraws an existing adoption application
#
# Before actions:
# - authenticate_user!: Ensures user is logged in
# - set_animal: Loads the animal for new/create/destroy actions
# - set_adoption: Loads the adoption for show/destroy actions
#
# @example Creating a new adoption
#   POST /animals/:animal_id/adoptions
#   params: {
#     adoption: {
#       reason: "Love animals",
#       home_type: "House",
#       has_yard: true,
#       has_other_pets: false,
#       other_pets_description: nil
#     }
#   }
#
# @see Animal
# @see Adoption
class AdoptionController < ApplicationController
  before_action :authenticate_user!
  before_action :set_animal, only: [:new, :create, :destroy, :quick_adopt, :quick_remove]
  before_action :set_adoption, only: [:show, :destroy]

  def index
    @adoptions = current_user.adoptions
  end

  def show
  end

  def new
    if @animal.available?
      @adoption = Adoption.new
    else
      flash[:alert] = "This animal is not available for adoption."
      redirect_to animal_path(@animal)
    end
  end

  def create
    @adoption = Adoption.new(adoption_params)
    @adoption.animal = @animal
    @adoption.user = current_user

    if @animal.available?
      if @adoption.save
        # Update animal status to pending
        @animal.update(status: :pending)
        flash[:notice] = "Adoption application submitted successfully!"
        redirect_to adoption_path(@adoption)
      else
        flash[:alert] = "Failed to submit adoption application. #{@adoption.errors.full_messages.join(', ')}"
        render :new
      end
    else
      flash[:alert] = "This animal is not available for adoption."
      redirect_to animal_path(@animal)
    end
  end

  def destroy
    if @adoption.user == current_user && @adoption.pending?
      @animal = @adoption.animal
      
      if @adoption.destroy
        # Make the animal available again
        @animal.update(status: :available)
        flash[:notice] = "Adoption application withdrawn successfully."
      else
        flash[:alert] = "Failed to withdraw application."
      end
      redirect_to animal_path(@animal)
    else
      flash[:alert] = "You cannot withdraw this adoption application."
      redirect_to adoptions_path
    end
  end

  private

  def set_animal
    @animal = Animal.find(params[:animal_id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Animal not found."
    redirect_to animals_path
  end

  def set_adoption
    @adoption = Adoption.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Adoption not found."
    redirect_to adoptions_path
  end

  def adoption_params
    params.require(:adoption).permit(
      :reason, :home_type, :has_yard, :has_other_pets, :other_pets_description
    )
  end
  
  # Quick adopt method for one-click adoptions from animal show page
  def quick_adopt
    # Check if animal is available
    if @animal.available?
      @adoption = Adoption.new(
        animal: @animal,
        user: current_user,
        reason: "Quick adoption"
      )
      
      if @adoption.save
        # Update animal status to pending or adopted based on your business logic
        @animal.update(status: :pending)
        flash[:notice] = "You have applied to adopt this animal!"
      else
        flash[:alert] = "Failed to adopt animal: #{@adoption.errors.full_messages.join(', ')}"
      end
    else
      flash[:alert] = "This animal is not available for adoption."
    end
    
    redirect_to animal_path(@animal)
  end
  
  # Quick remove method for cancelling adoptions from animal show page
  def quick_remove
    adoption = current_user.adoptions.find_by(animal_id: @animal.id)
    
    if adoption
      if adoption.destroy
        @animal.update(status: :available)
        flash[:notice] = "Adoption cancelled successfully."
      else
        flash[:alert] = "Failed to cancel adoption."
      end
    else
      flash[:alert] = "No adoption found for this animal."
    end
    
    redirect_to animal_path(@animal)
  end
end