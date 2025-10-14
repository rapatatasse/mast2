class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.all.order(created_at: :desc)
  end

  def show
    @clients_count = @user.clients.count
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'Utilisateur mis à jour avec succès.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user == current_user
      redirect_to users_path, alert: 'Vous ne pouvez pas supprimer votre propre compte.'
    else
      @user.destroy
      redirect_to users_path, notice: 'Utilisateur supprimé avec succès.'
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :nom, :prenom)
  end
end
