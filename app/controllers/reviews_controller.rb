# frozen_string_literal: true

class ReviewsController < ApplicationController
  before_action :authenticate_user!

  def create
    @hotel = Hotel.find(params[:hotel_id])
    @review = @hotel.reviews.build(review_params)
    @review.user = current_user
    authorize @review

    if @review.save
      redirect_to hotel_path(@hotel), notice: 'Отзыв успешно добавлен!'
    else
      redirect_to hotel_path(@hotel), alert: @review.errors.full_messages.join(', ')
    end
  end

  def destroy
    @review = Review.find(params[:id])
    authorize @review
    hotel = @review.hotel

    @review.destroy
    redirect_to hotel_path(hotel), notice: 'Отзыв удалён.'
  end

  private

  def review_params
    params.require(:review).permit(:rating, :body, :booking_id)
  end
end
