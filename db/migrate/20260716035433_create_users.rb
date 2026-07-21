class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.integer :published_articles_count, null: false, default: 0

      t.timestamps
    end
  end
end
