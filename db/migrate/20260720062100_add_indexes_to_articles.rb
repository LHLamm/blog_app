class AddIndexesToArticles < ActiveRecord::Migration[8.1]
    def change
    remove_index :articles, :user_id
    add_index :articles, [ :user_id, :status ]


    add_index :articles, :published_at
  end
end
