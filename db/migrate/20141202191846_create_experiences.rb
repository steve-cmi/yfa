class CreateExperiences < ActiveRecord::Migration
  def change
    create_table :experiences do |t|
      t.belongs_to :activity
      t.belongs_to :person
      t.timestamps
    end
  end
end
