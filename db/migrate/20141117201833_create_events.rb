class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name
      t.string :slug
      t.integer :minutes
      t.string :location
      t.belongs_to :building
      t.text :description
      t.attachment :image
      t.string :sponsor_name
      t.string :sponsor_link
      t.boolean :featured
      t.timestamps
    end

    create_table :event_dates do |t|
      t.belongs_to :event
      t.datetime :starts_at
      t.integer :minutes
      t.string :location
      t.belongs_to :building
    end

    create_table :filters do |t|
      t.string :name
      t.string :slug
      t.timestamps
    end

    create_table :events_filters do |t|
      t.belongs_to :event
      t.belongs_to :filter
      t.timestamps
    end

    create_table :buildings do |t|
      t.string :code
      t.string :name
      t.string :address
      t.string :city_state
      t.string :zip
    end
  end
end
