class CreateRooms < ActiveRecord::Migration[8.1]
  def change
    create_table :rooms do |t|
      t.string :code, null: false
      t.text :text, null: false, default: ""
      t.datetime :last_activity_at, null: false
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :rooms, :code, unique: true
    add_index :rooms, :last_activity_at
  end
end
