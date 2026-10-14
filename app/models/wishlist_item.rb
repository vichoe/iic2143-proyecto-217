class WishlistItem < ApplicationRecord
  belongs_to :user
  belongs_to :book, optional: true

  validates :title, presence: true
  validates :author, presence: true
end