module Admin
  class ReviewsController < BaseController
    def index
      @reviews = Review.includes(:reviewer, :reviewee, exchange_request: :book)
                       .order(created_at: :desc)
    end

    #elimina reseñas
    def destroy
      Review.find(params[:id]).destroy!

      redirect_to admin_reviews_path,
                  notice: "Reseña eliminada.",
                  status: :see_other
    end
  end
end