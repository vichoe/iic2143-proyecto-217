class Message < ApplicationRecord
  belongs_to :exchange_request
  belongs_to :sender, class_name: "User"

  #Orden cronológico: del más antiguo al más nuevo
  scope :chronological, -> { order(:created_at, :id) }

  validates :body, presence: true, length: { maximum: 2000 }
  validate :sender_is_participant
  validate :conversation_is_open, on: :create

  private

  def sender_is_participant
    return if exchange_request.nil? || sender.nil?
    errors.add(:sender, "no participa en este intercambio") unless exchange_request.participant?(sender)
  end

  def conversation_is_open
    return if exchange_request.nil? || exchange_request.chat_writable?
    errors.add(:base, "Solo puedes enviar mensajes mientras el intercambio está en proceso")
  end
end
