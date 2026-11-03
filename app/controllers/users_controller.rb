class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:index, :suspend, :reactivate]
  before_action :require_admin, only: [:index, :suspend, :reactivate]
  before_action :set_user, only: [:show, :suspend, :reactivate]
  # relacionado a config/application.rb
  before_action :require_profile_access, only: [:show]
  before_action :prevent_self_suspension, only: [:suspend]

  def index
    @query = params[:q].to_s.strip
    @users = User.order(:name)
    @users = @users.search(@query) if @query.present?
  end

  def show
    @books = @user.books.where(status: [:available, :reserved])
                  .order(created_at: :desc)
  end

  def suspend
    @user.update!(suspended_at: @user.suspended_at || Time.current)

    redirect_to users_path,
                notice: "Usuario suspendido correctamente.",
                status: :see_other
  end

  def reactivate
    @user.update!(suspended_at: nil)

    redirect_to users_path,
                notice: "Usuario reactivado correctamente.",
                status: :see_other
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def require_admin
    return if current_user.admin?

    redirect_to root_path, alert: "Acceso exclusivo para administradores."
  end

  def prevent_self_suspension
    return unless @user == current_user

    redirect_to users_path,
                alert: "No puedes suspender tu propia cuenta.",
                status: :see_other
  end

  def require_profile_access
    return if can_view_profile?(@user)

    authenticate_user!
    redirect_to root_path, alert: "No tienes permiso para ver este perfil."
  end
end