# frozen_string_literal: true

class AddDatabaseConstraints < ActiveRecord::Migration[7.1]
  def up
    # Расширение btree_gist для exclusion constraint
    enable_extension 'btree_gist'

    # === BOOKINGS ===

    # CHECK: check_out строго после check_in
    execute <<-SQL
      ALTER TABLE bookings
      ADD CONSTRAINT chk_bookings_checkout_after_checkin
      CHECK (check_out > check_in);
    SQL

    # CHECK: guests_count > 0
    execute <<-SQL
      ALTER TABLE bookings
      ADD CONSTRAINT chk_bookings_guests_count_positive
      CHECK (guests_count > 0);
    SQL

    # CHECK: total_price > 0
    execute <<-SQL
      ALTER TABLE bookings
      ADD CONSTRAINT chk_bookings_total_price_positive
      CHECK (total_price > 0);
    SQL

    # CHECK: status допустимые значения
    execute <<-SQL
      ALTER TABLE bookings
      ADD CONSTRAINT chk_bookings_status_values
      CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed'));
    SQL

    # EXCLUSION: защита от overbooking на уровне PostgreSQL
    # Не даёт создать пересекающиеся бронирования для одного номера
    # (только для активных бронирований — не cancelled)
    execute <<-SQL
      ALTER TABLE bookings
      ADD CONSTRAINT excl_bookings_no_overlap
      EXCLUDE USING gist (
        room_id WITH =,
        daterange(check_in, check_out) WITH &&
      )
      WHERE (status != 'cancelled');
    SQL

    # === REVIEWS ===

    # CHECK: rating от 1 до 5
    execute <<-SQL
      ALTER TABLE reviews
      ADD CONSTRAINT chk_reviews_rating_range
      CHECK (rating >= 1 AND rating <= 5);
    SQL

    # === FAVORITES ===

    # UNIQUE INDEX: один пользователь — один отель в избранном
    unless index_exists?(:favorites, [:user_id, :hotel_id])
      add_index :favorites, [:user_id, :hotel_id], unique: true, name: 'index_favorites_on_user_and_hotel'
    end

    # === HOTELS ===

    # CHECK: status допустимые значения
    execute <<-SQL
      ALTER TABLE hotels
      ADD CONSTRAINT chk_hotels_status_values
      CHECK (status IN ('review', 'active', 'rejected'));
    SQL

    # === PROPERTIES ===

    # CHECK: status допустимые значения
    execute <<-SQL
      ALTER TABLE properties
      ADD CONSTRAINT chk_properties_status_values
      CHECK (status IN ('review', 'active', 'rejected'));
    SQL

    # === USERS ===

    # CHECK: role допустимые значения
    execute <<-SQL
      ALTER TABLE users
      ADD CONSTRAINT chk_users_role_values
      CHECK (role IN ('user', 'supervisor', 'admin'));
    SQL
  end

  def down
    execute "ALTER TABLE bookings DROP CONSTRAINT IF EXISTS chk_bookings_checkout_after_checkin"
    execute "ALTER TABLE bookings DROP CONSTRAINT IF EXISTS chk_bookings_guests_count_positive"
    execute "ALTER TABLE bookings DROP CONSTRAINT IF EXISTS chk_bookings_total_price_positive"
    execute "ALTER TABLE bookings DROP CONSTRAINT IF EXISTS chk_bookings_status_values"
    execute "ALTER TABLE bookings DROP CONSTRAINT IF EXISTS excl_bookings_no_overlap"
    execute "ALTER TABLE reviews DROP CONSTRAINT IF EXISTS chk_reviews_rating_range"
    execute "ALTER TABLE hotels DROP CONSTRAINT IF EXISTS chk_hotels_status_values"
    execute "ALTER TABLE properties DROP CONSTRAINT IF EXISTS chk_properties_status_values"
    execute "ALTER TABLE users DROP CONSTRAINT IF EXISTS chk_users_role_values"

    remove_index :favorites, name: 'index_favorites_on_user_and_hotel', if_exists: true

    disable_extension 'btree_gist'
  end
end
