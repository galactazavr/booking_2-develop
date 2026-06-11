class Supervisor::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :require_supervisor!

  layout 'supervisor'

  def index
    @hotels = current_user.hotels
    @properties = current_user.properties
    @objects = (@hotels + @properties).sort_by(&:created_at)
  end

  def choice
  end

  def new_hotel
    @hotel = Hotel.new
  end

  def create_hotel
    # Filter out room_category from direct hotel params since it's processed separately
    filtered_params = hotel_params.except(:room_category)
    @hotel = current_user.hotels.build(filtered_params)
    @hotel.status = 'review' # Принудительно отправляем на модерацию

    ActiveRecord::Base.transaction do
      if @hotel.save
        category_params = params.dig(:hotel, :room_category)
        if category_params.present?
          quantity = category_params[:quantity].to_i
          quantity = 1 if quantity < 1
          quantity.times do |i|
            @hotel.rooms.create!(
              name: "#{category_params[:name]} ##{i + 1}",
              room_type: category_params[:room_type],
              capacity: category_params[:capacity],
              area: category_params[:area],
              price_per_night: category_params[:price_per_night],
              available: true,
              description: "#{category_params[:room_type]} номер, площадь #{category_params[:area]} м², до #{category_params[:capacity]} гостей"
            )
          end
        end
        redirect_to supervisor_success_path(type: 'hotel', id: @hotel.id), notice: 'Отель создан и отправлен на модерацию администратору'
      else
        raise ActiveRecord::Rollback
      end
    end

    unless @hotel.persisted?
      render :new_hotel, status: :unprocessable_entity
    end
  end

  def edit_hotel
    @hotel = current_user.hotels.find(params[:id])
    render :new_hotel
  end

  def update_hotel
    @hotel = current_user.hotels.find(params[:id])

    if @hotel.update(hotel_params)
      redirect_to supervisor_root_path, notice: 'Отель обновлён.'
    else
      render :new_hotel, status: :unprocessable_entity
    end
  end

  def new_property
    @property = Property.new
  end

  def create_property
    @property = current_user.properties.build(property_params)

    if @property.save
      redirect_to supervisor_success_path(type: 'property', id: @property.id), notice: 'Жильё создано и отправлено на проверку'
    else
      render :new_property, status: :unprocessable_entity
    end
  end

  def edit_property
    @property = current_user.properties.find(params[:id])
    render :new_property
  end

  def update_property
    @property = current_user.properties.find(params[:id])

    if @property.update(property_params)
      redirect_to supervisor_root_path, notice: 'Жильё обновлено.'
    else
      render :new_property, status: :unprocessable_entity
    end
  end

  def success
    @type = params[:type]
    @object = if @type == 'hotel'
                current_user.hotels.find(params[:id])
              else
                current_user.properties.find(params[:id])
              end
  end

  private

  def require_supervisor!
    unless current_user.supervisor?
      redirect_to root_path, alert: 'Доступ запрещён. Только для супервайзоров.'
    end
  end

  def hotel_params
    params.require(:hotel).permit(:name, :hotel_type, :city, :address, :description, :chain, :base_price_per_night, :available_from, :available_to, photos: [], room_category: [:room_type, :name, :capacity, :area, :price_per_night, :quantity])
  end

  def property_params
    params.require(:property).permit(:name, :property_type, :city, :address, :rooms_count, :area, :guests_capacity, :description, :base_price_per_night, :available_from, :available_to, photos: [])
  end
end
