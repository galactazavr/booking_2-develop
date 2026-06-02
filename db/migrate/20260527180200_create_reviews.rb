class CreateReviews < ActiveRecord::Migration[7.1]
  def change
    create_table :reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.references :hotel, null: false, foreign_key: true
      t.references :booking, foreign_key: true
      t.integer :rating, null: false
      t.text :body

      t.timestamps
    end

    add_index :reviews, [:user_id, :booking_id], unique: true, name: 'index_reviews_on_user_and_booking'
  end
end
