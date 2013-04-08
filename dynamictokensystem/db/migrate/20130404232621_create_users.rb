class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :email
      t.string :password
      t.datetime :token_expiry
      t.string :valid_token
      t.integer :token_rotation_count

      t.timestamps
    end
  end
end
