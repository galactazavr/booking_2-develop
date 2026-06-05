class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :message, null: false
      t.boolean :read, default: false, null: false
      t.references :booking, foreign_key: true

      t.timestamps
    end
  end
end
