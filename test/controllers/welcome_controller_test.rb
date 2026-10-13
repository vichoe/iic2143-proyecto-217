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

  
  test "administrador busca usuarios por nombre y enlaza a su perfil" do
    users(:carla).update!(admin: true)
    sign_in users(:carla)

    get root_path, params: { user_q: "beto" }

    assert_response :success
    assert_select "h2", text: /Usuarios que coinciden/
    assert_select "a[href=?]", user_path(users(:beto))
  end

  test "un usuario común no ve la búsqueda de usuarios" do
    sign_in users(:ana)

    get root_path, params: { user_q: "beto" }

    assert_response :success
    assert_select "input[name=user_q]", count: 0
    assert_select "h2", text: /Usuarios que coinciden/, count: 0
  end

  test "un visitante solo ve la barra de búsqueda de libros" do
    get root_path

    assert_select "input[name=q]"
    assert_select "input[name=user_q]", count: 0
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

  # Escenario 1: al combinar varios filtros, el sistema muestra
  # únicamente los libros que cumplen TODOS los criterios seleccionados.
  test "escenario 1: filtra por categoría y estado combinados" do
    get root_path, params: { category_id: categories(:science_fiction).id, condition: "like_new" }

    assert_response :success
    assert_select "a[href=?]", book_path(books(:dune))
    assert_select "a[href=?]", book_path(books(:foundation)), count: 0
    assert_select "a[href=?]", book_path(books(:hobbit)), count: 0
  end

  # Escenario 2 (HU filtros): si la combinación de filtros no matchea
  # ningún libro, la lista queda vacía y se muestra el mensaje correspondiente.
  test "escenario 2: combinación de filtros sin coincidencias muestra mensaje" do
    get root_path, params: { category_id: categories(:fantasy).id, condition: "like_new" }

    assert_response :success
    assert_select "a[href=?]", book_path(books(:hobbit)), count: 0
    assert_select "a[href=?]", book_path(books(:dune)), count: 0
    assert_match "No hay libros que coincidan con los filtros aplicados.", response.body
  end

  # --- HU "Ordenar resultados de búsqueda" ---

  # Escenario 1: al elegir un criterio de orden, se muestran los libros
  # ordenados según ese criterio.
  test "escenario 1: ordena por título de la A a la Z" do
    get root_path, params: { sort: "title" }
    assert_response :success

    dune_pos = response.body.index(book_path(books(:dune)))          # "Dune"
    hobbit_pos = response.body.index(book_path(books(:hobbit)))      # "El Hobbit"
    foundation_pos = response.body.index(book_path(books(:foundation))) # "Fundación"

    assert dune_pos < hobbit_pos, "Dune debería aparecer antes que El Hobbit"
    assert hobbit_pos < foundation_pos, "El Hobbit debería aparecer antes que Fundación"
  end

  test "escenario 1: ordena por mejor calificación del dueño del libro" do
    get root_path, params: { sort: "rating" }
    assert_response :success

    # Beto (dune, foundation) tiene una reseña con score 5; Ana (hobbit)
    # no tiene reseñas recibidas (average_rating nil -> se trata como peor).
    dune_pos = response.body.index(book_path(books(:dune)))
    foundation_pos = response.body.index(book_path(books(:foundation)))
    hobbit_pos = response.body.index(book_path(books(:hobbit)))

    assert dune_pos < hobbit_pos, "El libro del dueño mejor calificado debería ir primero"
    assert foundation_pos < hobbit_pos, "El libro del dueño mejor calificado debería ir primero"
  end

  # Escenario 2: sin resultados previos, el selector de orden queda deshabilitado.
  test "escenario 2: sin resultados el selector de orden queda deshabilitado" do
    get root_path, params: { q: "xxxxxxxxxx-no-existe" }
    assert_response :success
    assert_select "select#sort[disabled]"
  end

  test "con resultados el selector de orden está habilitado" do
    get root_path
    assert_response :success
    assert_select "select#sort:not([disabled])"
  end
end