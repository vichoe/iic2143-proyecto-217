class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    @books = @user.books.where(status: [:available, :reserved]).order(created_at: :desc)
  end
end