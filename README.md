# Book Rack · Grupo 217

Plataforma web para **intercambiar y prestar libros** entre personas de una misma comunidad, aprovechando libros que ya tienen en casa.

**🔗 Aplicación en Render:** https://two026-2-grupo-217.onrender.com/

## ¿Cómo funciona?

Cada usuario publica los libros que quiere ofrecer, eligiendo una de dos modalidades:

- **Intercambio:** el libro cambia de dueño. Quien lo pide ofrece a cambio uno de sus propios libros.
- **Préstamo:** el libro vuelve a su dueño. El dueño indica en qué periodo está disponible y quien lo pide elige las fechas en que lo necesita.

El flujo de una transacción es:

1. Un usuario encuentra un libro en el catálogo y envía una **solicitud**.
2. El dueño la **acepta o rechaza** desde *Mis solicitudes*.
3. Al aceptarse se abre un **chat privado** para coordinar la entrega.
4. Cuando la transacción termina, se marca como **concluida** y ambos pueden **calificarse** (1 a 5 estrellas y un comentario).

## Funcionalidades

| Sección | Qué se puede hacer |
|---|---|
| **Cuenta** | Registrarse, iniciar sesión, editar perfil y foto. Perfil público con calificaciones recibidas. |
| **Catálogo** | Ver los libros organizados en estantes, buscar por título o autor, filtrar (categoría, estado, modalidad, idioma, año, editorial) y ordenar. |
| **Publicaciones** | Publicar libros con portada y fotos, editarlos y eliminarlos. *Mis libros* lista las publicaciones propias. |
| **Solicitudes** | Solicitar un libro, aceptar, rechazar y concluir. Las solicitudes enviadas y recibidas se ven en *Mis solicitudes*. |
| **Calendario de préstamos** | En la página de un libro en préstamo se ve un calendario mensual con los días disponibles, reservados y fuera del periodo. Un mismo libro puede prestarse a varias personas en fechas que no se crucen. |
| **Chat** | Conversación entre ambas partes mientras la transacción está activa. |
| **Calificaciones** | Al concluir una transacción, cada parte califica a la otra. |
| **Wishlist** | Lista de libros deseados, ya sea desde una publicación (botón ♡) o escribiendo título y autor a mano. |
| **Notificaciones** | Aviso al solicitante cuando su solicitud es aceptada o rechazada. |
| **Administrador** | Listar usuarios, suspender y reactivar cuentas, y gestionar (eliminar) publicaciones y calificaciones. |

### Reglas importantes

- No se puede solicitar un libro propio ni enviar dos solicitudes pendientes por el mismo libro.
- En un intercambio, el libro ofrecido debe ser del solicitante y tener modalidad de intercambio.
- En un préstamo, las fechas deben estar dentro del periodo del dueño, no pueden ser pasadas y no pueden cruzarse con otro préstamo ya aceptado.
- Una cuenta suspendida no puede iniciar sesión.

## Cómo probarlo

Los seeds crean categorías, libros de ejemplo en intercambio y el libro **"Crimen y castigo"** en préstamo, publicado por un usuario de ejemplo:

| Usuario | Email | Contraseña |
|---|---|---|
| Usuario Prestamista | `prestamista@example.com` | `Prestamo123!` |

Para probar el préstamo: crea una cuenta, entra a "Crimen y castigo", revisa el calendario y solicítalo eligiendo fechas. Luego inicia sesión como el Usuario Prestamista para aceptar la solicitud desde *Mis solicitudes*.

## Ejecutar en local

Requisitos: Ruby 4.0, PostgreSQL y Bundler.

```bash
bundle install
bin/rails db:create db:migrate db:seed
bin/rails server
```

La aplicación queda en http://localhost:3000.

### Tests y calidad

```bash
bin/rails test              # Minitest + SimpleCov (reporte en coverage/index.html)
bundle exec rubocop         # estilo de código
bin/brakeman --no-pager     # análisis de seguridad
bin/bundler-audit           # gemas con vulnerabilidades conocidas
```

## Documentación

- **Modelo E/R:** [`docs/modelo_er.png`](docs/modelo_er.png)
- **Reglamento interno:** [`docs/reglamento_interno_IIC2143-2.pdf`](docs/reglamento_interno_IIC2143-2.pdf)
- **Flujo de trabajo:** Gitflow (`feat/*` y `fix/*` → `develop` → `main`) con conventional commits.
- **Configuración de Rubocop:** https://iic2143.github.io/Setup-Guides/guides/tools/rubocop/

### Uso de IA 

Principalmente se uso Claude para depuración y creacion de testcases y guía en areas que no manejabamos con certeza. Cabe destacar que Claude no hizo ningun push, los pushes fueron manuales y el codigo fue revisado y adaptado a lo nuestro.

Tambien lo usamos para guiarnos con el manejo de ramas al inicio, aunque despues le agarramos mas mano.

#### ¿Para qué se usó?

