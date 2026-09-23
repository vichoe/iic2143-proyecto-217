class User < ApplicationRecord
  # Módulos de Devise: login con email/contraseña, registro,
  # recuperar contraseña, "recordarme" y validaciones de email/contraseña.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :avatar

  has_many :books, dependent: :destroy
  has_many :sent_exchange_requests, class_name: "ExchangeRequest", foreign_key: :requester_id, dependent: :destroy
  has_many :sent_messages, class_name: "Message", foreign_key: :sender_id, dependent: :destroy
  has_many :written_reviews, class_name: "Review", foreign_key: :reviewer_id, dependent: :destroy
  has_many :received_reviews, class_name: "Review", foreign_key: :reviewee_id, dependent: :destroy

  validates :name, presence: true, length: { maximum: 50 }
  validates :bio, length: { maximum: 500 }

  def suspended?
    suspended_at.present?
  end

  # Nota del perfil: promedio de las reseñas recibidas (nil si no tiene).
  def average_rating
    received_reviews.average(:score)&.round(1)
  end
end
