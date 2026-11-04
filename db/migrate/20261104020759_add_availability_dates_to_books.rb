class AddAvailabilityDatesToBooks < ActiveRecord::Migration[8.1]
  def change
    add_column :books, :available_from, :date
    add_column :books, :available_until, :date
  end
end
# rails escribe codigo asi porque el nombre sigue el patron
# add<something>To<Tabla>: de 'Tobooks' saca la tabla y de los argumentos
#     <in the way she mooooves>
# 'campo:tipo' saca las columnas
