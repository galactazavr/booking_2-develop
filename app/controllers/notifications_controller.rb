class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.recent.page(params[:page]).per(20)
    current_user.notifications.unread.update_all(read: true)
  end

  def destroy
    @notification = current_user.notifications.find(params[:id])
    @notification.destroy
    redirect_back fallback_location: notifications_path, notice: 'Уведомление удалено'
  end
end
