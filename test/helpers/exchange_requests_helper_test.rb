require "test_helper"

class ExchangeRequestsHelperTest < ActionView::TestCase
  test "loan_period_label muestra las fechas del préstamo" do
    request = ExchangeRequest.new(start_date: Date.new(2026, 11, 10), end_date: Date.new(2026, 11, 15))
    assert_equal "préstamo (del 10-11-2026 al 15-11-2026)", loan_period_label(request)
  end

  test "loan_period_label sin fechas dice solo préstamo" do
    assert_equal "préstamo", loan_period_label(ExchangeRequest.new)
  end

  test "request_status_label traduce el estado" do
    assert_equal "Pendiente", request_status_label(ExchangeRequest.new(status: :pending))
  end
end