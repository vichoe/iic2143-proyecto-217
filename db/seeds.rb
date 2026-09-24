[
  "Fantasía", "Ciencia ficción", "Misterio", "Romance", "Terror", "Historia",
  "Biografía", "Infantil", "Juvenil", "Poesía", "Ciencia", "Autoayuda"
].each do |name|
  Category.find_or_create_by!(name: name)
end