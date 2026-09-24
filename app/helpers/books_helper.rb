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

  def condition_options
    CONDITION_LABELS.map { |value, label| [label, value] }
  end

  def modality_options
    MODALITY_LABELS.map { |value, label| [label, value] }
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
end