module Admin
  # Gestión de publicaciones por parte del administrador
  class BooksController < BaseController
    def index
      @books = Book.includes(:user).order(created_at: :desc)
    end

    # Igual que cuando el dueño elimina: se retira, no se borra de la base
    def destroy
      book = Book.find(params[:id])
      book.withdrawn!

      redirect_to admin_books_path,
                  notice: "Publicación \"#{book.title}\" retirada.",
                  status: :see_other
    end
  end
end