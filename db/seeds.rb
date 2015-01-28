# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# -------- SITE CONF --------

Site.find_or_create_by_id(1,
  carousel_interval: 5000,
  carousel_order: 'position'
)

# ------- ANNOUNCEMENT --------

Announcement.find_or_create_by_id(1,
  title: 'Brand new site launched!',
  body: "We've launched a brand new site! Check out all the new features. You can browse for films and filmmakers, look for opporunitues in film, check out our calendar of film events, and even donate to support film at Yale!",
  link_text: 'Our films page is particularly cool!',
  link_url: '/films'
  active: true
)

# ------- CAROUSELS --------

Carousel.find_or_create_by_title("Slideshow image one",
  body: "First slideshow image",
  active: true,
  image: File.new('db/seed-images/carousel-image-1.jpg')
)

Carousel.find_or_create_by_title("Slideshow image two",
  body: "Middle slideshow image",
  active: true,
  image: File.new('db/seed-images/carousel-image-2.jpg')
)

Carousel.find_or_create_by_title("Slideshow image three",
  body: "Last slideshow image",
  active: true,
  image: File.new('db/seed-images/carousel-image-3.jpg')
)

# -------- POSITIONS --------

Position.find_or_create_by_position('Actor', key: 'actor')
Position.find_or_create_by_position('Director', key: 'director')
Position.find_or_create_by_position('Editor', key: 'editor')
Position.find_or_create_by_position('Cinematographer')
Position.find_or_create_by_position('Sound editor')
Position.find_or_create_by_position('Composer')
Position.find_or_create_by_position('Producer', key: 'producer')
Position.find_or_create_by_position('Writer', key: 'writer')
Position.find_or_create_by_position('Production Assistant')
Position.find_or_create_by_position('Make-up Artist')
Position.find_or_create_by_position('Production Designer')
Position.find_or_create_by_position('Costume Designer')
Position.find_or_create_by_position('1st Assistant Director')

# -------- ACTIVITIES --------

Activity.find_or_create_by_name('Acting')
Activity.find_or_create_by_name('Directing')
Activity.find_or_create_by_name('Editing')
Activity.find_or_create_by_name('Cinematography')
Activity.find_or_create_by_name('Sound Editing')
Activity.find_or_create_by_name('Composing')
Activity.find_or_create_by_name('Producing')
Activity.find_or_create_by_name('Writing')
Activity.find_or_create_by_name('Make-up Artistry')
Activity.find_or_create_by_name('Production Design')
Activity.find_or_create_by_name('Costume Design')
Activity.find_or_create_by_name('Assistant Directing')
Activity.find_or_create_by_name('Color-Correcting')
Activity.find_or_create_by_name('Sound Recording (on-set/ADR/foley)')

# -------- GENRES --------

Genre.find_or_create_by_name('Comedy')
Genre.find_or_create_by_name('Drama')
Genre.find_or_create_by_name('Short')
Genre.find_or_create_by_name('Music Video')

# -------- FILTERS --------

Filter.find_or_create_by_name('Film Screenings')
Filter.find_or_create_by_name('Student Film Screenings')
Filter.find_or_create_by_name('Master\'s Teas')
Filter.find_or_create_by_name('Workshops and Master\'s Classes')
Filter.find_or_create_by_name('DCMA Workshops')
Filter.find_or_create_by_name('Public Events')
Filter.find_or_create_by_name('Other Events')

# -------- BUILDINGS --------

require 'csv'
CSV.foreach("db/buildings.csv") do |row|
  name, code, address, city_state, zip = row
  Building.find_or_create_by_code(code, name: name, address: address, city_state: city_state, zip: zip)
end

# -------- PEOPLE --------

# Admin
Person.find_or_create_by_email('steve.friedman@commonmediainc.com',
  fname: 'Steve',
  lname: 'Friedman',
  year: 2014,
  college: Yale::colleges.keys.sample,
  active: true,
  email_allow: true,
  site_admin: true,
  netid: 'cmi1'
)

if Person.count == 1
  Person.populate(40) do |p|
    p.fname = Faker::Name.first_name
    p.lname = Faker::Name.last_name
    p.slug = Faker::Internet.slug
    p.email = Faker::Internet.email
    p.year = Faker::Number.between(2010, 2018)
    p.college = Yale::colleges.keys
    p.bio = Faker::Lorem.paragraphs(3).join("\n\n")
    p.active = true
    p.email_allow = true
  end
end

if Experience.count == 0
  activity_count = Activity.count
  person_count = Person.count
  Experience.populate(125) do |e|
    e.activity_id = rand(activity_count) + 1
    e.person_id = rand(person_count) + 1
  end
