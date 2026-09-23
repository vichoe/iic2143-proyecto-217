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

  # El dueño del libro solicitado.
  def owner
    book.user
  end

  # true si el usuario es quien solicita o el dueño del libro.
  def participant?(user)
    user.present? && (requester_id == user.id || book.user_id == user.id)
  end

  private

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
end
