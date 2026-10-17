categorias = [
  "Fantasía",
  "Ciencia ficción",
  "Misterio",
  "Romance",
  "Terror",
  "Historia",
  "Biografía",
  "Otros"
]

categorias.each do |nombre|
  Category.find_or_create_by!(name: nombre)
end

usuario = User.find_or_create_by!(
  email: ENV.fetch("SEED_USER_EMAIL", "aaisiidora@gmail.com")
) do |user|
  user.name = "Isidora Gomez"
  user.password = ENV.fetch("SEED_USER_PASSWORD", "Isidora123!")
  user.password_confirmation = user.password
end

libros = [
  ["El Hobbit", "J. R. R. Tolkien", "Fantasía"],
  ["Dune", "Frank Herbert", "Ciencia ficción"],
  ["Fundación", "Isaac Asimov", "Ciencia ficción"],
  ["Harry Potter y la piedra filosofal", "J. K. Rowling", "Fantasía"],
  ["Orgullo y prejuicio", "Jane Austen", "Romance"],
  ["Drácula", "Bram Stoker", "Terror"],
  ["El código Da Vinci", "Dan Brown", "Misterio"]
]

libros.each do |titulo, autor, nombre_categoria|
  Book.find_or_create_by!(
    user: usuario,
    title: titulo,
    author: autor
  ) do |book|
    book.category = Category.find_by!(name: nombre_categoria)
    book.condition = :good
    book.modality = :exchange
    book.status = :available
    book.language = :spanish
    book.published_year = 2020
  end
end

puts "Seeds ejecutados: #{Book.count} libros disponibles."