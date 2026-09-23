require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "los fixtures son válidos" do
    assert users(:ana).valid?
    assert users(:beto).valid?
  end

  test "requiere nombre" do
    user = users(:ana)
    user.name = ""
    assert_not user.valid?
  end

  test "no permite emails repetidos" do
    user = User.new(name: "Otra Ana", email: users(:ana).email, password: "password123")
    assert_not user.valid?
  end

  test "por defecto no es admin ni está suspendido" do
    user = User.create!(name: "Nuevo", email: "nuevo@example.com", password: "password123")
    assert_not user.admin?
    assert_not user.suspended?
  end

  test "suspended? es verdadero si tiene fecha de suspensión" do
    user = users(:ana)
    user.suspended_at = Time.current
    assert user.suspended?
  end

  test "average_rating promedia las reseñas recibidas" do
    assert_in_delta 5.0, users(:beto).average_rating
    assert_nil users(:carla).average_rating
  end
end