end

if Interest.count == 0
  activity_count = Activity.count
  person_count = Person.count
  Interest.populate(125) do |e|
    e.activity_id = rand(activity_count) + 1
    e.person_id = rand(person_count) + 1
  end
end

# -------- EVENTS --------

start_date = Yale::semester_start
end_date = Yale::semester_end - 1

if Event.count == 0
  building_count = Building.count
  Event.populate(40) do |e|
    e.name = Faker::Lorem.sentence(3)
    e.slug = Faker::Internet.slug
    e.minutes = Faker::Number.digit.to_i * 30
    e.location = Faker::Address.street_name
    e.building_id = rand(building_count) + 1
    e.description = Faker::Lorem.paragraphs(3).collect {|x| "<p>#{x}</p>"}.join
    e.sponsor_name = Faker::Company.name
    e.sponsor_link = Faker::Internet.url
    e.featured = [true, false]
  end
end

if EventDate.count == 0
  event_count = Event.count
  EventDate.populate(300) do |d|
    d.event_id = rand(event_count) + 1
    d.starts_at = Faker::Time.between(start_date, end_date, :day)
  end
end

if EventFilter.count == 0
  event_count = Event.count
  filter_count = Filter.count
  EventFilter.populate(100) do |f|
    f.event_id = rand(event_count) + 1
    f.filter_id = rand(filter_count) + 1
  end
end

# -------- FILMS --------

start_date = Date.parse('2010-01-01')
end_date = Yale::year_end - 1

if Film.count == 0
  Film.populate(400) do |f|
    f.title = Faker::Lorem.sentence(5)
    f.slug = Faker::Internet.slug
    f.tagline = Faker::Lorem.sentence(8)
    f.contact = Faker::Internet.email
    f.description = Faker::Lorem.paragraphs(3).collect {|x| "<p>#{x}</p>"}.join
    f.aud_info = Faker::Lorem.paragraph
    f.approved = true
    f.start_date = Faker::Date.between(start_date, end_date)
    f.end_date = Faker::Date.between(f.start_date, end_date)
    f.auditions_enabled = true
    f.archive = f.archive_reminder_sent = false
  end
end

if FilmPosition.count == 0
  person_count = Person.count
  positions = Position.all
  Film.all.each do |f|
    Position.all.each do |p|
      position_count = p.id == 1 ? 10 : 1
      FilmPosition.populate(position_count) do |fp|
        fp.film_id = f.id
        fp.position_id = p.id
        fp.person_id = rand(person_count) + 1 if p.id == 2 or [true, false].sample
        fp.character = Faker::Name.name if p.id == 1
      end
    end
  end
end

if FilmGenre.count == 0
  film_count = Film.count
  genre_count = Genre.count
  FilmGenre.populate(500) do |f|
    f.film_id = rand(film_count) + 1
    f.genre_id = rand(genre_count) + 1
  end
end

if Screening.count == 0
  building_count = Building.count
  Film.all.each do |f|
    Screening.populate([4,5,6,7].sample) do |s|
      s.film_id = f.id
      s.starts_at = Faker::Time.between(f.end_date, end_date, :day)
      s.location = Faker::Address.street_name
      s.building_id = rand(building_count) + 1
    end
  end
end

if Link.count == 0
  (Film.all + Person.all).each do |i|
    Link.populate([1,2,3,4,5,6].sample) do |v|
      v.item_id = i.id
      v.item_type = i.class.to_s
      v.name = Faker::Company.name
      v.url = Faker::Internet.url
    end
  end
end

if Audition.count == 0
  Film.this_semester.each do |f|
    Audition.populate([2,3,4,5,6,7,8].sample) do |a|
      a.film_id = f.id
      a.starts_at = Faker::Time.between(f.start_date, f.end_date, :day)
      a.location = Faker::Address.street_name
    end
  end
end

if Permission.count == 0
  film_count = Film.count
  person_count = Person.count
  Permission.populate(500) do |f|
    f.film_id = rand(film_count) + 1
    f.person_id = rand(person_count) + 1
  end
end

# -------- JOBS --------

start_date = Yale::year_start
end_date = Yale::year_end - 1

