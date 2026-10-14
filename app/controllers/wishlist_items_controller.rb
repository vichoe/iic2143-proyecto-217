class WishlistItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_wishlist_item, only: [:edit, :update, :destroy]

  def index
    @wishlist_items = current_user.wishlist_items.order(created_at: :desc)
  end

  def create
    @wishlist_item = current_user.wishlist_items.new(wishlist_item_params)

    if @wishlist_item.save
      redirect_back fallback_location: wishlist_items_path,
                    notice: "Libro agregado a tu lista de deseos."
    else
      redirect_back fallback_location: wishlist_items_path,
                    alert: @wishlist_item.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    if @wishlist_item.update(wishlist_item_params)
      redirect_to wishlist_items_path,
                  notice: "Libro actualizado correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @wishlist_item.destroy

    redirect_to wishlist_items_path,
                notice: "Libro eliminado de tu lista de deseos."
  end

  private

  def set_wishlist_item
    @wishlist_item = current_user.wishlist_items.find(params[:id])
  end

  def wishlist_item_params
    params.require(:wishlist_item).permit(:title, :author, :book_id)
  end
end