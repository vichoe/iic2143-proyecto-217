class Review < ApplicationRecord
  belongs_to :exchange_request
  belongs_to :reviewer, class_name: "User"
  belongs_to :reviewee, class_name: "User"

  validates :score, presence: true, inclusion: { in: 1..5 }
  validates :comment, length: { maximum: 1000 }
  # Cada participante califica una sola vez por intercambio.
  validates :reviewer_id, uniqueness: { scope: :exchange_request_id }
  validate :reviewer_is_not_reviewee
  validate :exchange_request_is_completed
  validate :both_are_participants

  private

  def reviewer_is_not_reviewee
    errors.add(:reviewee, "no puede ser uno mismo") if reviewer_id.present? && reviewer_id == reviewee_id
  end

  def exchange_request_is_completed
    return if exchange_request.nil?

    errors.add(:exchange_request, "debe estar completado") unless exchange_request.completed?
  end

  def both_are_participants
    return if exchange_request.nil?

    errors.add(:reviewer, "no participa en este intercambio") unless exchange_request.participant?(reviewer)
    errors.add(:reviewee, "no participa en este intercambio") unless exchange_request.participant?(reviewee)
  end
end
