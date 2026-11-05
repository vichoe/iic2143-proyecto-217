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
  validate :offered_book_is_exchange, on: :create
  validate :no_duplicate_pending_request, on: :create
  validate :loan_dates_are_valid, on: :create
  validate :loan_dates_are_free, on: :create

  # Solicitudes cuyo periodo se cruza con el periodo [from, to]
  scope :overlapping, lambda { |from, to|
    where("exchange_requests.start_date <= ? AND exchange_requests.end_date >= ?", to, from)
  }

  # El dueño del libro solicitado.
  def owner
    book.user
  end

  # true si el usuario es quien solicita o el dueño del libro.
  def participant?(user)
    user.present? && (requester_id == user.id || book.user_id == user.id)
  end

  def accept!
    transaction do
      # si algo falla en la mitad, se deshace todo
      update!(status: :accepted, responded_at: Time.current)
      notify_requester("#{owner.name} aceptó tu solicitud por \"#{book.title}\".")

      if dated_loan?
        # préstamo con fechas: el libro sigue disponible, solo se rechazan las pendientes que se cruzan
        book.exchange_requests.pending.where.not(id: id).overlapping(start_date, end_date).find_each(&:reject!)
      else
        # intercambio (o préstamo antiguo sin fechas): se reserva el libro y se rechazan todas las pendientes
        book.reserved!
        offered_book&.reserved!
        book.exchange_requests.pending.where.not(id: id).find_each(&:reject!)
      end
    end
  end

  # true si es un préstamo con periodo de fechas
  def dated_loan?
    book.loan? && start_date.present? && end_date.present?
  end

  #el dueño RECHAZA: la solicitud queda rechazada y el libro sigue estando disponible
  def reject!
    transaction do
      update!(status: :rejected, responded_at: Time.current)
      notify_requester("#{owner.name} rechazó tu solicitud por \"#{book.title}\".")
    end 
  end

  #se marca como CONCLUIDO cuando la entrega (o la devolución) ya ocurrió
  #intercambio: los libros cambiaron de mano y no se vuelven a publicar
  #préstamo: el libro se devolvió, así que vuelve a estar disponible
  def complete!
    transaction do
      update!(status: :completed, completed_at: Time.current)
      if book.exchange?
        book.exchanged!
        offered_book&.exchanged!
      else
        book.available!
      end
    end
  end



  #MENSAJERIA NUEVO
  #la conversacion provada se habilita cuando la solicitud fue aceptada (o ya se completó)
  def chat_open?
    accepted? || completed?
  end

  #solo dos participantes pueden ver y escribir en la conversación
  def chat_open_for?(user)
    chat_open? && participant?(user)
  end 

  #solo se envian mensajes cuando el intercambio esta en proceso
  def chat_writable?
    accepted?
  end

  #la otra persona de la conversación (si soy quien pidió, el dueño; y al revés)
  def other_participant(user)
    requester == user ? owner : requester 
  end

  # e puede calificar si el intercambio concluyo, el usuario participó y todavía no calificoo
  def can_be_reviewed_by?(user)
    completed? && participant?(user) && !reviews.exists?(reviewer: user)
  end

  private

  def loan_dates_are_free
    return if book.nil? || !book.loan? || start_date.blank? || end_date.blank?
    return unless book.exchange_requests.accepted.overlapping(start_date, end_date).exists?

    errors.add(:base, "Esas fechas ya están reservadas por otra persona")
  end

  def loan_dates_are_valid
    return if book.nil? || !book.loan?

    if start_date.blank? || end_date.blank?
      errors.add(:base, "Debes indicar las fechas de inicio y término del préstamo")
    elsif end_date < start_date
      errors.add(:end_date, "debe ser igual o posterior a la fecha de inicio")
    elsif start_date < Date.current
      errors.add(:start_date, "no puede ser una fecha pasada")
    elsif book.available_from.present? &&
          (start_date < book.available_from || end_date > book.available_until)
      errors.add(:base, "Las fechas deben estar dentro del periodo disponible del libro")
    end
  end

  def offered_book_is_exchange
    return if offered_book.nil? || offered_book.exchange?

    errors.add(
      :offered_book,
      "debe tener modalidad de intercambio; no puede ser un préstamo"
    )
  end

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
