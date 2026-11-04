module BooksHelper
  CONDITION_LABELS = {
    "brand_new" => "Nuevo",
    "like_new" => "Como nuevo",
    "good" => "Buen estado",
    "acceptable" => "Aceptable"
  }.freeze

  MODALITY_LABELS = {
    "exchange" => "Intercambio",
    "loan" => "Préstamo"
  }.freeze

  STATUS_LABELS = {
    "available" => "Disponible",
    "reserved" => "Reservado",
    "exchanged" => "Intercambiado",
    "withdrawn" => "Retirado"
  }.freeze

  LANGUAGE_LABELS = {
    "spanish" => "Español",
    "english" => "Inglés",
    "other" => "Otro"
  }.freeze

  SORT_LABELS = {
    "rating" => "Mejor calificación",
    "title" => "Título (A-Z)"
  }.freeze

  def sort_options
    SORT_LABELS.map { |value, label| [label, value] }
  end

  def condition_options
    CONDITION_LABELS.map { |value, label| [label, value] }
  end

  def modality_options
    MODALITY_LABELS.map { |value, label| [label, value] }
  end

  def language_options
    LANGUAGE_LABELS.map { |value, label| [label, value] }
  end

  def status_filter_options
    STATUS_LABELS.slice("available", "reserved").map { |value, label| [label, value] }
  end

  def condition_label(book)
    CONDITION_LABELS[book.condition]
  end

  def modality_label(book)
    MODALITY_LABELS[book.modality]
  end

  def status_label(book)
    STATUS_LABELS[book.status]
  end

  def language_label(book)
    LANGUAGE_LABELS[book.language]
  end

  MONTH_NAMES = %w[Enero Febrero Marzo Abril Mayo Junio Julio Agosto Septiembre Octubre Noviembre Diciembre].freeze
  WEEKDAY_NAMES = %w[Lu Ma Mi Ju Vi Sá Do].freeze

  # Semanas (de lunes a domingo) que cubren el mes, para la grilla del calendario
  def calendar_weeks(month)
    first_day = month.beginning_of_month.beginning_of_week(:monday)
    last_day = month.end_of_month.end_of_week(:monday)
    (first_day..last_day).each_slice(7).to_a
  end

  # "Noviembre 2026"
  def calendar_month_title(month)
    "#{MONTH_NAMES[month.month - 1]} #{month.year}"
  end
end