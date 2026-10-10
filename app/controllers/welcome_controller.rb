
class WelcomeController < ApplicationController
  def index
    @query = params[:q].to_s.strip
    @filters = filter_params
    @sort = params[:sort].presence

    #mostrar solamente libros vigentes
    @books = Book.where(status: [:available, :reserved])
                 .includes(:user)
                 .order(created_at: :desc)

    #aplicar filtros de libros
    @books = @books.filter_by(@filters)

    if @query.present?
      # Buscar libros para todos los usuarios
      @books = @books.search(@query)

      #buscar usuarios solamente si es administrador
      if user_signed_in? && current_user.admin?
        @users = User.search(@query).order(:name)
      else
        @users = User.none
      end
    else
      #limitar publicaciones cuando no hay filtros
      @books = @books.limit(20) unless @filters.values.any?(&:present?)
      @users = User.none
    end

    #aplicar ordenamiento seleccionado
    @books = Book.sort_by_criterion(@books, @sort) if @sort.present?
  end

  private

  def filter_params
    params.permit(:category_id, :condition, :modality, :status, :publisher, :published_year, :language)
          .to_h
          .symbolize_keys
  end
end
