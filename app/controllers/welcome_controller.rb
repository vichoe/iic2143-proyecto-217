class WelcomeController < ApplicationController
  def index
    @query = params[:q].to_s.strip
    @filters = filter_params
    @sort = params[:sort].presence
 
    # solo mostramos libros vigentes (igual que en el perfil publico)
    @books = Book.where(status: [:available, :reserved])
                 .includes(:user)
                 .order(created_at: :desc)
    # recordar que rubocop revisa la identacion con respecto a
    # .includes y .order NO OLVIDAR
 
    @books = @books.filter_by(@filters)
 
    if @query.present?
      @books = @books.search(@query)

      if user_signed_in? && current_user.admin?
        @users = User.search(@query).order(:name)
      else
        @users = User.none
      end
    else
      @books = @books.limit(20)
      @users = User.none
    end
 
  private
 
  def filter_params
    params.permit(:category_id, :condition, :modality, :status, :publisher, :published_year, :language)
          .to_h
          .symbolize_keys
  end
end
 