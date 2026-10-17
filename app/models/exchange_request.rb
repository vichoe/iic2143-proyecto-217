class ExchangeRequest < ApplicationRecord
  belongs_to :requester, class_name: "User"
  belongs_to :book
  belongs_to :offered_book, class_name: "Book", optional: true

  has_many :messages, dependent: :destroy
  has_many :reviews, dependent: :destroy

  enum :status, { pending: 0, accepted: 1, rejected: 2, cancelled: 3, completed: 4 }, validate: true

  validates :message, length: { maximum: 1000 }
  validate :requester_is_not_owner
  validate :offered_book_belongs_to_requester
  validate :offered_book_required_for_exchange
  validate :book_is_available, on: :create
  validate :offered_book_is_available, on: :create
  validate :no_duplicate_pending_request, on: :create
  # El dueño del libro solicitado.
  def owner
    book.user
  end

  # true si el usuario es quien solicita o el dueño del libro.
  def participant?(user)
    user.present? && (requester_id == user.id || book.user_id == user.id)
  end

  #el dueño ACEPTA: la solicitud es aceptada y los libros involucrados quedan reservados
  #(en proceso de transacción).
  #las otras solicitudes pendientes por el mimso libro se rechazan porque ya no se pueden concretar:c
  def accept!
    transaction do 
      #si algo falla en la mitad, se deshace todo (asi no queda una soli aceptada con el libro sin reservar)
      update!(status: :accepted, responded_at: Time.current)
      book.reserved! #el '!' lanza un error si no se puede guardar en vez de quedarse piolita fallando
      offered_book&.reserved!
      notify_requester("#{owner.name} aceptó tu solicitud por \"#{book.title}\".")
      book.exchange_requests.pending.where.not(id: id).find_each(&:reject!)
    end
  end

  #el dueño RECHAZA: la solicitud queda rechazada y el libro sigue estando disponible
  def reject!
    transaction do
      update!(status: :rejected, responded_at: Time.current)
      notify_requester("#{owner.name} rechazó tu solicitud por \"#{book.title}\".")
    end 
  end

  private

  def notify_requester(text)
    Notification.create!(user: requester, book: book, message: text, read: false)
  end


  def requester_is_not_owner
    return if book.nil? || requester.nil?

    errors.add(:requester, "no puede solicitar su propio libro") if book.user_id == requester_id
  end

  def offered_book_belongs_to_requester
    return if offered_book.nil?

    errors.add(:offered_book, "debe ser un libro propio") if offered_book.user_id != requester_id
  end

  def offered_book_required_for_exchange
    return if book.nil? || !book.exchange?

    errors.add(:offered_book, "es obligatorio en un intercambio") if offered_book.nil?
  end

  def book_is_available
    return if book.nil? || book.available?

    errors.add(:book, "no está disponible")
  end

  def offered_book_is_available
    return if offered_book.nil? || offered_book.available?

    errors.add(:offered_book, "no está disponible")
  end

  def no_duplicate_pending_request
    return if book.nil? || requester.nil?
    return unless ExchangeRequest.pending.exists?(book: book, requester: requester)

    errors.add(:base, "Ya tienes una solicitud pendiente por este libro")
  end
end
