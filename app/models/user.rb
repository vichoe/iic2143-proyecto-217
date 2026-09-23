class User < ApplicationRecord
  # Módulos de Devise: login con email/contraseña, registro,
  # recuperar contraseña, "recordarme" y validaciones de email/contraseña.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :avatar

  has_many :books, dependent: :destroy

  validates :name, presence: true, length: { maximum: 50 }
  validates :bio, length: { maximum: 500 }

  def suspended?
    suspended_at.present?
  end
end
