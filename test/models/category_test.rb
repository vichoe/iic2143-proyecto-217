require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "el fixture es válido" do
    assert categories(:fantasy).valid?
  end

  test "requiere nombre" do
    assert_not Category.new(name: "").valid?
  end

  test "el nombre es único sin importar mayúsculas" do
    assert_not Category.new(name: "fantasía").valid?
  end
end
