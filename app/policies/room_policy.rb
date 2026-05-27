# frozen_string_literal: true

class RoomPolicy < ApplicationPolicy
  def show?
    true
  end

  def create?
    !!(user&.supervisor? && record.hotel&.user_id == user.id)
  end

  def update?
    owner_or_admin?
  end

  def destroy?
    owner_or_admin?
  end

  private

  def owner_or_admin?
    !!(user&.admin? || (user&.supervisor? && record.hotel&.user_id == user.id))
  end
end
