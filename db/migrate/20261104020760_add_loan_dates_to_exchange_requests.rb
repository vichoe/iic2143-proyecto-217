class AddLoanDatesToExchangeRequests < ActiveRecord::Migration[8.1]
  def change
    add_column :exchange_requests, :start_date, :date
    add_column :exchange_requests, :end_date, :date
  end
end
