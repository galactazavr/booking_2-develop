# frozen_string_literal: true

class ReviewPolicy < ApplicationPolicy
  def create?
    !!user&.user?
  end

  def destroy?
    !!(user && (record.user_id == user.id || user.admin?))
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
