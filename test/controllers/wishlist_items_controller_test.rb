require "test_helper"

class WishlistItemsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "un usuario ve solo su lista de deseos" do
    sign_in users(:ana)
    get wishlist_items_path

    assert_response :success
    assert_match "El Hobbit", response.body
    assert_no_match "Frank Herbert", response.body
  end

  test "se puede agregar un libro escribiendo solo título y autor" do
    sign_in users(:ana)

    assert_difference("WishlistItem.count", 1) do
      post wishlist_items_path, params: { wishlist_item: { title: "Rayuela", author: "Julio Cortázar" } }
    end
    assert_redirected_to wishlist_items_path
    assert_nil WishlistItem.last.book
  end

  test "no se agrega un libro sin título" do
    sign_in users(:ana)

    assert_no_difference("WishlistItem.count") do
      post wishlist_items_path, params: { wishlist_item: { title: "", author: "Alguien" } }
    end
    assert_redirected_to wishlist_items_path
  end

  test "un usuario ve el formulario para editar su libro deseado" do
    sign_in users(:ana)
    get edit_wishlist_item_path(wishlist_items(:one))

    assert_response :success
  end

  test "un usuario puede editar su libro deseado" do
    sign_in users(:ana)
    patch wishlist_item_path(wishlist_items(:one)), params: { wishlist_item: { title: "El Señor de los Anillos" } }

    assert_redirected_to wishlist_items_path
    assert_equal "El Señor de los Anillos", wishlist_items(:one).reload.title
  end

  test "no se guarda una edición sin título" do
    sign_in users(:ana)
    patch wishlist_item_path(wishlist_items(:one)), params: { wishlist_item: { title: "" } }

    assert_response :unprocessable_content
    assert_equal "El Hobbit", wishlist_items(:one).reload.title
  end

  test "un usuario puede eliminar un libro de su lista" do
    sign_in users(:ana)

    assert_difference("WishlistItem.count", -1) do
      delete wishlist_item_path(wishlist_items(:one))
    end
    assert_redirected_to wishlist_items_path
  end

  test "no se puede eliminar un libro de la lista de otro usuario" do
    sign_in users(:ana)

    assert_no_difference("WishlistItem.count") do
      delete wishlist_item_path(wishlist_items(:two))
    end
    assert_response :not_found
  end

  test "un visitante debe iniciar sesión" do
    get wishlist_items_path
    assert_redirected_to new_user_session_path
  end
end