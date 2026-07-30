class ArticlePolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    return true if publicly_visible?
    return false unless user

    admin? || owner?
  end

  def create?
    user.present?
  end
  alias_method :new?, :create?

  def update?
    return false unless user

    admin? || (owner? && record.draft?)
  end
  alias_method :edit?, :update?

  def publish?
    return false unless user

    admin? || owner?
  end

  def destroy?
    admin?
  end

  class Scope < Scope
    def resolve
      return scope.all if user&.admin?
      return scope.where(user_id: user.id).or(scope.where.not(status: :draft)) if user

      scope.where.not(status: :draft)
    end
  end

  private

  def admin?
    user&.admin?
  end

  def owner?
    user && record.user_id == user.id
  end

  def publicly_visible?
    record.published? || record.archived?
  end
end
