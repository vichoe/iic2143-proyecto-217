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
      @users = User.search(@query).order(:name)
    else
      @books = @books.limit(20) unless @filters.values.any?(&:present?)
      @users = User.none
    end
 
    @books = Book.sort_by_criterion(@books, @sort) if @sort.present?
  end
 
  private
 
  def filter_params
    params.permit(:category_id, :condition, :modality, :status, :publisher, :published_year, :language)
          .to_h
          .symbolize_keys
  end
end
 