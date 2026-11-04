require "test_helper"

# Calendario de préstamos: fechas del libro y de cada solicitud
class LoanCalendarTest < ActiveSupport::TestCase
  setup do
    @book = books(:foundation) # préstamo de Beto
    @book.update!(available_from: Date.current, available_until: Date.current + 30)
    @start = Date.current + 5
  end

  def loan_request(requester, from, to, status: :pending)
    ExchangeRequest.new(requester: users(requester), book: @book, start_date: from, end_date: to, status: status)
  end

  test "la fecha hasta del libro no puede ser anterior a desde" do
    @book.available_until = @book.available_from - 1
    assert_not @book.valid?
  end

  test "un préstamo exige fechas" do
    assert_not loan_request(:carla, nil, nil).valid?
  end

  test "la fecha de término no puede ser anterior al inicio" do
    assert_not loan_request(:carla, @start, @start - 1).valid?
  end

  test "no se puede pedir en fechas pasadas" do
    assert_not loan_request(:carla, Date.current - 2, @start).valid?
  end

  test "las fechas deben estar dentro del periodo del libro" do
    assert_not loan_request(:carla, @start, Date.current + 40).valid?
  end

  test "no se puede pedir un periodo cruzado con un préstamo aceptado" do
    loan_request(:ana, @start, @start + 4, status: :accepted).save!
    assert_not loan_request(:carla, @start + 2, @start + 6).valid?
  end

  test "sí se puede pedir un periodo libre" do
    loan_request(:ana, @start, @start + 4, status: :accepted).save!
    assert loan_request(:carla, @start + 5, @start + 8).valid?
  end

  test "aceptar un préstamo deja el libro disponible y rechaza solo las pendientes cruzadas" do
    first = loan_request(:ana, @start, @start + 4)
    first.save!
    crossing = loan_request(:carla, @start + 2, @start + 6)
    crossing.save!

    first.accept!

    assert @book.reload.available?
    assert crossing.reload.rejected?
  end

  test "availability_on distingue los cuatro estados" do
    loan_request(:carla, @start, @start + 2, status: :accepted).save!

    assert_equal :past, @book.availability_on(Date.current - 1)
    assert_equal :unavailable, @book.availability_on(Date.current + 40)
    assert_equal :reserved, @book.availability_on(@start + 1)
    assert_equal :available, @book.availability_on(@start + 10)
  end
end