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
  carousel_order: 'date'
)

# ------- ANNOUNCEMENT --------

Announcement.find_or_create_by_id(1,
  title: 'Brand new site launched!',
  body: "We've launched a brand new site! Check out all the new features. You can browse for films and filmmakers, look for opporunitues in film, check out our calendar of film events, and even donate to support film at Yale!",
  link_text: 'Our films page is particularly cool!',
  link_url: '/films'
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

actor             = Position.find_or_create_by_position('Actor', key: 'actor')
director          = Position.find_or_create_by_position('Director', key: 'director')
editor            = Position.find_or_create_by_position('Editor', key: 'editor')
cinematographer   = Position.find_or_create_by_position('Cinematographer')
sound_editor      = Position.find_or_create_by_position('Sound editor')
composer          = Position.find_or_create_by_position('Composer')
producer          = Position.find_or_create_by_position('Producer', key: 'producer')
writer            = Position.find_or_create_by_position('Writer', key: 'writer')
prod_asst         = Position.find_or_create_by_position('Production Assistant')
makeup_artist     = Position.find_or_create_by_position('Make-up Artist')
prod_designer     = Position.find_or_create_by_position('Production Designer')
costume_designer  = Position.find_or_create_by_position('Costume Designer')
asst_director     = Position.find_or_create_by_position('1st Assistant Director')

# -------- GENRES --------

comedy  = Genre.find_or_create_by_name('Comedy')
drama   = Genre.find_or_create_by_name('Drama')
short   = Genre.find_or_create_by_name('Short')
music   = Genre.find_or_create_by_name('Music Video')

# -------- FILTERS --------

other_film    = Filter.find_or_create_by_name('Film Screenings')
student_film  = Filter.find_or_create_by_name('Student Film Screenings')
tea           = Filter.find_or_create_by_name('Master\'s Teas')
work          = Filter.find_or_create_by_name('Workshops and Master\'s Classes')
dcma          = Filter.find_or_create_by_name('DCMA Workshops')
pub           = Filter.find_or_create_by_name('Public Events')
other         = Filter.find_or_create_by_name('Other Events')

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
  site_admin: true,
  netid: 'cmi1'
)

if Person.count == 1
  Person.populate(40) do |p|
    p.fname = Faker::Name.first_name
    p.lname = Faker::Name.last_name
    p.slug = Faker::Internet.slug
    p.email = Faker::Internet.email
    p.year = Faker::Number.between(2010, 2014)
    p.college = Yale::colleges.keys
    p.active = true
    p.email_allow = true
  end
end

# -------- EVENTS --------

start_date = Date.today
end_date = Date.today.next_month
placeholder = File.new('db/seed-images/placeholder-large.png')

if Event.count == 0
  Event.populate(40) do |e|
    e.name = Faker::Lorem.sentence(3)
    e.slug = Faker::Internet.slug
    e.minutes = Faker::Number.digit.to_i * 30
    e.location = Faker::Address.street_name
    e.building_id = rand(Building.count) + 1
    e.description = Faker::Lorem.paragraphs(3).collect {|x| "<p>#{x}</p>"}.join
    e.sponsor_name = Faker::Company.name
    e.sponsor_link = Faker::Internet.url
    e.featured = [true, false]
  end
  Event.all.each do |e|
    e.image = placeholder
    e.save
  end
end

if EventDate.count == 0
  EventDate.populate(300) do |d|
    d.event_id = rand(Event.count) + 1
    d.starts_at = Faker::Time.between(start_date, end_date, :day)
  end
end

if EventsFilter.count == 0
  EventsFilter.populate(100) do |f|
    f.event_id = rand(Event.count) + 1
    f.filter_id = rand(Filter.count) + 1
  end
end

# -------- FILMS --------

start_date = Date.parse('2010-01-01')
end_date = Yale::year_end

if Film.count == 0
  Film.populate(400) do |f|
    f.category = 'film'
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
  Film.all.each do |f|
    f.poster = placeholder
    f.save
  end
end

if FilmPosition.count == 0
  Film.all.each do |film|
    film.film_positions.create(:person_id => rand(Person.count) + 1, :position_id => 2)
  end
end

if FilmsGenre.count == 0
  FilmsGenre.populate(500) do |f|
    f.film_id = rand(Film.count) + 1
    f.genre_id = rand(Genre.count) + 1
  end
end