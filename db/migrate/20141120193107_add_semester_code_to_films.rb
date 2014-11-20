class AddSemesterCodeToFilms < ActiveRecord::Migration
  def change
    add_column :films, :semester_code, :string
    Film.all.each(&:update_semester_code)
  end
end
