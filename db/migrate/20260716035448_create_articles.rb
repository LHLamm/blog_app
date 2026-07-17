class CreateArticles < ActiveRecord::Migration[8.1]
  def change
    create_table :articles do |t|
      t.string :title, null: false
      t.text :body
      t.string :status, null: false, default: "draft"
      t.references :user, null: false, foreign_key: true
      t.datetime :published_at

      t.timestamps
    end

    add_index :articles, :status
  end
end
