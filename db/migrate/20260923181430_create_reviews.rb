class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.references :exchange_request, null: false, foreign_key: true
      t.references :reviewer, null: false, foreign_key: { to_table: :users }
      t.references :reviewee, null: false, foreign_key: { to_table: :users }
      t.integer :score, null: false
      t.text :comment

      t.timestamps
    end
    add_index :reviews, [:exchange_request_id, :reviewer_id], unique: true
  end
end
