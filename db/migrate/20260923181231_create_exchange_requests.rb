class CreateExchangeRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :exchange_requests do |t|
      t.references :requester, null: false, foreign_key: { to_table: :users }
      t.references :book, null: false, foreign_key: true
      t.references :offered_book, foreign_key: { to_table: :books }
      t.text :message
      t.integer :status, null: false, default: 0
      t.datetime :responded_at
      t.datetime :completed_at

      t.timestamps
    end
  end
end
