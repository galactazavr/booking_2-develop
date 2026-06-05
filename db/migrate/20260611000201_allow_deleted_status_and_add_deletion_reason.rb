class AllowDeletedStatusAndAddDeletionReason < ActiveRecord::Migration[7.1]
  def up
    # Remove old constraints
    execute "ALTER TABLE hotels DROP CONSTRAINT IF EXISTS chk_hotels_status_values"
    execute "ALTER TABLE properties DROP CONSTRAINT IF EXISTS chk_properties_status_values"

    # Add new constraints
    execute "ALTER TABLE hotels ADD CONSTRAINT chk_hotels_status_values CHECK (status::text = ANY (ARRAY['review'::text, 'active'::text, 'rejected'::text, 'deleted'::text]))"
    execute "ALTER TABLE properties ADD CONSTRAINT chk_properties_status_values CHECK (status::text = ANY (ARRAY['review'::text, 'active'::text, 'rejected'::text, 'deleted'::text]))"

    # Add deletion_reason column
    add_column :hotels, :deletion_reason, :text
    add_column :properties, :deletion_reason, :text
  end

  def down
    remove_column :hotels, :deletion_reason
    remove_column :properties, :deletion_reason

    execute "ALTER TABLE hotels DROP CONSTRAINT IF EXISTS chk_hotels_status_values"
    execute "ALTER TABLE properties DROP CONSTRAINT IF EXISTS chk_properties_status_values"

    execute "ALTER TABLE hotels ADD CONSTRAINT chk_hotels_status_values CHECK (status::text = ANY (ARRAY['review'::text, 'active'::text, 'rejected'::text]))"
    execute "ALTER TABLE properties ADD CONSTRAINT chk_properties_status_values CHECK (status::text = ANY (ARRAY['review'::text, 'active'::text, 'rejected'::text]))"
  end
end
