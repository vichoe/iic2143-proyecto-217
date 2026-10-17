class ExchangeRequestsController < ApplicationController
  #se requiere inicio de sesion
  before_action :authenticate_user!
  before_action :set_book, only: [:new, :create]
  before_action :require_requestable_book, only: [:new, :create]
  #nueo
  before_action :set_received_request, only: [:accept, :reject]

  def index
    @sent_requests = current_user.sent_exchange_requests
                                 .includes(:book, :offered_book)
                                 .order(created_at: :desc)
    #nueo
    @received_requests = current_user.received_exchange_requests
                                     .includes(:book, :requester, :offered_book)
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

  #nueo
  def accept
    if @exchange_request.book.available?
      @exchange_request.accept!
      redirect_to exchange_requests_path,
                  notice: "Aceptaste la solicitud. Le avisamos a #{@exchange_request.requester.name}."
    else
      redirect_to exchange_requests_path, alert: "El libro ya no está disponible."
    end
  end

  def reject
    @exchange_request.reject!
    redirect_to exchange_requests_path,
                notice: "Rechazaste la solicitud. Le avisamos a #{@exchange_request.requester.name}."
  end

  private

  #nueo
  #solo el dueño del libro puede responder (las solicitudes pendientes)
  def set_received_request
    @exchange_request = current_user.received_exchange_requests.find_by(id: params[:id])

    if @exchange_request.nil?
      redirect_to exchange_requests_path, alert: "No encontramos esa solicitud."
    elsif !@exchange_request.pending?
      redirect_to exchange_requests_path, alert: "Esta solicitud ya fue respondida."
    end
  end

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