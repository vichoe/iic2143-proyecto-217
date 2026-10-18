class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_exchange_request

  def create
    @message = @exchange_request.messages.new(message_params)
      @message.sender = current_user

      if @message.save
        redirect_to exchange_request_path(@exchange_request, anchor: "nuevo-mensaje")
      else
        redirect_to exchange_request_path(@exchange_request), alert: "No se pudo enviar el mensaje."
      end 
  end

    private

  def set_exchange_request
    @exchange_request = ExchangeRequest.find_by(id: params[:exchange_request_id])
      return if @exchange_request&.chat_open_for?(current_user)

      redirect_to exchange_requests_path, alert: "No puedes acceder a esa conversación."
  end 

  def message_params
    params.require(:message).permit(:body)
  end
end
