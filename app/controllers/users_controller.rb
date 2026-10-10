
class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin, only: [:index]

  def index
    @query= params[:q].to_s.strip

    @users= User.order(:name)

    if @query.present?
      @users = @users.search(@query)
    end
  end

  def show
    @user= User.find(params[:id])

    unless current_user.admin? || current_user == @user
      redirect_to root_path, alert: "No tienes permiso para ver este perfil."
      return
    end

    @books= @user.books
                  .where(status: [:available, :reserved])
                  .order(created_at: :desc)
  end

  private

  def require_admin
    unless current_user.admin?
      redirect_to root_path, alert: "Acceso exclusivo para administradores."
    end
  end
end
