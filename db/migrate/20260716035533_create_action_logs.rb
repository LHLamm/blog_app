class CreateActionLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :action_logs do |t|
      t.string :action
      t.json :metadata, null: false, default: {}
      t.references :loggable, polymorphic: true, null: false
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end