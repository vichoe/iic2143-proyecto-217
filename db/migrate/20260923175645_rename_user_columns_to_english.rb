class RenameUserColumnsToEnglish < ActiveRecord::Migration[8.1]
  def change
    rename_column :users, :nombre, :name
    rename_column :users, :ciudad, :city
    rename_column :users, :suspendido, :suspended_at
  end
end
