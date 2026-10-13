require "test_helper"

class BooksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "el dueño ve los botones de editar y eliminar" do
    sign_in users(:ana)
    get book_path(books(:hobbit))
    assert_select "a[href=?]", edit_book_path(books(:hobbit))
    assert_select "form[action=?]", book_path(books(:hobbit))
  end

  test "otro usuario no ve los botones" do
    sign_in users(:beto)
    get book_path(books(:hobbit))
    assert_select "a[href=?]", edit_book_path(books(:hobbit)), count: 0
  end

  test "el dueño puede editar su publicación" do
    sign_in users(:ana)
    get edit_book_path(books(:hobbit))
    assert_response :success

    patch book_path(books(:hobbit)), params: { book: { title: "El Hobbit (edición ilustrada)" } }
    assert_redirected_to book_path(books(:hobbit))
    assert_equal "El Hobbit (edición ilustrada)", books(:hobbit).reload.title
  end

  test "no guarda cambios inválidos" do
    sign_in users(:ana)
    patch book_path(books(:hobbit)), params: { book: { title: "" } }
    assert_response :unprocessable_content
    assert_equal "El Hobbit", books(:hobbit).reload.title
  end

  test "otro usuario no puede editar ni eliminar" do
    sign_in users(:beto)
    get edit_book_path(books(:hobbit))
    assert_redirected_to book_path(books(:hobbit))

    patch book_path(books(:hobbit)), params: { book: { title: "Robado" } }
    assert_equal "El Hobbit", books(:hobbit).reload.title

    delete book_path(books(:hobbit))
    assert books(:hobbit).reload.available?
  end

  test "sin sesión redirige al login" do
    get edit_book_path(books(:hobbit))
    assert_redirected_to new_user_session_path
  end

  test "eliminar marca la publicación como retirada y la saca del inicio" do
    sign_in users(:ana)
    delete book_path(books(:hobbit))
    assert_redirected_to user_path(users(:ana))
    assert books(:hobbit).reload.withdrawn?

    get root_path
    assert_select "a[href=?]", book_path(books(:hobbit)), count: 0
  end

  test "no se puede editar una publicación eliminada" do
    books(:hobbit).withdrawn!
    sign_in users(:ana)

    get edit_book_path(books(:hobbit))
    assert_redirected_to book_path(books(:hobbit))

    patch book_path(books(:hobbit)), params: { book: { title: "Revivido" } }
    assert_equal "El Hobbit", books(:hobbit).reload.title
  end

end