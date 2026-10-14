class CreateWishlistItems < ActiveRecord::Migration[8.1]
  def change
    create_table :wishlist_items do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.string :author
      t.references :book, null: false, foreign_key: true

      t.timestamps
    end
  end
end
