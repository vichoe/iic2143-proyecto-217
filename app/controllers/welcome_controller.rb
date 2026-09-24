class WelcomeController < ApplicationController
  def index
    @query = params[:q].to_s.strip

    # solo mostramos libros vigentes (igual que en el perfil publico)
    @books = Book.where(status: [:available, :reserved])
                 .includes(:user)
                 .order(created_at: :desc)
    # recordar que rubocop revisa la identacion con respecto a
    # .includes y .order NO OLVIDAR

    if @query.present?
      @books = @books.search(@query)
      @users = User.search(@query).order(:name)
    else
      @books = @books.limit(20)
      @users = User.none
    end
  end
end
