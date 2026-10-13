class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:index]
  before_action :require_admin, only: [:index]
  before_action :set_user, only: [:show]
  # relacionado a config/application.rb
  before_action :require_profile_access, only: [:show]

  def index
    @query = params[:q].to_s.strip
    @users = User.order(:name)
    @users = @users.search(@query) if @query.present?
  end

  def show
    @books = @user.books.where(status: [:available, :reserved]).order(created_at: :desc)
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def require_admin
    return if current_user.admin?

    redirect_to root_path, alert: "Acceso exclusivo para administradores."
  end

  def require_profile_access
    return if can_view_profile?(@user)

    authenticate_user!
    redirect_to root_path, alert: "No tienes permiso para ver este perfil."
  end
end