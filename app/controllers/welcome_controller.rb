class WelcomeController < ApplicationController
  def index
    @query = params[:q].to_s.strip
    @user_query = params[:user_q].to_s.strip
    @filters = filter_params
    @sort = params[:sort].presence

    # filtro de libros
    @books = Book.where(status: [:available, :reserved]).includes(:user).order(created_at: :desc)
    @books = @books.filter_by(@filters)
    @books = @books.search(@query) if @query.present?
    # si no mostrar 20 publicaciones recientes
    @books = @books.limit(20) unless @query.present? || @filters.values.any?(&:present?)
    @books = Book.sort_by_criterion(@books, @sort) if @sort.present?

    # filtro de usuarios (si es que esta activado)
    @users = if can_search_users? && @user_query.present?
               User.search(@user_query).order(:name)
             else
               User.none
             end
  end

  private

  def filter_params
    params.permit(:category_id, :condition, :modality, :status, :publisher, :published_year, :language)
          .to_h
          .symbolize_keys
  end
end