| Area | Inteligencia Artificial (lo que hizo la IA)| Inteligencia Artesanal (lo que hicimos nosotros) |
|---|---|---|
| Modelo E/R y base de datos | Primera version del diagrama con relaciones | Rediseñar ciertos aspectos del diagrama y usar nombres en ingles para las tablas |
| Configuración (Devise, Active Storage, Render) | Guió la instalación de Devise y Active Storage, y la configuración del Build Command de Render (`db:migrate:primary`, seeds, `:async` en vez de Solid Queue) | Ejecutamos y verificamos cada paso, revisamos los logs de Render y decidimos los cambios |
| Depuración | orrecion de errores en consola, ya sea en el repositorio o en el setup de Render. | Probamos los errores y aplicamos lo propuesto por la IA |
| Features | Sugirió codigo inicial para algunas caracteristicas del programa | Corregimos cosas que no nos parecian, como los perfiles publicos (aunque tenemos un config que nos deja hacer los perfiles publicos con un cambio de linea) |
| Tests | Propuso tests de modelos y controladores | Revisamos que probaran los casos correctos y los ajustamos cuando cambio el comportamiento |

#### Uso por integrante

| Integrante | Uso de IA |
|---|---|
| Vicente | Agilizar creacion de BBDD, setup de Devise, depuración y testeos |
| Antonella | Depuración de la conexión a PostgreSQL en WSL, tests. |
| Isidora | tbd |

#### Recursos externos utilizados
- Configuración de Rubocop del curso: https://iic2143.github.io/Setup-Guides/guides/tools/rubocop/
- Video de configuración de Render: https://www.youtube.com/watch?v=MFTmX-EI-M4
- Guías de Rails: https://guides.rubyonrails.org/
- Documentación de Devise: https://github.com/heartcombo/devise
- Documentación de Render: https://render.com/docs

### Notas
Nos daba error al hacer Pull Request en `System Test` y es porque no existía `test/system`.
Cuando Rails genera un proyecto nuevo con soporte de tests de sistema, siempre crea esa carpeta con un archivo base. Puede ser que se te borrara Vicho o se ignorara en el `.gitignore`

**Probando rubocop**
```bash
bundle exec rubocop
```
Ejecuta la herramienta RuboCop usando exactamente la versión de la gema especificada en el Gemfile de tu proyecto actual, lo cual me generó:
```bash
ainzua@LAPTOP-MJ7R32C2:~/iic2143-proyecto-217$ bundle exec rubocop
Inspecting 20 files
....................
20 files inspected, no offenses detected
Tip: Based on detected gems, the following RuboCop extension libraries might be helpful:
  * rubocop-capybara (https://rubygems.org/gems/rubocop-capybara)
The following RuboCop extension libraries are installed but not loaded in config:
  * rubocop-rails
You can opt out of this message by adding the following to your config (see https://docs.rubocop.org/rubocop/plugins.html#plugin-suggestions for more options):
  AllCops:
    SuggestExtensions: false
ainzua@LAPTOP-MJ7R32C2:~/iic2143-proyecto-217$
```
Lo cual indica que Rubocop esta bien configurado.

### Revisar
El ultimo mensaje de los 2 tip que dio es de `rubocop-rails` que está instalado pero no cargado, tenemos la gema instalda pero no esta activada en la configuración (`.rubocop.yml`) el cual añade reglas especificas de buenas prácticas Rails.

Avisar si quieren que lo implementemos!!!

### Soluciones
Crearemos el helper que falta directamente
```bash
mkdir -p test/system
```
Y cree el archivo con nano
```bash
nano test/system/application_system_test_case.rb
```
Con el contenido:
```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
end
```

Ese es el archivo Rails que se genera por defecto en cualquier proyecto nuevo (miami me lo confirmo en el log del error, ya que se usa `selenium-webdriver` que ya está en el `Gemfile`; esto da a entender que solo faltaba el archivo de configuración ya que la gema en si, estaba.)

Luego de haber creado el archivo y haberlo corrido con 
```bash
bin/rails test:system
```
Me dio:
```bash
ainzua@LAPTOP-MJ7R32C2:~/iic2143-proyecto-217$ bin/rails test:system
Run options: --seed 52100

# Running:



Finished in 0.001304s, 0.0000 runs/s, 0.0000 assertions/s.
0 runs, 0 assertions, 0 failures, 0 errors, 0 skips
ainzua@LAPTOP-MJ7R32C2:~/iic2143-proyecto-217$
```
Demostrando que ya no explota con `LoasError`, simplemente no hay test de sistema escritos todavía y por eso aparecen 0 runs, pero la infraestructura ya esta hecha :D
Probando gitflow!!!


# **Hello World**
1. Cree una branch nueva desde develop con
```bash
git checkout -b feat/hello-world
```
2. Generamos un controlador con 
```bash
bin/rails generate controller Welcome index --skip-test-framework
```
3. Configuramos la ruta raís `config/routes.rb` agregando dentro del bloque `root "welcome#index"`
