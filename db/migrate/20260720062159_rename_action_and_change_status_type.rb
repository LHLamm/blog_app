class RenameActionAndChangeStatusType < ActiveRecord::Migration[8.1]
  STATUS_TO_INT = { "draft" => 10, "published" => 20, "archived" => 30 }.freeze
  INT_TO_STATUS = STATUS_TO_INT.invert.freeze

  def up
    rename_column :action_logs, :action, :action_name

    add_column :articles, :status_tmp, :integer, default: 10, null: false

    STATUS_TO_INT.each do |string_value, int_value|
      execute <<~SQL.squish
        UPDATE articles SET status_tmp = #{int_value} WHERE status = '#{string_value}'
      SQL
    end

    remove_index :articles, :status
    remove_index :articles, [ :user_id, :status ]
    remove_column :articles, :status

    rename_column :articles, :status_tmp, :status
    add_index :articles, :status
    add_index :articles, [ :user_id, :status ]
  end

  def down
    rename_column :action_logs, :action_name, :action

    add_column :articles, :status_tmp, :string, default: "draft", null: false

    INT_TO_STATUS.each do |int_value, string_value|
      execute <<~SQL.squish
        UPDATE articles SET status_tmp = '#{string_value}' WHERE status = #{int_value}
      SQL
    end

    remove_index :articles, :status
    remove_index :articles, [ :user_id, :status ]
    remove_column :articles, :status

    rename_column :articles, :status_tmp, :status
    add_index :articles, :status
    add_index :articles, [ :user_id, :status ]
  end
end
