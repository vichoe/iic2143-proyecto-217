class WishlistItem < ApplicationRecord
  belongs_to :user
  belongs_to :book, optional: true

  validates :title, :author, presence: true, length: { maximum: 150 }
end