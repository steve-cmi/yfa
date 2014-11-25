class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.date :start_date
      t.date :end_date

      t.string :position
      t.string :title
      t.string :compensation
      t.boolean :alumni_affiliation

      t.string :company
      t.string :street
      t.string :suite
      t.string :city
      t.string :state
      t.string :zip
      t.string :country
      t.string :email
      t.string :phone
      t.string :website

      t.text :description
      t.text :application_instructions
      t.string :application_link

      t.timestamps
    end
  end
end
