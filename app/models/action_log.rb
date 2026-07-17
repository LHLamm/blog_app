class ActionLog < ApplicationRecord
  belongs_to :loggable, polymorphic: true
  belongs_to :user, optional: true

  validates :action, presence: true
end