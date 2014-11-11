class DropReservations < ActiveRecord::Migration
  def up
    drop_table :reservations
    drop_table :reservation_types
    remove_column :showtimes, :reminder_sent

    remove_column :shows, :alt_tix
    remove_column :shows, :seats
    remove_column :shows, :cap
    remove_column :shows, :waitlist
    remove_column :shows, :show_waitlist
    remove_column :shows, :tix_enabled
    remove_column :shows, :freeze_mins_before
    remove_column :shows, :on_sale
    remove_column :shows, :charges_at_door
    remove_column :shows, :private_registration_token
    remove_column :shows, :waitlist_seats
  end

  def down
    create_table :reservation_types, :force => true do |t|
      t.string :tix_type, :limit => 50, :null => false
    end

    create_table :reservations, :force => true do |t|
      t.string    :fname, :limit => 50, :null => false
      t.string    :lname, :limit => 50, :null => false
      t.string    :email, :null => false
      t.integer   :num, :limit => 1, :null => false
      t.timestamp :updated_at, :null => false
      t.integer   :showtime_id, :null => false
      t.integer   :reservation_type_id, :limit => 2, :null => false
      t.datetime  :created_at
      t.integer   :person_id
      t.integer   :used, :default => 0, :null => false
      t.text      :token
    end

    add_column :showtimes, :reminder_sent, :boolean
    add_column :shows, :alt_tix, :string
    add_column :shows, :seats, :integer
    add_column :shows, :cap, :integer
    add_column :shows, :waitlist, :boolean
    add_column :shows, :show_waitlist, :boolean
    add_column :shows, :tix_enabled, :boolean
    add_column :shows, :freeze_mins_before, :integer
    add_column :shows, :on_sale, :date
    add_column :shows, :charges_at_door, :boolean
    add_column :shows, :private_registration_token, :string
    add_column :shows, :waitlist_seats, :integer
  end
end