if Job.count == 0
  Job.populate(15) do |j|
    j.start_date = Faker::Date.between(start_date, end_date)
    j.end_date = Faker::Date.between(j.start_date, end_date)
    j.position = ['Intern', 'Contractor', 'Part Time', 'Full Time']
    j.title = Faker::Lorem.sentence
    j.compensation = [nil, "$#{Faker::Number.number(2)} per hour"]
    j.alumni_affiliation = [true, false]
    j.company = Faker::Company.name
    j.street = Faker::Address.street_address
    j.suite = [nil, Faker::Address.secondary_address]
    j.city = Faker::Address.city
    j.state = Faker::Address.state_abbr
    j.zip = Faker::Address.zip
    j.country = [nil, nil, nil, Faker::Address.country]
    j.email = Faker::Internet.email
    j.phone = Faker::PhoneNumber.phone_number
    j.website = Faker::Internet.url
    j.description = Faker::Lorem.paragraphs([2,3].sample).collect {|x| "<p>#{x}</p>"}.join
    j.application_instructions = Faker::Lorem.sentence
    j.application_link = Faker::Internet.url
  end
end

# -------- PAGES --------

# MAIN MENU

Page.find_or_create_by_slug('film-fest',
  title: 'Yale College Film Festival',
  content: Faker::Lorem.paragraphs([4,5,6].sample).collect {|x| "<p>#{x}</p>"}.join,
  menu: 'main',
  menu_title: 'Film Fest'
)

Page.find_or_create_by_slug('board',
  title: 'Meet the Board',
  content: Faker::Lorem.paragraphs([4,5,6].sample).collect {|x| "<p>#{x}</p>"}.join,
  menu: 'main',
  menu_title: 'Meet the Board'
)

Page.find_or_create_by_slug('donate',
  title: 'Donate',
  content: '<h4>The YFA uses funds to provide refreshments at YFA sponsored events, publicize events, purchase supplies, and any other event-related expenses.</h4><p>&nbsp;</p><h4>Make checks payable to:</h4><p>&nbsp;</p><div class="jumbotron">Yale Film Alliance: An Undergraduate Organization</div><h4>Mail to:</h4><div class="jumbotron">Yale Film Alliance<br />[TODO: Contact Information]</div><p>Please note that donations to the YFA are not tax-deductable.</p>',
  menu: 'main',
  menu_title: 'Donate'
)

# RESOURCES

Page.find_or_create_by_slug('film-groups',
  title: 'Campus Film Groups',
  content: Faker::Lorem.paragraphs([4,5,6].sample).collect {|x| "<p>#{x}</p>"}.join,
  menu: 'resources',
  menu_title: 'Campus Film Groups'
)

Page.find_or_create_by_slug('institutional-resources',
  title: 'Institutional Resources',
  content: Faker::Lorem.paragraphs([4,5,6].sample).collect {|x| "<p>#{x}</p>"}.join,
  menu: 'resources',
  menu_title: 'Institutional Resources'
)

Page.find_or_create_by_slug('academic-studies-in-film',
  title: 'Academic Studies in Film',
  content: Faker::Lorem.paragraphs([4,5,6].sample).collect {|x| "<p>#{x}</p>"}.join,
  menu: 'resources',
  menu_title: 'Academic Studies in Film'
)

Page.find_or_create_by_slug('online-resources',
  title: 'Online Resources',
  content: Faker::Lorem.paragraphs([4,5,6].sample).collect {|x| "<p>#{x}</p>"}.join,
  menu: 'resources',
  menu_title: 'Online Resources'
)

# HOW TOS

Page.find_or_create_by_slug('pre-production',
  title: 'Pre-production',
  lead: Faker::Lorem.sentences([2,3].sample).join(' '),
  content: Faker::Lorem.paragraphs([4,5,6].sample).collect {|x| "<p>#{x}</p>"}.join,
  menu: 'howtos',
  menu_title: 'Pre-production'
)

Page.find_or_create_by_slug('production',
  title: 'Production',
  lead: Faker::Lorem.sentences([2,3].sample).join(' '),
  content: Faker::Lorem.paragraphs([4,5,6].sample).collect {|x| "<p>#{x}</p>"}.join,
  menu: 'howtos',
  menu_title: 'Production'
)

Page.find_or_create_by_slug('faq',
  title: 'FAQ',
  lead: Faker::Lorem.sentences([2,3].sample).join(' '),
  content: Faker::Lorem.paragraphs([4,5,6].sample).collect {|x| "<p>#{x}</p>"}.join,
  menu: 'howtos',
  menu_title: 'FAQ'
)

Page.find_or_create_by_slug('how-to-title',
  title: 'How To Title',
  lead: Faker::Lorem.sentences([2,3].sample).join(' '),
  content: Faker::Lorem.paragraphs([4,5,6].sample).collect {|x| "<p>#{x}</p>"}.join,
  menu: 'howtos',
  menu_title: 'How To Title'
)
