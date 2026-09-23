require "test_helper"

class ExchangeRequestTest < ActiveSupport::TestCase
  test "los fixtures son válidos" do
    assert exchange_requests(:beto_wants_hobbit).valid?
    assert exchange_requests(:ana_borrowed_foundation).valid?
  end

  test "owner es el dueño del libro solicitado" do
    assert_equal users(:ana), exchange_requests(:beto_wants_hobbit).owner
  end

  test "no se puede solicitar un libro propio" do
    request = ExchangeRequest.new(requester: users(:ana), book: books(:hobbit), offered_book: books(:hobbit))
    assert_not request.valid?
    assert request.errors.key?(:requester)
  end

  test "el libro ofrecido debe ser del solicitante" do
    request = ExchangeRequest.new(requester: users(:carla), book: books(:hobbit), offered_book: books(:dune))
    assert_not request.valid?
    assert request.errors.key?(:offered_book)
  end

  test "un intercambio exige ofrecer un libro" do
    request = ExchangeRequest.new(requester: users(:beto), book: books(:hobbit))
    assert_not request.valid?
    assert request.errors.key?(:offered_book)
  end

  test "un préstamo no exige ofrecer un libro" do
    request = ExchangeRequest.new(requester: users(:carla), book: books(:foundation))
    assert request.valid?
    assert request.pending?
  end

  test "participant? reconoce a solicitante y dueño" do
    request = exchange_requests(:beto_wants_hobbit)
    assert request.participant?(users(:beto))
    assert request.participant?(users(:ana))
    assert_not request.participant?(users(:carla))
  end
end
