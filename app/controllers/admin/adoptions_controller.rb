class Admin::AdoptionsController < Admin::ApplicationController
  before_action :set_adoption, only: [:show, :approve, :reject]

  def index
    @adoptions = Adoption.includes(:animal, :user).order(created_at: :desc)
  end

  def show
  end

  def approve
    if @adoption.update(status: :approved)
      flash[:notice] = "Adoption application approved."
    else
      flash[:alert] = "Failed to approve adoption."
    end
    redirect_to admin_adoption_path(@adoption)
  end

  def reject
    if @adoption.update(status: :rejected)
      flash[:notice] = "Adoption application rejected."
    else
      flash[:alert] = "Failed to reject adoption."
    end
    redirect_to admin_adoption_path(@adoption)
  end

  private

  def set_adoption
    @adoption = Adoption.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Adoption not found."
    redirect_to admin_adoptions_path
  end
end
