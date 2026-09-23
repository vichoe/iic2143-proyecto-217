class Book < ApplicationRecord
  belongs_to :user
  belongs_to :category

  has_one_attached :cover_image
  has_many_attached :photos

  # validate: true hace que un valor inválido sea un error de validación en vez de una excepción.
  enum :condition, { brand_new: 0, like_new: 1, good: 2, acceptable: 3 }, validate: true
  enum :modality, { exchange: 0, loan: 1 }, validate: true
  enum :status, { available: 0, reserved: 1, exchanged: 2, withdrawn: 3 }, validate: true

  validates :title, :author, presence: true, length: { maximum: 150 }
  validates :published_year,
            numericality: { only_integer: true, less_than_or_equal_to: Date.current.year, allow_nil: true }
end
