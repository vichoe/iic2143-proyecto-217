class ExchangeRequestsController < ApplicationController
  #se requiere inicio de sesion
  before_action :authenticate_user!
  before_action :set_book, only: [:new, :create]
  before_action :require_requestable_book, only: [:new, :create]

  def index
    @sent_requests = current_user.sent_exchange_requests
                                 .includes(:book, :offered_book)
                                 .order(created_at: :desc)
  end

  def new
    @exchange_request = @book.exchange_requests.new
    load_offerable_books
  end

  def create
    @exchange_request = @book.exchange_requests.new(exchange_request_params)
    @exchange_request.requester = current_user
    @exchange_request.offered_book = nil if @book.loan?

    if @exchange_request.save
      redirect_to @book, notice: "¡Solicitud enviada! El dueño del libro la revisará."
    else
      load_offerable_books
      render :new, status: :unprocessable_content
    end
  end

  private

  def set_book
    @book = Book.find(params[:book_id])
  end

  def require_requestable_book
    if @book.user == current_user
      redirect_to @book, alert: "No puedes solicitar tu propio libro."
    elsif !@book.available?
      redirect_to @book, alert: "Este libro no está disponible."
    end
  end

  def load_offerable_books
    @offerable_books = current_user.books.available.order(:title)
  end

  def exchange_request_params
    params.require(:exchange_request).permit(:offered_book_id, :message)
  end
end