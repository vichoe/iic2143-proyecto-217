class AddWithdrawnReasonToBooks < ActiveRecord::Migration[8.1]
  def change
    add_column :books, :withdrawn_reason, :text
  end
end