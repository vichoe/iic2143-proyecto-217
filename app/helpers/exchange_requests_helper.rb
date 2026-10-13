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
end