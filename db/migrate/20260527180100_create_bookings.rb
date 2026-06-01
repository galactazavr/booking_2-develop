class CreateBookings < ActiveRecord::Migration[7.1]
  def change
    create_table :bookings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :room, null: false, foreign_key: true
      t.date :check_in, null: false
      t.date :check_out, null: false
      t.integer :guests_count, null: false, default: 1
      t.decimal :total_price, precision: 10, scale: 2, null: false
      t.string :status, null: false, default: 'pending'
      t.text :special_requests

      t.timestamps
    end

    add_index :bookings, :status
    add_index :bookings, [:check_in, :check_out]
    add_index :bookings, [:room_id, :check_in, :check_out], name: 'index_bookings_on_room_and_dates'
  end
end
