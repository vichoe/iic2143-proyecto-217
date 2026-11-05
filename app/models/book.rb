class Book < ApplicationRecord
  belongs_to :user
  belongs_to :category

  has_one_attached :cover_image
  has_many_attached :photos

  has_many :exchange_requests, dependent: :destroy
  has_many :offered_in_requests, class_name: "ExchangeRequest", foreign_key: :offered_book_id, dependent: :nullify

  has_many :wishlist_items, dependent: :nullify

  enum :condition, { brand_new: 0, like_new: 1, good: 2, acceptable: 3 }, validate: true
  enum :modality, { exchange: 0, loan: 1 }, validate: true
  enum :status, { available: 0, reserved: 1, exchanged: 2, withdrawn: 3 }, validate: true
  enum :language, { spanish: "es", english: "en", other: "other" }, prefix: true, validate: { allow_nil: true }

  validates :title, :author, presence: true, length: { maximum: 150 }
  validates :published_year,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 1,
              less_than_or_equal_to: ->(_book) { Date.current.year }
            },
            allow_blank: true
  validates :available_from, :available_until, presence: true, on: :create, if: :loan?
  # presence: true: el campo no puede venir vacío.
  # on: :create: solo se revisa al crear el libro, no al editarlo
  # ni al cambiarle el estado con available! o reserved!.
  # Por eso los libros antiguos no se rompen.
  # if: :loan?: solo aplica si la modalidad es préstamo. 
  # loan? existe gracias al enum :modality que ya tienen en el modelo.

  validate :available_until_after_from
  before_validation :clear_dates_unless_loan

  scope :search, lambda { |query|
    term = "%#{sanitize_sql_like(query)}%"
    where("books.title ILIKE :term OR books.author ILIKE :term", term: term)
  }

  scope :by_category,  ->(category_id) { where(category_id: category_id) if category_id.present? }
  scope :by_condition, ->(condition) { where(condition: condition) if condition.present? }
  scope :by_modality,  ->(modality) { where(modality: modality) if modality.present? }
  scope :by_status,    ->(status) { where(status: status) if status.present? }
  scope :by_language,  ->(language) { where(language: language) if language.present? }
  scope :by_year_from, ->(year) { where(published_year: year.to_i..) if year.present? }
  scope :by_year_to,   ->(year) { where(published_year: ..year.to_i) if year.present? }
  scope :by_publisher, lambda { |publisher|
    where("books.publisher ILIKE ?", "%#{sanitize_sql_like(publisher)}%") if publisher.present?
  }

  def self.filter_by(filters = {})
    by_category(filters[:category_id])
      .by_condition(filters[:condition])
      .by_modality(filters[:modality])
      .by_status(filters[:status])
      .by_publisher(filters[:publisher])
      .by_year_from(filters[:year_from])
      .by_year_to(filters[:year_to])
      .by_language(filters[:language])
  end

  def self.sort_by_criterion(books, criterion)
    case criterion.to_s
    when "title"
      books.reorder(Arel.sql("LOWER(books.title) ASC"))
    when "rating"
      books.left_joins(user: :received_reviews)
           .group("books.id", "users.id")
           .reorder(Arel.sql("COALESCE(AVG(reviews.score), 0) DESC, books.created_at DESC"))
    else
      books
    end
  end

  # Periodos [inicio, fin] de los préstamos aceptados de este libro
  def reserved_periods
    exchange_requests.accepted.where.not(start_date: nil).pluck(:start_date, :end_date)
  end

  # Estado de un día en el calendario: :past, :unavailable, :reserved o :available
  def availability_on(date, reserved = reserved_periods)
    return :past if date < Date.current
    return :unavailable if available_from.present? && !date.between?(available_from, available_until)
    return :reserved if reserved.any? { |from, to| date.between?(from, to) }

    :available
  end

  private

  def available_until_after_from
    return if available_from.blank? || available_until.blank?

    if available_until < available_from
      errors.add(:available_until, "debe ser igual o posterior a la fecha de inicio")
    end
  end

  def clear_dates_unless_loan
    return if loan?

    self.available_from = nil
    self.available_until = nil
  end
end