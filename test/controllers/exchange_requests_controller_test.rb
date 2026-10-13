require "test_helper"

class ExchangeRequestsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  # Un libro disponible de Carla, para que pueda ofrecerlo en un intercambio.
  def carla_book
    @carla_book ||= Book.create!(user: users(:carla), category: categories(:fantasy),
                                 title: "Mi libro", author: "Carla", condition: :good)
  end

  test "un visitante debe iniciar sesión para solicitar" do
    get new_book_exchange_request_path(books(:dune))
    assert_redirected_to new_user_session_path
  end

  test "el dueño no puede solicitar su propio libro" do
    sign_in users(:ana)
    get new_book_exchange_request_path(books(:hobbit))
    assert_redirected_to book_path(books(:hobbit))
  end

  test "no se puede solicitar un libro que no está disponible" do
    books(:dune).reserved!
    sign_in users(:carla)
    get new_book_exchange_request_path(books(:dune))
    assert_redirected_to book_path(books(:dune))
  end

  test "solicitar un préstamo no exige ofrecer un libro" do
    sign_in users(:carla)

    assert_difference("ExchangeRequest.count", 1) do
      post book_exchange_requests_path(books(:foundation)), params: { exchange_request: { message: "¡Hola!" } }
    end

    request = ExchangeRequest.last
    assert_redirected_to book_path(books(:foundation))
    assert_equal users(:carla), request.requester
    assert request.pending?
    assert_nil request.offered_book
  end

  test "solicitar un intercambio ofreciendo un libro propio" do
    sign_in users(:carla)

    assert_difference("ExchangeRequest.count", 1) do
      post book_exchange_requests_path(books(:dune)), params: { exchange_request: { offered_book_id: carla_book.id } }
    end

    assert_equal carla_book, ExchangeRequest.last.offered_book
  end

  test "un intercambio sin libro ofrecido no se crea" do
    sign_in users(:carla)

    assert_no_difference("ExchangeRequest.count") do
      post book_exchange_requests_path(books(:dune)), params: { exchange_request: { message: "Sin libro" } }
    end
    assert_response :unprocessable_content
  end

  test "no se puede ofrecer un libro ajeno" do
    sign_in users(:carla)

    assert_no_difference("ExchangeRequest.count") do
      params = { exchange_request: { offered_book_id: books(:hobbit).id } }
      post book_exchange_requests_path(books(:dune)), params: params
    end
  end

  test "no se puede enviar dos solicitudes pendientes por el mismo libro" do
    # Beto ya tiene una solicitud pendiente por El Hobbit (fixture beto_wants_hobbit).
    sign_in users(:beto)

    assert_no_difference("ExchangeRequest.count") do
      params = { exchange_request: { offered_book_id: books(:dune).id } }
      post book_exchange_requests_path(books(:hobbit)), params: params
    end
  end

  test "mis solicitudes muestra las que envié" do
    sign_in users(:beto)
    get exchange_requests_path
    assert_response :success
    assert_select "a[href=?]", book_path(books(:hobbit))
  end
end