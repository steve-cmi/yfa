class Yale

  def self.colleges
    @@colleges ||= {
      'BK' => 'Berkeley', 
      'BR' => 'Branford', 
      'CC' => 'Calhoun', 
      'DC' => 'Davenport', 
      'JE' => 'JE', 
      'MC' => 'Morse', 
      'PC' => 'Pierson', 
      'SY' => 'Saybrook', 
      'SM' => 'Silliman', 
      'ES' => 'Stiles', 
      'TD' => 'Timothy Dwight',   
      'TC' => 'Trumbull' 
    }
  end

  # Determine semesters and academic years.
  YEAR_START_MONTH = 8 # August is in the second semester, July is in the first

  def self.semester_start
    today = Date.today
    if today.month >= YEAR_START_MONTH
      Date.new today.year, YEAR_START_MONTH, 1
    else
      Date.new today.year, 1, 1
    end
  end

  def self.semester_end
    today = Date.today
    if today.month >= YEAR_START_MONTH
      Date.new today.year + 1, 1, 1
    else
      Date.new today.year, YEAR_START_MONTH, 1
    end
  end

  def self.year_start
    today = Date.today
    if today.month >= YEAR_START_MONTH
      Date.new today.year, YEAR_START_MONTH, 1
    else
      Date.new today.year - 1, YEAR_START_MONTH, 1
    end
  end

  def self.year_end
    today = Date.today
    if today.month >= YEAR_START_MONTH
      Date.new today.year + 1, YEAR_START_MONTH, 1
    else
      Date.new today.year, YEAR_START_MONTH, 1
    end
  end

  # Convert a static term_code into a ruby date range
  # @param term_code [String] the term_code to search for
  # examples: 201201 is spring 2012, 201103 is fall 2011
  def self.term_to_range(term_code)
    year = term_code.slice(0, 4).to_i
    term = term_code.slice(4, 2).to_i
    if term == 1 # spring
      (Date.new(year, 1, 1) .. Date.new(year, YEAR_START_MONTH, 1))
    elsif term == 3 # fall
      (Date.new(year, YEAR_START_MONTH, 1) .. Date.new(year, 12, 31))
    end
  end

end