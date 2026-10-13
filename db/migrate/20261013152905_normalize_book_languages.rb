class NormalizeBookLanguages < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL.squish
      UPDATE books SET language = CASE
        WHEN LOWER(TRIM(language)) IN ('es', 'español', 'espanol', 'spanish', 'castellano') THEN 'es'
        WHEN LOWER(TRIM(language)) IN ('en', 'inglés', 'ingles', 'english') THEN 'en'
        WHEN TRIM(language) = '' THEN NULL
        ELSE 'other'
      END
      WHERE language IS NOT NULL
    SQL
  end

  def down
  end
end