require "test_helper"

class MessageTest < ActiveSupport::TestCase
  test "el fixture es válido" do
    assert messages(:greeting).valid?
  end

  test "requiere contenido" do
    message = messages(:greeting)
    message.body = ""
    assert_not message.valid?
  end

  test "solo los participantes pueden escribir" do
    message = Message.new(exchange_request: exchange_requests(:beto_wants_hobbit),
                          sender: users(:carla), body: "Hola")
    assert_not message.valid?
    assert message.errors.key?(:sender)
  end

  test "no se puede escribir una solicitud pendiente" do
    message = Message.new(exchange_request: exchange_requests(:beto_wants_hobbit),
                          sender: users(:beto), body: "Hola")
    assert_not message.valid?
  end

  test "se puede escribir en una solicitud aceptada o completada" do
    message = Message.new(exchange_request: exchange_requests(:ana_borrowed_foundation),
                          sender: users(:ana), body: "Hola")
    assert message.valid?
  end
end
