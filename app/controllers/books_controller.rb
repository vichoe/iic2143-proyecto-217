class BooksController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :set_book, only: [:show, :edit, :update, :destroy]
  before_action :require_owner, only: [:edit, :update, :destroy]

  def show
  end

  def new
    @book = Book.new
  end

  def create
    @book = current_user.books.new(book_params)

    if @book.save
      redirect_to @book, notice: "¡Libro publicado!"
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @book.update(update_params)
      redirect_to @book, notice: "Publicación actualizada."
    else
      render :edit, status: :unprocessable_content
    end
  end

  # No borramos el libro de la base de datos: lo marcamos como "retirado".
  # Así no se pierden los intercambios ni las reseñas asociadas a él.
  def destroy
    @book.withdrawn!
    redirect_to user_path(current_user), notice: "Publicación eliminada."
  end

  private

  def set_book
    @book = Book.find(params[:id])
  end

  def require_owner
    return if @book.user == current_user

    redirect_to @book, alert: "Solo el dueño puede modificar esta publicación."
  end

  def book_params
    params.require(:book).permit(:title, :author, :description, :publisher, :published_year, :language,
                                 :category_id, :condition, :modality, :cover_image, photos: [])
  end

  # Al editar, si no se eligen fotos nuevas se mantienen las que ya tenía.
  def update_params
    permitted = book_params
    permitted.delete(:cover_image) if permitted[:cover_image].blank?
    permitted.delete(:photos) if Array(permitted[:photos]).compact_blank.empty?
    permitted
  end
end