class AddDetailsToBookings < ActiveRecord::Migration[7.1]
  def change
    add_column :bookings, :guest_name, :string
    add_column :bookings, :guest_phone, :string
    add_column :bookings, :guest_passport, :string
    add_column :bookings, :cancellation_reason, :text
  end
end
