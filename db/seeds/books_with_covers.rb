require "json"
require "open-uri"
require "securerandom"
require "stringio"
require "uri"

if Rails.env.production? && ENV["ALLOW_DEMO_SEEDS"] != "1"
  abort "Carga cancelada en producción: define ALLOW_DEMO_SEEDS=1 para habilitarla."
end

module BookRackBooksWithCovers
  CATALOGO = [
    ["El Hobbit", "The Hobbit", "J. R. R. Tolkien", "Fantasía", 1937],
    ["La comunidad del anillo", "The Fellowship of the Ring", "J. R. R. Tolkien", "Fantasía", 1954],
    ["Harry Potter y la piedra filosofal", "Harry Potter and the Philosopher's Stone", "J. K. Rowling", "Fantasía", 1997],
    ["El león, la bruja y el ropero", "The Lion, the Witch and the Wardrobe", "C. S. Lewis", "Fantasía", 1950],
    ["La historia interminable", "The Neverending Story", "Michael Ende", "Fantasía", 1979],
    ["El nombre del viento", "The Name of the Wind", "Patrick Rothfuss", "Fantasía", 2007],
    ["El castillo ambulante", "Howl's Moving Castle", "Diana Wynne Jones", "Fantasía", 1986],
    ["La brújula dorada", "Northern Lights", "Philip Pullman", "Fantasía", 1995],
    ["Juego de tronos", "A Game of Thrones", "George R. R. Martin", "Fantasía", 1996],
    ["El imperio final", "Mistborn", "Brandon Sanderson", "Fantasía", 2006],
    ["Dune", "Dune", "Frank Herbert", "Ciencia ficción", 1965],
    ["Fundación", "Foundation", "Isaac Asimov", "Ciencia ficción", 1951],
    ["1984", "Nineteen Eighty-Four", "George Orwell", "Ciencia ficción", 1949],
    ["Fahrenheit 451", "Fahrenheit 451", "Ray Bradbury", "Ciencia ficción", 1953],
    ["Un mundo feliz", "Brave New World", "Aldous Huxley", "Ciencia ficción", 1932],
    ["La mano izquierda de la oscuridad", "The Left Hand of Darkness", "Ursula K. Le Guin", "Ciencia ficción", 1969],
    ["¿Sueñan los androides con ovejas eléctricas?", "Do Androids Dream of Electric Sheep?", "Philip K. Dick", "Ciencia ficción", 1968],
    ["El problema de los tres cuerpos", "The Three-Body Problem", "Liu Cixin", "Ciencia ficción", 2006],
    ["Neuromante", "Neuromancer", "William Gibson", "Ciencia ficción", 1984],
    ["El fin de la eternidad", "The End of Eternity", "Isaac Asimov", "Ciencia ficción", 1955],
    ["Asesinato en el Orient Express", "Murder on the Orient Express", "Agatha Christie", "Misterio", 1934],
    ["Y no quedó ninguno", "And Then There Were None", "Agatha Christie", "Misterio", 1939],
    ["El sabueso de los Baskerville", "The Hound of the Baskervilles", "Arthur Conan Doyle", "Misterio", 1902],
    ["La chica del tren", "The Girl on the Train", "Paula Hawkins", "Misterio", 2015],
    ["La verdad sobre el caso Harry Quebert", "The Truth About the Harry Quebert Affair", "Joël Dicker", "Misterio", 2012],
    ["El nombre de la rosa", "The Name of the Rose", "Umberto Eco", "Misterio", 1980],
    ["La sombra del viento", "The Shadow of the Wind", "Carlos Ruiz Zafón", "Misterio", 2001],
    ["El código Da Vinci", "The Da Vinci Code", "Dan Brown", "Misterio", 2003],
    ["Perdida", "Gone Girl", "Gillian Flynn", "Misterio", 2012],
    ["La paciente silenciosa", "The Silent Patient", "Alex Michaelides", "Misterio", 2019],
    ["Orgullo y prejuicio", "Pride and Prejudice", "Jane Austen", "Romance", 1813],
    ["Jane Eyre", "Jane Eyre", "Charlotte Brontë", "Romance", 1847],
    ["Cumbres borrascosas", "Wuthering Heights", "Emily Brontë", "Romance", 1847],
    ["Sentido y sensibilidad", "Sense and Sensibility", "Jane Austen", "Romance", 1811],
    ["Yo antes de ti", "Me Before You", "Jojo Moyes", "Romance", 2012],
    ["Bajo la misma estrella", "The Fault in Our Stars", "John Green", "Romance", 2012],
    ["El cuaderno de Noah", "The Notebook", "Nicholas Sparks", "Romance", 1996],
    ["Como agua para chocolate", "Como agua para chocolate", "Laura Esquivel", "Romance", 1989],
    ["Persuasión", "Persuasion", "Jane Austen", "Romance", 1817],
    ["Posdata: te quiero", "P.S. I Love You", "Cecelia Ahern", "Romance", 2004],
    ["Drácula", "Dracula", "Bram Stoker", "Terror", 1897],
    ["Frankenstein", "Frankenstein", "Mary Shelley", "Terror", 1818],
    ["El resplandor", "The Shining", "Stephen King", "Terror", 1977],
    ["It", "It", "Stephen King", "Terror", 1986],
    ["El exorcista", "The Exorcist", "William Peter Blatty", "Terror", 1971],
    ["La maldición de Hill House", "The Haunting of Hill House", "Shirley Jackson", "Terror", 1959],
    ["Otra vuelta de tuerca", "The Turn of the Screw", "Henry James", "Terror", 1898],
    ["El gato negro", "The Black Cat", "Edgar Allan Poe", "Terror", 1843],
    ["Cementerio de animales", "Pet Sematary", "Stephen King", "Terror", 1983],
    ["Carrie", "Carrie", "Stephen King", "Terror", 1974],
    ["Sapiens: De animales a dioses", "Sapiens", "Yuval Noah Harari", "Historia", 2011],
    ["Historia de dos ciudades", "A Tale of Two Cities", "Charles Dickens", "Historia", 1859],
    ["Los pilares de la Tierra", "The Pillars of the Earth", "Ken Follett", "Historia", 1989],
    ["La ladrona de libros", "The Book Thief", "Markus Zusak", "Historia", 2005],
    ["Historia del siglo XX", "Age of Extremes", "Eric Hobsbawm", "Historia", 1994],
    ["Las venas abiertas de América Latina", "Las venas abiertas de América Latina", "Eduardo Galeano", "Historia", 1971],
    ["Armas, gérmenes y acero", "Guns, Germs, and Steel", "Jared Diamond", "Historia", 1997],
    ["La guerra no tiene rostro de mujer", "The Unwomanly Face of War", "Svetlana Alexiévich", "Historia", 1985],
    ["La segunda guerra mundial", "The Second World War", "Antony Beevor", "Historia", 2012],
    ["El mundo de ayer", "The World of Yesterday", "Stefan Zweig", "Historia", 1942],
    ["El diario de Ana Frank", "The Diary of a Young Girl", "Ana Frank", "Biografía", 1947],
    ["Steve Jobs", "Steve Jobs", "Walter Isaacson", "Biografía", 2011],
    ["Mi historia", "Becoming", "Michelle Obama", "Biografía", 2018],
    ["El largo camino hacia la libertad", "Long Walk to Freedom", "Nelson Mandela", "Biografía", 1994],
    ["Yo soy Malala", "I Am Malala", "Malala Yousafzai", "Biografía", 2013],
    ["Elon Musk", "Elon Musk: Tesla, SpaceX, and the Quest for a Fantastic Future", "Ashlee Vance", "Biografía", 2015],
    ["Vivir para contarla", "Vivir para contarla", "Gabriel García Márquez", "Biografía", 2002],
    ["Confieso que he vivido", "Confieso que he vivido", "Pablo Neruda", "Biografía", 1974],
    ["Open: Memorias", "Open", "Andre Agassi", "Biografía", 2009],
    ["Una educación", "Educated", "Tara Westover", "Biografía", 2018],
    ["Cien años de soledad", "Cien años de soledad", "Gabriel García Márquez", "Otros", 1967],
    ["El principito", "Le Petit Prince", "Antoine de Saint-Exupéry", "Otros", 1943],
    ["Don Quijote de la Mancha", "Don Quixote", "Miguel de Cervantes", "Otros", 1605],
    ["La tregua", "La tregua", "Mario Benedetti", "Otros", 1960],
    ["Rayuela", "Rayuela", "Julio Cortázar", "Otros", 1963],
    ["El extranjero", "The Stranger", "Albert Camus", "Otros", 1942],
    ["Ensayo sobre la ceguera", "Blindness", "José Saramago", "Otros", 1995],
    ["El alquimista", "The Alchemist", "Paulo Coelho", "Otros", 1988],
    ["Crónica de una muerte anunciada", "Crónica de una muerte anunciada", "Gabriel García Márquez", "Otros", 1981],
    ["La casa de los espíritus", "La casa de los espíritus", "Isabel Allende", "Otros", 1982],
  ].freeze

  CIUDADES = ["Santiago", "Valparaíso", "Concepción", "Temuco", "La Serena", "Rancagua"].freeze
  CONDICIONES = %i[like_new good acceptable brand_new].freeze
  USER_AGENT = "BookRackGrupo217/1.0 (https://github.com/vichoe/iic2143-proyecto-217)".freeze
  SEARCH_DELAY = 1.1
  MAX_IMAGE_BYTES = 2_500_000
  TOTAL_USUARIOS = 12

  def self.normalizar(texto)
    texto.to_s.unicode_normalize(:nfkd)
         .gsub(/\p{Mn}/, "")
         .downcase
         .gsub(/[^a-z0-9]+/, " ")
         .strip
  end

  def self.coincide_titulo?(candidato, buscado)
    a = normalizar(candidato)
    b = normalizar(buscado)
    a == b || a.start_with?("#{b} ") || b.start_with?("#{a} ")
  end

  def self.coincide_autor?(autores, autor)
    buscado = normalizar(autor)
    apellido = buscado.split.last
    Array(autores).any? do |candidato|
      nombre = normalizar(candidato)
      nombre == buscado || (apellido && nombre.split.include?(apellido))
    end
  end

  def self.buscar_portada(titulo, consulta, autor)
    [consulta, titulo].uniq.each do |titulo_busqueda|
      sleep SEARCH_DELAY 
      parametros = URI.encode_www_form(
        title: titulo_busqueda, author: autor,
        fields: "title,author_name,cover_i", limit: 12
      )
      url = "https://openlibrary.org/search.json?#{parametros}"
      datos = URI.open(url, "User-Agent" => USER_AGENT, "Accept" => "application/json",
                            open_timeout: 10, read_timeout: 20) do |respuesta|
        JSON.parse(respuesta.read)
      end

      candidato = Array(datos["docs"]).find do |obra|
        obra["cover_i"].to_i.positive? &&
          coincide_autor?(obra["author_name"], autor) &&
          (coincide_titulo?(obra["title"], titulo_busqueda) ||
           coincide_titulo?(obra["title"], titulo))
      end
      return candidato.fetch("cover_i") if candidato
    end
    nil
  end

  def self.adjuntar_portada(libro, cover_id)
    url = "https://covers.openlibrary.org/b/id/#{cover_id}-M.jpg?default=false"
    imagen = URI.open(url, "User-Agent" => USER_AGENT, open_timeout: 10, read_timeout: 20)
    begin
      bytes = imagen.read(MAX_IMAGE_BYTES + 1)
      raise "Portada excede el tamaño permitido" if bytes.bytesize > MAX_IMAGE_BYTES
      raise "La respuesta no es una imagen JPEG" unless bytes.start_with?("\xFF\xD8\xFF".b)

      libro.cover_image.attach(
        io: StringIO.new(bytes),
        filename: "bookrack-#{libro.id}-openlibrary-#{cover_id}.jpg",
        content_type: "image/jpeg"
      )
    ensure
      imagen.close
    end
  end

  def self.run
    categorias = CATALOGO.map { |item| item[3] }.uniq.to_h do |nombre|
      [nombre, Category.find_or_create_by!(name: nombre)]
    end

    usuarios = TOTAL_USUARIOS.times.map do |indice|
      User.find_or_create_by!(email: format("bookrack.portadas.%02d@example.com", indice + 1)) do |usuario|
        usuario.name = format("Lector demo %02d", indice + 1)
        usuario.city = CIUDADES[indice % CIUDADES.length]
        usuario.bio = "Cuenta ficticia para demostrar el catálogo de Book Rack."
        usuario.password = SecureRandom.hex(24)
        usuario.password_confirmation = usuario.password
      end
    end

    nuevos = 0
    portadas = 0
    sin_portada = []
    omitir_portadas = ENV["SEED_SKIP_COVERS"] == "1"

    CATALOGO.each_with_index do |(titulo, consulta, autor, categoria, anio), indice|
      usuario = usuarios[indice % usuarios.length]
      libro = Book.find_or_initialize_by(user: usuario, title: titulo, author: autor)

      if libro.new_record?
        modalidad = (indice % 4).zero? ? :loan : :exchange
        libro.assign_attributes(
          category: categorias.fetch(categoria),
          published_year: anio,
          language: :spanish,
          condition: CONDICIONES[indice % CONDICIONES.length],
          modality: modalidad,
          status: :available,
          description: "Ejemplar ficticio para la demostración de Book Rack. " \
                       "Título y autor corresponden a una obra publicada realmente."
        )
        if modalidad == :loan
          libro.available_from = Date.current
          libro.available_until = Date.current + 180
        end
        libro.save!
        nuevos += 1
      end

      next if omitir_portadas || libro.cover_image.attached?

      begin
        cover_id = buscar_portada(titulo, consulta, autor)
        if cover_id
          adjuntar_portada(libro, cover_id)
          portadas += 1
          puts "Portada agregada: #{titulo}"
        else
          sin_portada << titulo
          warn "Sin portada disponible: #{titulo} - #{autor}"
        end
      rescue StandardError => error
        sin_portada << titulo
        warn "No se pudo adjuntar la portada de #{titulo}: #{error.class} - #{error.message}"
      end
    end

    puts "Carga finalizada: #{CATALOGO.length} libros definidos, #{nuevos} nuevos, " \
         "#{portadas} portadas adjuntadas."
    if omitir_portadas
      puts "Portadas omitidas por SEED_SKIP_COVERS=1. Ejecuta de nuevo sin la variable para adjuntarlas."
    elsif sin_portada.any?
      puts "#{sin_portada.length} libro(s) quedaron pendientes de portada: #{sin_portada.join(', ')}."
      puts "Puedes reintentar ejecutando este mismo archivo; no duplica los libros existentes."
    end
  end
end

BookRackBooksWithCovers.run
