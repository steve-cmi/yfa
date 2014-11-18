module ApplicationHelper

  def smart_date(date)
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

  def smart_time(date)
    date.strftime('%-l:%M%p')
  end

  def link_to_building(building)
    if building
      link_to building.name, "http://map.yale.edu/map/#building:#{building.code}", target: '_blank'
    end
  end

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
	
	def best_link(film, full_path = false)
		if full_path
			url_for film.url_key.blank? ? film_url(film) : vanity_url(film.url_key)
		else
			url_for film.url_key.blank? ? film : vanity_path(film.url_key)
		end
	end
	
	def square_film_thumb(poster, lazy = false)
	    c = (poster.height(:thumb) > poster.width(:thumb)) ? "poster-vertical" : "poster-horizontal"
	    if lazy
	      "<img src=\"/assets/placeholder.gif\" data-original=\"#{poster.url(:thumb)}\" class=\"#{c} lazy\">"
	    else
	      "<img src=\"#{poster.url(:thumb)}\" class=\"#{c}\">"
	    end
	end
	
	def link_to_film_title(film)
       # truncate long titles
       title = (film.archive && film.title.length > 45) ? film.title[0,45] + "..." : film.title
       tag_title = (film.archive && film.title.length > 45) ? film.title : ""
       
       if film.id.blank?
           return "<span title=\"#{film.title}\">#{title}</span>"
       else
           return link_to title, best_link(film), :title => tag_title
       end
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

  def oci_id_to_text(term)
  	year = term.first(4).to_i
  	term.last(2).to_i == 1 ? "Spring #{year}" : "Fall #{year}"
  end

  def current_oci_id
  	today = Time.now
  	"#{today.year}" + (today.month > 6 ? "03" : "01")
  end

  def next_oci_id
  	today = Time.now
  	today.month > 6 ? "#{today.year + 1}01" : "#{today.year}03"
  end
end