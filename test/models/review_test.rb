require "test_helper"

class ReviewTest < ActiveSupport::TestCase
  test "el fixture es válido" do
    assert reviews(:ana_reviews_beto).valid?
  end

  test "el puntaje debe estar entre 1 y 5" do
    review = reviews(:ana_reviews_beto)
    review.score = 6
    assert_not review.valid?
    review.score = 0
    assert_not review.valid?
  end

  test "cada participante califica una sola vez por intercambio" do
    duplicate = Review.new(exchange_request: exchange_requests(:ana_borrowed_foundation),
                           reviewer: users(:ana), reviewee: users(:beto), score: 4)
    assert_not duplicate.valid?
  end

  test "la otra parte sí puede calificar" do
    review = Review.new(exchange_request: exchange_requests(:ana_borrowed_foundation),
                        reviewer: users(:beto), reviewee: users(:ana), score: 4)
    assert review.valid?
  end

  test "solo se califica un intercambio completado" do
    review = Review.new(exchange_request: exchange_requests(:beto_wants_hobbit),
                        reviewer: users(:beto), reviewee: users(:ana), score: 5)
    assert_not review.valid?
    assert review.errors.key?(:exchange_request)
  end

  test "no se puede calificar a uno mismo" do
    review = Review.new(exchange_request: exchange_requests(:ana_borrowed_foundation),
                        reviewer: users(:ana), reviewee: users(:ana), score: 5)
    assert_not review.valid?
  end
end
