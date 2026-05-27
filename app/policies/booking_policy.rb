# frozen_string_literal: true

class BookingPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    owner? || hotel_owner? || user&.admin?
  end

  def create?
    user&.user? # Only regular users can book
  end

  def cancel?
    owner? && record.can_cancel?
  end

  def confirm?
    (hotel_owner? || user&.admin?) && record.pending?
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.supervisor?
        scope.joins(room: :hotel).where(hotels: { user_id: user.id })
      else
        scope.where(user_id: user.id)
      end
    end
  end

  private

  def owner?
    record.user_id == user&.id
  end

  def hotel_owner?
    user&.supervisor? && record.room&.hotel&.user_id == user.id
  end
end
