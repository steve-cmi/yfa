class Experience < ActiveRecord::Base
  belongs_to :activity
  belongs_to :person
end
