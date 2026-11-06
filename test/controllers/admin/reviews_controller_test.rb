require "test_helper"

module Admin
  class ReviewsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      users(:carla).update!(admin: true)
    end

    test "un administrador ve todas las reseñas" do
      sign_in users(:carla)
      get admin_reviews_path

      assert_response :success
      assert_match "Todo excelente, muy puntual.", response.body
    end

    test "un administrador puede eliminar una reseña" do
      sign_in users(:carla)

      assert_difference("Review.count", -1) do
        delete admin_review_path(reviews(:ana_reviews_beto))
      end
      assert_redirected_to admin_reviews_path
    end

    test "un usuario común no puede eliminar reseñas" do
      sign_in users(:ana)

      assert_no_difference("Review.count") do
        delete admin_review_path(reviews(:ana_reviews_beto))
      end
      assert_redirected_to root_path
    end

    test "un visitante debe iniciar sesión" do
      get admin_reviews_path
      assert_redirected_to new_user_session_path
    end
  end
end