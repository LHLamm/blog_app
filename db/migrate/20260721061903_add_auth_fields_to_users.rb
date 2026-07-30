class AddAuthFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :email, :string, null: false, default: ""
    add_column :users, :password_digest, :string, null: false, default: ""

    add_index :users, :email, unique: true
  end
end
