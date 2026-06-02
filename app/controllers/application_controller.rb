# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:role, :first_name, :last_name, :phone])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :phone])
  end

  private

  def user_not_authorized
    flash[:alert] = 'У вас нет доступа к этому действию.'
    redirect_back(fallback_location: root_path)
  end

  def record_not_found
    respond_to do |format|
      format.html { redirect_to root_path, alert: 'Запрашиваемая страница не найдена.' }
      format.json { render json: { error: 'Не найдено' }, status: :not_found }
    end
  end

  def require_admin!
    return if current_user&.admin?

    redirect_to root_path, alert: 'Доступ разрешён только администратору.'
  end
end
