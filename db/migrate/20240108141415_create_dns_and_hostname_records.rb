class CreateDnsAndHostnameRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :dns do |t|
      t.string :ip, null: false

      t.timestamps
    end

    create_table :hostnames do |t|
      t.string :hostname, null: false

      t.timestamps
    end

    create_table :dns_hostnames do |t|
      t.belongs_to :dns, null: false, foreign_key: true
      t.belongs_to :hostname, null: false, foreign_key: true

      t.timestamps
    end
  end
end
