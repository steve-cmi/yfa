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
  def self.year_start_month
    8 # August is in the second semester, July is in the first
  end

  def self.spring_code
    @@spring_code ||= "01"
  end

  def self.fall_code
    @@fall_code ||= "03"
  end

  def self.semester_code_for(date)
    if date.month < year_start_month
      date.year.to_s + spring_code
    else
      date.year.to_s + fall_code
    end
  end

  def self.semester_label_for(date)
    if date.month < year_start_month
      "Spring #{date.year}"
    else
      "Fall #{date.year}"
    end
  end

  def self.this_semester
    semester_code_for(Date.today)
  end

  def self.next_semester
    semester_code_for(6.months.from_now)
  end

  def self.semester_start
    today = Date.today
    if today.month >= year_start_month
      Date.new today.year, year_start_month, 1
    else
      Date.new today.year, 1, 1
    end
  end

  def self.semester_end
    today = Date.today
    if today.month >= year_start_month
      Date.new today.year + 1, 1, 1
    else
      Date.new today.year, year_start_month, 1
    end
  end

  def self.year_start
    today = Date.today
    if today.month >= year_start_month
      Date.new today.year, year_start_month, 1
    else
      Date.new today.year - 1, year_start_month, 1
    end
  end

  def self.year_end
    today = Date.today
    if today.month >= year_start_month
      Date.new today.year + 1, year_start_month, 1
    else
      Date.new today.year, year_start_month, 1
    end
  end

  def self.this_week
    if Date.today.sunday?
      Date.today .. Date.today.next_week(:sunday)
    else
      Date.today .. Date.today.sunday
    end
  end

  # Convert a static term_code into a ruby date range
  # @param term_code [String] the term_code to search for
  # examples: 201201 is spring 2012, 201103 is fall 2011
  def self.term_to_range(term_code)
    year = term_code.slice(0, 4).to_i
    term = term_code.slice(4, 2).to_i
    if term == 1 # spring
      (Date.new(year, 1, 1) .. Date.new(year, year_start_month, 1))
    elsif term == 3 # fall
      (Date.new(year, year_start_month, 1) .. Date.new(year, 12, 31))
    end
  end

end