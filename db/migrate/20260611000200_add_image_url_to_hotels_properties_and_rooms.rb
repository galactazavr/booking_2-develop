class AddImageUrlToHotelsPropertiesAndRooms < ActiveRecord::Migration[7.1]
  def change
    add_column :hotels, :image_url, :string
    add_column :properties, :image_url, :string
    add_column :rooms, :image_url, :string
  end
end
