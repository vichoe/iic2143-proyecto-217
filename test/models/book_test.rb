require "test_helper"

class BookTest < ActiveSupport::TestCase
  test "los fixtures son válidos" do
    assert books(:hobbit).valid?
    assert books(:foundation).valid?
  end

  test "requiere título y autor" do
    book = books(:hobbit)
    book.title = ""
    book.author = ""
    assert_not book.valid?
    assert book.errors.key?(:title)
    assert book.errors.key?(:author)
  end

  test "por defecto es de intercambio y está disponible" do
    book = Book.new(user: users(:ana), category: categories(:fantasy),
                    title: "Nuevo", author: "Alguien", condition: :good)
    assert book.valid?
    assert book.exchange?
    assert book.available?
  end

  test "rechaza una condición inválida" do
    book = books(:hobbit)
    book.condition = "roto"
    assert_not book.valid?
  end

  test "rechaza un año de publicación futuro" do
    book = books(:hobbit)
    book.published_year = Date.current.year + 1
    assert_not book.valid?
  end

  test "pertenece a su dueño y categoría" do
    assert_equal users(:ana), books(:hobbit).user
    assert_equal categories(:fantasy), books(:hobbit).category
  end
end
