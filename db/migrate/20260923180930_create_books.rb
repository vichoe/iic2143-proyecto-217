class CreateBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :books do |t|
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.string :title, null: false
      t.string :author, null: false
      t.text :description
      t.string :publisher
      t.integer :published_year
      t.string :language
      t.integer :condition, null: false
      t.integer :modality, null: false, default: 0
      t.integer :status, null: false, default: 0

      t.timestamps
    end
    add_index :books, :status
  end
end
