require "test_helper"
class MessagesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

    #Ana pidio prestado Fundación (de Beto) y la solicitud esta completada: pueden conversar
  def conversation 
    exchange_requests(:ana_borrowed_foundation)
  end

  test "un participante ve los mensajes en orden cronológico" do
    Message.create!(exchange_request: conversation, sender: users(:beto), body:
    "Segundo", created_at: 1.hour.ago)

      Message.create!(exchange_request: conversation, sender: users(:ana), body:
      "Primero", created_at: 2.hours.ago)

      sign_in users(:ana)
      get exchange_request_path(conversation)

      assert_response :success
      assert response.body.index("Primero") < response.body.index("Segundo")
  end

  test "ambos participantes pueden ver la conversación" do
    sign_in users(:beto)
      get exchange_request_path(conversation)

      assert_response :success
  end

  test "alguien que no participa no puede ver la conversacion" do
    sign_in users(:carla)
      get exchange_request_path(conversation)
      assert_redirected_to exchange_requests_path
  end

  test "la conversación no está disponible si la solicitud sigue pendiente" do
  sign_in users(:beto)
  get exchange_request_path(exchange_requests(:beto_wants_hobbit))
  assert_redirected_to exchange_requests_path
end

  test "un participante puede enviar un mensaje" do
    sign_in users(:ana)

    assert_difference("Message.count", 1) do
      post exchange_request_messages_path(conversation), params: { message: { body: "¿Nos vemos el lunes?" } }
    end

    assert_redirected_to exchange_request_path(conversation, anchor: "nuevo-mensaje")
    assert_equal users(:ana), Message.last.sender

    follow_redirect!
    assert_match "¿Nos vemos el lunes?", response.body
  end

  test "no se envía un mensaje vacío" do
    sign_in users(:ana)

    assert_no_difference("Message.count") do
      post exchange_request_messages_path(conversation), params: { message: { body: "" } }
    end
  end

  test "alguien que no participa no puede enviar mensajes" do
    sign_in users(:carla)

    assert_no_difference("Message.count") do
      post exchange_request_messages_path(conversation), params: { message: { body: "Hola" } }
    end
    assert_redirected_to exchange_requests_path
  end

  test "un visitante debe iniciar sesión" do
    post exchange_request_messages_path(conversation), params: { message: { body: "Hola" } }
    assert_redirected_to new_user_session_path
  end
end
