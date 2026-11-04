require "test_helper"

class BooksHelperTest < ActionView::TestCase
  test "calendar_weeks cubre el mes en semanas de lunes a domingo" do
    weeks = calendar_weeks(Date.new(2026, 11, 1))

    assert_equal 6, weeks.size
    assert_equal Date.new(2026, 10, 26), weeks.first.first
    assert_equal Date.new(2026, 12, 6), weeks.last.last
  end

  test "calendar_month_title muestra el mes en español" do
    assert_equal "Noviembre 2026", calendar_month_title(Date.new(2026, 11, 1))
  end
end