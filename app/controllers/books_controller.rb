class BooksController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]

  def show
    @book = Book.find(params[:id])
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

  private

  def book_params
    params.require(:book).permit(:title, :author, :description, :publisher, :published_year, :language,
                                 :category_id, :condition, :modality, :cover_image, photos: [])
  end
end