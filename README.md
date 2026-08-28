Se utilizo la configuracion de Rubocop del siguiente link: https://iic2143.github.io/Setup-Guides/guides/tools/rubocop/ 

Render setup: https://www.youtube.com/watch?v=MFTmX-EI-M4 

### Notas
Nos daba error al hacer Pull Request en `System Test` y es porque no existía `test/system`.
Cuando Rails genera un proyecto nuevo con soporte de tests de sistema, siempre crea esa carpeta con un archivo base. Puede ser que se te borrara Vicho o se ignorara en el `.gitignore`

**Probando rubocop**
````bash
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
