class UserPolicy < ApplicationPolicy
  def show?
    user.present? && user == record
  end
end
