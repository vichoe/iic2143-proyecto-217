class Book < ApplicationRecord
  belongs_to :user
  belongs_to :category

  has_one_attached :cover_image
  has_many_attached :photos

  has_many :exchange_requests, dependent: :destroy
  has_many :offered_in_requests, class_name: "ExchangeRequest", foreign_key: :offered_book_id, dependent: :nullify

  # validate: true hace que un valor inválido sea un error de validación en vez de una excepción.
  enum :condition, { brand_new: 0, like_new: 1, good: 2, acceptable: 3 }, validate: true
  enum :modality, { exchange: 0, loan: 1 }, validate: true
  enum :status, { available: 0, reserved: 1, exchanged: 2, withdrawn: 3 }, validate: true

  validates :title, :author, presence: true, length: { maximum: 150 }
  validates :published_year,
            numericality: { only_integer: true, less_than_or_equal_to: Date.current.year, allow_nil: true }

  #hola isi, hola vicho
  #buscar por el titulo o autor, sin distinguir mayusculas
  #sanitize_sql escapra % y _ para desconfiar del usuario
  scope :search, lambda { |query|
    term = "%#{sanitize_sql_like(query)}%"
    where("books.title ILIKE :term OR books.author ILIKE :term", term: term)
  }
  #filtrar busqueda por opciones de libro
  scope :by_category,   ->(category_id)   { where(category_id: category_id) if category_id.present? }
  scope :by_condition,  ->(condition)     { where(condition: condition) if condition.present? }
  scope :by_modality,   ->(modality)      { where(modality: modality) if modality.present? }
  scope :by_status,     ->(status)        { where(status: status) if status.present? }
  scope :by_publisher,  ->(publisher)     { where(publisher: publisher) if publisher.present? }
  scope :by_year,       ->(published_year) { where(published_year: published_year) if published_year.present? }
  scope :by_language,   ->(language)      { where(language: language) if language.present? }
 
  #aqui hace la relacion que no hay nada segun el filtro
  def self.filter_by(filters = {})
    by_category(filters[:category_id])
      .by_condition(filters[:condition])
      .by_modality(filters[:modality])
      .by_status(filters[:status])
      .by_publisher(filters[:publisher])
      .by_year(filters[:published_year])
      .by_language(filters[:language])
  end
end
