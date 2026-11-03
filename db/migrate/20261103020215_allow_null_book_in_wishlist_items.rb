class AllowNullBookInWishlistItems < ActiveRecord::Migration[8.1]
  def change
    change_column_null :wishlist_items, :book_id, true
  end
end
