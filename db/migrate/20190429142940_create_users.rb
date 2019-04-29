class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.text :user_id
      t.text :user_name
      t.text :jwt
      t.datetime :jwt_expires_at

      t.timestamps
    end

    add_index :users, :user_id, unique: true
    add_index :users, :user_name, unique: true
    
  end
end
