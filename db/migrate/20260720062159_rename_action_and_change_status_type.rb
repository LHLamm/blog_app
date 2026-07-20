class RenameActionAndChangeStatusType < ActiveRecord::Migration[8.1]
  def up
    rename_column :action_logs, :action, :action_name

    add_column :articles, :status_tmp, :integer, default: 10, null: false

    # Nếu có dữ liệu status (string) cũ cần convert sang integer,
    # chạy trước khi deploy migration này: bin/rails articles:backfill_status
    # (xem lib/tasks/articles.rake)

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

    remove_index :articles, :status
    remove_index :articles, [ :user_id, :status ]
    remove_column :articles, :status

    rename_column :articles, :status_tmp, :status
    add_index :articles, :status
    add_index :articles, [ :user_id, :status ]
  end
end
