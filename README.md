Se utilizo la configuracion de Rubocop del siguiente link: https://iic2143.github.io/Setup-Guides/guides/tools/rubocop/ 

LINK DE RENDER: https://two026-2-grupo-217.onrender.com/ 

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
| Antonella | tbd |
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
