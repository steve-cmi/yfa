class AddSlugs < ActiveRecord::Migration
  def change
    add_column :films, :slug, :string, :after => :title
    add_column :people, :slug, :string, :after => :lname
  end
end
