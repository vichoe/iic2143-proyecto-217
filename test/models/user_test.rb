# tests creados con claue

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "los fixtures son válidos" do
    assert users(:ana).valid?
    assert users(:beto).valid?
  end

  test "requiere nombre" do
    user = users(:ana)
    user.nombre = ""
    assert_not user.valid?
  end

  test "no permite emails repetidos" do
    user = User.new(nombre: "Otra Ana", email: users(:ana).email, password: "password123")
    assert_not user.valid?
  end

  test "por defecto no es admin ni está suspendido" do
    user = User.create!(nombre: "Nuevo", email: "nuevo@example.com", password: "password123")
    assert_not user.admin?
    assert_not user.suspendido?
  end

  test "suspendido? es verdadero si tiene fecha de suspensión" do
    user = users(:ana)
    user.suspendido = Time.current
    assert user.suspendido?
  end
end