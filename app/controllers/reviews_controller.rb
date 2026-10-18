class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reviewable_request

  def new
    @review = Review.new
  end

  def create
    @review = @exchange_request.reviews.new(review_params)
    @review.reviewer = current_user
    @review.reviewee = @exchange_request.other_participant(current_user)

    if @review.save
      redirect_to exchange_requests_path, notice: "¡Gracias! Tu calificación quedó registrada."
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  # solo puede calificar quien participó en un intercambio concluido y aún no ha calificado
  def set_reviewable_request
    @exchange_request = ExchangeRequest.find_by(id: params[:exchange_request_id])
    return if @exchange_request&.can_be_reviewed_by?(current_user)

    redirect_to exchange_requests_path, alert: "No puedes calificar esa solicitud."
  end

  def review_params
    params.require(:review).permit(:score, :comment)
  end
end