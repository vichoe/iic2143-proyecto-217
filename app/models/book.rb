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
            numericality: { only_integer: true, less_than_or_equal_to: Date.current.year, allow_nil: true }

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
end