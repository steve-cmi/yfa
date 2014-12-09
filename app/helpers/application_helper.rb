module ApplicationHelper

  def short_date(date)
    return nil unless date
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
    return nil unless date
    today = Date.today
    if date == today
      date.strftime('Today, %B %-d')
    elsif date == today - 1
      date.strftime('Yesterday, %B %-d')
    elsif date.year == today.year
      date.strftime('%A, %B %-d')
    else
      date.strftime('%B %-d, %Y')
    end
  end

  def time(date)
    date.strftime('%-l:%M%p') if date
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

  def javascript(*files)
    content_for(:head) { javascript_include_tag(*files) }
  end

  # Format all phone numbers as: 111-222-3333
  def format_phone(string)
    return nil if string.blank?
    arr = string.scan(/(\d)/)
    return nil if !arr || arr.empty?
    arr.slice!(0,1) if arr.first.first == '1'
    return nil if arr.length != 10
    [arr.slice!(0,3).join,arr.slice!(0,3).join,arr.slice!(0,4).join].join('-')
  end

  def link_to_remove_fields(name, f)
    if f.object.new_record?
      link_to_function(name, "remove_added_fields(this)", :class => "remove btn btn-info")
    else
      f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)", :class => "remove btn btn-danger")
    end
  end
  
  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")", :class => "add-link btn btn-primary")
  end
  
  def link_to_cast_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    new_object.position_id = Position.actor_id
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")", :class => "add-link btn btn-primary")
  end

  def link_to_file(object)
    link_to object.key.split("/")[-1], "#{object.url_for(:read)}", target: '_blank'
  end

  def image_field(builder, column, size = :show)
    if builder.object.send(column)
      image_tag(builder.object.send(column).url(size),
        :id => 'show-image',
        :onClick => "$('#show-image').toggle(); $('#edit-image').toggle()",
        "data-toggle" => "tooltip",
        "data-placement" => "right",
        :title => "Click to replace") +
      builder.file_field(column, :class => 'form-control', :id => 'edit-image', :style => 'display:none')
    else
      builder.file_field(column, :class => 'form-control')
    end
  end
  	
end