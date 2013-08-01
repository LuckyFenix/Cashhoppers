class AddDetailsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :zip, :string
    add_column :users, :user_name, :string
    add_column :users, :contact, :string
    add_column :users, :phone, :string
  end
end
