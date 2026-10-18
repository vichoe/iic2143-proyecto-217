require "test_helper"

class ReviewsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  #Ana pidio prestado Fundacion (de Beto) el intercambio ya concluyo
  #y Ana ya califico a Beto (fixture ana_reviews_beto)
  #Falta que Beto califique a Ana.
  setup do
    @completed = exchange_requests(:ana_borrowed_foundation)
  end

  test "un participante ve el formulario para calificar a la otra parte" do
    sign_in users(:beto)

    get new_exchange_request_review_path(@completed)

    assert_response :success
    assert_select "h1", text: /Calificar a #{users(:ana).name}/
  end

  test "calificar registra la valoración y actualiza el promedio del perfil evaluado" do
    sign_in users(:beto)

    assert_difference -> { users(:ana).received_reviews.count }, 1 do
      post exchange_request_reviews_path(@completed),
           params: { review: { score: 4, comment: "Cuidó muy bien el libro." } }
    end

    assert_redirected_to exchange_requests_path
    review = users(:ana).received_reviews.last
    assert_equal users(:beto), review.reviewer
    assert_equal "Cuidó muy bien el libro.", review.comment
    assert_equal 4.0, users(:ana).average_rating
  end

  test "no se puede calificar dos veces el mismo intercambio" do
    sign_in users(:ana)

    assert_no_difference "Review.count" do
      post exchange_request_reviews_path(@completed), params: { review: { score: 1 } }
    end

    assert_redirected_to exchange_requests_path
  end

  test "no se puede calificar un intercambio que no ha concluido" do
    sign_in users(:beto)

    get new_exchange_request_review_path(exchange_requests(:beto_wants_hobbit))

    assert_redirected_to exchange_requests_path
  end

  test "alguien que no participó no puede calificar" do
    sign_in users(:carla)

    assert_no_difference "Review.count" do
      post exchange_request_reviews_path(@completed), params: { review: { score: 5 } }
    end

    assert_redirected_to exchange_requests_path
  end

  test "sin puntuación no se guarda y vuelve a mostrar el formulario" do
    sign_in users(:beto)

    assert_no_difference "Review.count" do
      post exchange_request_reviews_path(@completed), params: { review: { score: "", comment: "Hola" } }
    end

    assert_response :unprocessable_content
  end

  test "Mis solicitudes muestra Calificar solo a quien todavía puede calificar" do
    sign_in users(:beto)
    get exchange_requests_path
    assert_select "a[href=?]", new_exchange_request_review_path(@completed)

    sign_out users(:beto)
    sign_in users(:ana)
    get exchange_requests_path
    assert_select "a[href=?]", new_exchange_request_review_path(@completed), count: 0
  end

  test "un visitante debe iniciar sesión para calificar" do
    get new_exchange_request_review_path(@completed)

    assert_redirected_to new_user_session_path
  end
end