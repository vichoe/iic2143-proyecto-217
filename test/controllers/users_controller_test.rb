require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  # Cambia temporalmente el interruptor de perfiles y lo deja como estaba al terminar.
  def with_public_profiles(value)
    original = Rails.configuration.x.public_profiles
    Rails.configuration.x.public_profiles = value
    yield
  ensure
    Rails.configuration.x.public_profiles = original
  end

  # --- Perfiles públicos (public_profiles = true) ---

  test "perfiles públicos: un visitante puede ver un perfil" do
    with_public_profiles(true) do
      get user_path(users(:beto))
      assert_response :success
      assert_match "Beto Librero", response.body
    end
  end

  test "perfiles públicos: un usuario puede ver el perfil de otro" do
    with_public_profiles(true) do
      sign_in users(:ana)
      get user_path(users(:beto))
      assert_response :success
    end
  end

  test "el perfil no muestra libros retirados" do
    with_public_profiles(true) do
      books(:dune).update!(status: :withdrawn)
      get user_path(users(:beto))
      assert_select "a[href=?]", book_path(books(:dune)), count: 0
      assert_select "a[href=?]", book_path(books(:foundation))
    end
  end

  # --- Perfiles privados (public_profiles = false) ---

  test "perfiles privados: un visitante debe iniciar sesión" do
    with_public_profiles(false) do
      get user_path(users(:beto))
      assert_redirected_to new_user_session_path
    end
  end

  test "perfiles privados: un usuario no puede ver el perfil de otro" do
    with_public_profiles(false) do
      sign_in users(:ana)
      get user_path(users(:beto))
      assert_redirected_to root_path
    end
  end

  test "perfiles privados: un usuario puede ver su propio perfil" do
    with_public_profiles(false) do
      sign_in users(:ana)
      get user_path(users(:ana))
      assert_response :success
    end
  end

  test "perfiles privados: un administrador puede ver cualquier perfil" do
    with_public_profiles(false) do
      users(:carla).update!(admin: true)
      sign_in users(:carla)
      get user_path(users(:beto))
      assert_response :success
    end
  end

  # --- Lista de usuarios (siempre solo para administradores) ---

  test "un visitante no puede ver la lista de usuarios" do
    get users_path
    assert_redirected_to new_user_session_path
  end

  test "un usuario común no puede ver la lista de usuarios" do
    sign_in users(:ana)
    get users_path
    assert_redirected_to root_path
  end

  test "un administrador puede ver la lista de usuarios" do
    users(:carla).update!(admin: true)
    sign_in users(:carla)
    get users_path
    assert_response :success
  end
end