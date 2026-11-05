require "test_helper"

module Admin
  class BooksControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      users(:carla).update!(admin: true)
    end

    test "un administrador ve todas las publicaciones" do
      sign_in users(:carla)
      get admin_books_path

      assert_response :success
      assert_match books(:hobbit).title, response.body
      assert_match books(:dune).title, response.body
    end

    test "un administrador puede retirar cualquier publicación" do
      sign_in users(:carla)
      delete admin_book_path(books(:dune))

      assert_redirected_to admin_books_path
      assert books(:dune).reload.withdrawn?
    end

    test "un usuario común no puede entrar a la administración" do
      sign_in users(:ana)
      get admin_books_path

      assert_redirected_to root_path
    end

    test "un usuario común no puede retirar publicaciones ajenas" do
      sign_in users(:ana)
      delete admin_book_path(books(:dune))

      assert_redirected_to root_path
      assert_not books(:dune).reload.withdrawn?
    end

    test "un visitante debe iniciar sesión" do
      get admin_books_path
      assert_redirected_to new_user_session_path
    end
  end
end