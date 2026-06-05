class AddDetailFieldsToHotelsPropertiesAndRooms < ActiveRecord::Migration[7.1]
  def change
    add_column :hotels, :check_in_time, :string, default: '14:00'
    add_column :hotels, :check_out_time, :string, default: '12:00'
    add_column :hotels, :amenities, :text, array: true, default: []
    add_column :hotels, :rules, :text

    add_column :properties, :check_in_time, :string, default: '14:00'
    add_column :properties, :check_out_time, :string, default: '12:00'
    add_column :properties, :amenities, :text, array: true, default: []
    add_column :properties, :rules, :text

    add_column :rooms, :view_type, :string, default: 'Во двор'
    add_column :rooms, :amenities, :text, array: true, default: []
  end
end
