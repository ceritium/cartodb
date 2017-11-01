require 'carto/db/migration_helper'

include Carto::Db::MigrationHelper

migration(
  Proc.new do
    create_table :user_tokens do
      Uuid          :id, primary_key: true, default: 'uuid_generate_v4()'.lit
      foreign_key   :user_table_id, :user_tables, null: false, type: :uuid, on_delete: :cascade
      Boolean       :writable, default: false, null: false
      String        :token, null: false
      DateTime      :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      DateTime      :updated_at, null: false, default: Sequel::CURRENT_TIMESTAMP
    end

    alter_table :user_tokens do
      add_index :user_table_id
      add_index :token, unique: true
    end
  end,

  Proc.new do
    drop_table :user_tokens
  end
)
