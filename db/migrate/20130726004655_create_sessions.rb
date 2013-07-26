class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.datetime :login
      t.datetime :logout
      t.integer :idle
      t.integer :user_id

      t.timestamps
    end
  end
end
