class WelcomeController < ApplicationController
  def index
    @query = params[:q].to_s.strip
    @user_query = params[:user_q].to_s.strip
    @filters = filter_params
    @sort = params[:sort].presence

    # Filtrar antes de organizar los estantes.
    @books = Book.where(status: [:available, :reserved])
                 .includes(:user, :category)
                 .with_attached_cover_image
                 .order(created_at: :desc)

    @books = @books.filter_by(@filters)
    @books = @books.search(@query) if @query.present?
    @books = Book.sort_by_criterion(@books, @sort) if @sort.present?

    @books_by_category = @books.to_a
                               .group_by(&:category)
                               .sort_by { |category, _books| category.name.downcase }
    
    # filtro de usuarios (si es que esta activado)
    @users = if can_search_users? && @user_query.present?
               User.search(@user_query).order(:name)
             else
               User.none
             end
  end

  private

  def filter_params
    params.permit(:category_id, :condition, :modality, :status, :publisher, :year_from, :year_to, :language)
          .to_h
          .symbolize_keys
  end
end