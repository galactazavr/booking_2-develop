class PropertiesController < ApplicationController
  before_action :set_property, only: [:show, :destroy]

  def show
  end

  def destroy
    reason = params[:deletion_reason].presence || "Жилье было удалено"
    @property.update!(status: 'deleted', deletion_reason: reason)
    redirect_to request.referer || root_path, notice: "Объект недвижимости \"#{@property.name}\" успешно удалён."
  end

  private

  def set_property
    @property = Property.find(params[:id])
    authorize @property
  end
end
