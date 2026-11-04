module ExchangeRequestsHelper
  REQUEST_STATUS_LABELS = {
    "pending" => "Pendiente",
    "accepted" => "Aceptada",
    "rejected" => "Rechazada",
    "cancelled" => "Cancelada",
    "completed" => "Completada"
  }.freeze

  def request_status_label(request)
    REQUEST_STATUS_LABELS[request.status]
  end

  # "préstamo (del 10-11-2026 al 15-11-2026)" o solo "préstamo" si no tiene fechas
  def loan_period_label(request)
    return "préstamo" if request.start_date.blank? || request.end_date.blank?

    "préstamo (del #{request.start_date.strftime('%d-%m-%Y')} al #{request.end_date.strftime('%d-%m-%Y')})"
  end
end