module ApplicationHelper

  def short_date(date)
    today = Date.today
    if date == today
      'Today'
    elsif date == today - 1
      'Yesterday'
    elsif date.year == today.year
      date.strftime('%a %b %-d')
    else
      date.strftime('%b %-d %Y')
    end
  end

  def long_date(date)
    today = Date.today
    if date == today
      date.strftime('Today, %B %-d')
    elsif date == today - 1
      date.strftime('Yesterday, %B %-d')
    elsif date.year == today.year
      date.strftime('%A, %B %-d')
    else
      date.strftime('%B, %-d %Y')
    end
  end

  def time(date)
    date.strftime('%-l:%M%p')
  end

  def link_to_building(building)
    if building
      link_to building.name, "http://map.yale.edu/map/#building:#{building.code}", target: '_blank'
    end
  end

  # Generates image tags to work with jquery.lazyload.
  # Note: it is recommended that width and height options are provided.
  def lazy_image_tag(source, options = {})
    options[:src] = image_path('placeholder.gif')
    options["data-original"] = source
    options[:class] = [options[:class], 'lazy'].compact.join(' ')
    tag :img, options
  end

  def person_field(field, options = {})
    best_in_place_if @current_user && @person.id == @current_user.id, @person, field, options
  end

  def sanitize_bio(bio)
    sanitize(bio, :tags => %w(b i em strong a br)).gsub(/\n/, '<br/>').html_safe
  end

  def options_for_college
    Yale::colleges.collect do |key, value|
      [key, key]
    end
  end

  def short_year(year)
    "'" + year.to_s.last(2)
  end

  def person_listing(person)
    "#{person.name}, #{person.college} #{short_year person.year}"
  end

  # ----- OLD HELPERS ------ prune when done.

	# Expects ordered screening array, this is usually handled by the model
	def format_screenings(array)
		start = array.first.timestamp
		stop = array.last.timestamp
		if start.month == stop.month && start.day == stop.day
			str = start.strftime("%B #{start.day.ordinalize}")
		elsif start.month == stop.month
			str = start.strftime("%B %e")
			str += " &ndash; " + stop.day.to_s
		else
			str = start.strftime("%B %e")
			str += " &ndash; "
			str += stop.strftime("%B %e")
		end
		str.html_safe
	end
	
	def format_screening_full(timestamp)
		timestamp.strftime("%B %-d at %-l:%M%P")
	end
	
	def style_full_screening(timestamp)
	    @is_next ||= false
	    fs = format_screening_full(timestamp)
	    cl = (timestamp < Time.now) ? "performances-past" : ""
	    if timestamp > Time.now && !@is_next
	       @is_next = true
	       cl = "performances-next"
	    end
	    "<span class=\"#{cl}\">#{fs}</span>"
	end
	
	def format_long_rundates(film)
		return "" unless film.screenings.length > 0
		screenings = film.screenings.sort_by{|st| st.timestamp}
		start = screenings.first.timestamp
		stop = screenings.last.timestamp
		if start.month == stop.month && start.day == stop.day
			str = start.strftime("%b %-d, %Y")
		elsif start.month == stop.month
			str = start.strftime("%b %-d")
			str += " &ndash; " + stop.strftime("%-d, %Y")
		else
			str = start.strftime("%b %-d")
			str += " &ndash; "
			str += stop.strftime("%b %-d, %Y")
		end
		str.html_safe
	end
	
	def full_timestamp(time)
		time.strftime("%B #{time.day.ordinalize} at %-l:%M %P")
	end
	
	def small_timestamp(time)
		time.strftime("%b %d %-l:%M %P")
	end

	# (517) 648-8850
	def format_phone(string)
		return "" if string.blank?
		arr = string.scan(/(\d)/)
		return "" if !arr || arr.empty?
		builder = ""
		arr.slice!(0,1) if arr.first.first == "1"
		return "" if arr.length != 10
		[arr.slice!(0,3).join,arr.slice!(0,3).join,arr.slice!(0,4).join].join("-")
	end
	
  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)", :class => "remove")
  end
  
  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")", :class => "add-link")
  end
  
   def link_to_cast_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    new_object.position_id = 17
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")", :class => "add-link")
  end
  
  #Helper to load javascript page specific stuff
  def javascript(*files)
    content_for(:head) { javascript_include_tag(*files) }
  end

end