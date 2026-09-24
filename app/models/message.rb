class Message < ApplicationRecord
  belongs_to :exchange_request
  belongs_to :sender, class_name: "User"

  validates :body, presence: true, length: { maximum: 2000 }
  validate :sender_is_participant

  private

  def sender_is_participant
    return if exchange_request.nil? || sender.nil?

    errors.add(:sender, "no participa en este intercambio") unless exchange_request.participant?(sender)
  end
end
