class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.integer :carousel_interval
      t.enum :carousel_order, limit: [:position, :random]
      t.timestamps
    end
  end
end
