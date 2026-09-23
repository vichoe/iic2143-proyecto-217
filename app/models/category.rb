class Category < ApplicationRecord
  # No se puede borrar una categoría que todavía tiene libros.
  has_many :books, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 50 }
end
