# frozen_string_literal: true

class PropertyPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    record.active? || owner_or_admin?
  end

  def create?
    !!user&.supervisor?
  end

  def update?
    owner_or_admin?
  end

  def destroy?
    owner_or_admin?
  end

  class Scope < Scope
    def resolve
      if user&.admin?
        scope.all
      elsif user&.supervisor?
        scope.where(user_id: user.id).or(scope.active)
      else
        scope.active
      end
    end
  end

  private

  def owner_or_admin?
    !!(user&.admin? || (user&.supervisor? && record.user_id == user.id))
  end
end
