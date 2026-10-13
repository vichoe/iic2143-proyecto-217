class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :configure_permitted_parameters, if: :devise_controller?
  helper_method :public_profiles?, :can_view_profile?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :city, :bio, :avatar])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :city, :bio, :avatar])
  end

  # config/application.rb para hacer perfiles publicos o privados
  def public_profiles?
    Rails.configuration.x.public_profiles
  end

  def can_view_profile?(user)
    public_profiles? || (user_signed_in? && (current_user.admin? || current_user == user))
  end
end