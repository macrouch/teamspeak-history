class CreateChannelsSessions < ActiveRecord::Migration
  def change
    create_table :channels_sessions, id: false do |t|
      t.references :channel, null: false
      t.references :session, null: false
    end
  end
end
