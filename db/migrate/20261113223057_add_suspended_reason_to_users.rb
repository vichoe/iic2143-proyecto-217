class AddSuspendedReasonToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :suspended_reason, :text
  end
end