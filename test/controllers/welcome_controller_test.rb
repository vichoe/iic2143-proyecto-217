require "test_helper"

class WelcomeControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "sin búsqueda muestra publicaciones recientes con link al perfil del dueño" do
    get root_path
    assert_response :success
    assert_select "a[href=?]", book_path(books(:hobbit)), text: "El Hobbit"
    assert_select "a[href=?]", user_path(users(:ana)), text: "Ana Lectora"
    assert_select "a[href=?]", user_path(users(:beto)), text: "Beto Librero"
  end

  test "busca libros por título sin distinguir mayúsculas" do
    get root_path, params: { q: "hobbit" }
    assert_response :success
    assert_select "a[href=?]", book_path(books(:hobbit))
    assert_select "a[href=?]", book_path(books(:dune)), count: 0
  end

  test "busca libros por autor" do
    get root_path, params: { q: "asimov" }
    assert_select "a[href=?]", book_path(books(:foundation))
    assert_select "a[href=?]", book_path(books(:hobbit)), count: 0
  end

  test "busca usuarios por nombre y enlaza a su perfil" do
    get root_path, params: { q: "carla" }
    assert_select "h2", "Usuarios"
    assert_select "a[href=?]", user_path(users(:carla))
  end

  test "no muestra libros retirados" do
    books(:dune).update!(status: :withdrawn)
    get root_path, params: { q: "dune" }
    assert_select "a[href=?]", book_path(books(:dune)), count: 0
    assert_match "No encontramos libros", response.body
  end

  test "los comodines % y _ se buscan como texto literal" do
    get root_path, params: { q: "%" }
    assert_response :success
    assert_select "a[href=?]", book_path(books(:hobbit)), count: 0
  end

  test "el saludo enlaza al perfil del usuario conectado" do
    sign_in users(:ana)
    get root_path
    assert_select ".top-bar a[href=?]", user_path(users(:ana))
  end
end