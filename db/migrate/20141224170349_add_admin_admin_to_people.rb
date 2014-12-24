class AddAdminAdminToPeople < ActiveRecord::Migration
  def change
    add_column :people, :admin_admin, :boolean, :after => :site_admin
    Person.where(:site_admin => true).update_all(:admin_admin => true)
  end
end
