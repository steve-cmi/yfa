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

# -------- PEOPLE --------

admin = Person.find_or_create_by_email('steve.friedman@commonmediainc.com',
  fname: 'Steve',
  lname: 'Friedman',
  year: 2014,
  college: YALE_COLLEGES.keys.first,
  active: true,
  site_admin: true,
  netid: 'cmi1'
)

tarantino = Person.find_or_create_by_email('quentin@tarantino.com',
  fname: 'Quentin',
  lname: 'Tarantino',
  year: 2014,
  college: YALE_COLLEGES.keys.last,
  active: true
)

lynch = Person.find_or_create_by_email('dave@lynch.com',
  fname: 'David',
  lname: 'Lynch',
  year: 2014,
  college: YALE_COLLEGES.keys.first,
  active: true
)

anderson = Person.find_or_create_by_email('wes@anderson.com',
  fname: 'Wes',
  lname: 'Anderson',
  year: 2014,
  college: YALE_COLLEGES.keys.last,
  active: true
)

wilson = Person.find_or_create_by_email('owen@wilson.com',
  fname: 'Owen',
  lname: 'Wilson',
  year: 2014,
  college: YALE_COLLEGES.keys.last,
  active: true
)

kubrick = Person.find_or_create_by_email('stanley@kubrick.com',
  fname: 'Stanley',
  lname: 'Kubrick',
  year: 2014,
  college: YALE_COLLEGES.keys.first,
  active: true
)

clarke = Person.find_or_create_by_email('arthur@clarke.com',
  fname: 'Arthur C.',
  lname: 'Clarke',
  year: 2014,
  college: YALE_COLLEGES.keys.first,
  active: true
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

# -------- FILMS --------

space = Film.find_or_create_by_title('2001: A Space Odyssey',
  category: 'film',
  tagline: "I'm afraid I can't do that",
  contact: 'mgm@studios.com',
  description: 'Hal goes mayday. Classical music galore. Also the best slit-screen effect ever.',
  start_date: Date.parse('2014-11-25'),
  end_date: Date.parse('2014-12-03')
)

FilmPosition.find_or_create_by_film_id_and_position_id(space.id, director.id, person_id: kubrick.id)
FilmPosition.find_or_create_by_film_id_and_position_id(space.id, writer.id, person_id: kubrick.id)
FilmPosition.find_or_create_by_film_id_and_position_id(space.id, writer.id, person_id: clarke.id)

tenenbaums = Film.find_or_create_by_title('The Royal Tenenbaums',
  category: 'film',
  tagline: "I can't even begin to think about knowing how to describe this movie.",
  contact: 'anderson@studios.com',
  description: 'Royal saves his family from the wreckage of a destroyed sinking battleship.',
  start_date: Date.parse('2014-12-05'),
  end_date: Date.parse('2014-12-30')
)

FilmPosition.find_or_create_by_film_id_and_position_id(tenenbaums.id, director.id, person_id: anderson.id)
FilmPosition.find_or_create_by_film_id_and_position_id(tenenbaums.id, writer.id, person_id: anderson.id)
FilmPosition.find_or_create_by_film_id_and_position_id(tenenbaums.id, writer.id, person_id: wilson.id)

eraserhead = Film.find_or_create_by_title('Eraserhead',
  category: 'film',
  tagline: "But they're new!",
  contact: 'lynch@studios.com',
  description: "I have no idea what's going on right now.",
  start_date: Date.parse('2014-12-15'),
  end_date: Date.parse('2015-01-03')
)

FilmPosition.find_or_create_by_film_id_and_position_id(eraserhead.id, director.id, person_id: lynch.id)
FilmPosition.find_or_create_by_film_id_and_position_id(eraserhead.id, writer.id, person_id: lynch.id)

# -------- BUILDINGS --------

require 'csv'
CSV.foreach("db/buildings.csv") do |row|
  name, code, address, city_state, zip = row
  Building.find_or_create_by_code(code, name: name, address: address, city_state: city_state, zip: zip)
end

# -------- FILTERS --------

other_film    = Filter.find_or_create_by_name('Film Screenings')
student_film  = Filter.find_or_create_by_name('Student Film Screenings')
tea           = Filter.find_or_create_by_name('Master\'s Teas')
workshop      = Filter.find_or_create_by_name('Workshops and Master\'s Classes')
dcma          = Filter.find_or_create_by_name('DCMA Workshop Schedule')
pub           = Filter.find_or_create_by_name('Public Events')
other         = Filter.find_or_create_by_name('Other')

# -------- EVENTS --------

workshop = Event.find_or_create_by_name('Acting Workshop',
  minutes: 120,
  location: 'Campus Center',
  building_id: 1,
  description: 'Acting! Genius! Thank you!',
  featured: true,
  image: File.new('db/seed-images/event-acting-workshop.gif')
)

EventDate.find_or_create_by_event_id_and_starts_at(workshop.id, '2014-11-20 12:00:00')
EventDate.find_or_create_by_event_id_and_starts_at(workshop.id, '2014-11-20 16:00:00')
EventDate.find_or_create_by_event_id_and_starts_at(workshop.id, '2014-11-21 10:00:00')

EventsFilter.find_or_create_by_event_id_and_filter_id(workshop.id, tea.id)
EventsFilter.find_or_create_by_event_id_and_filter_id(workshop.id, pub.id)

film_fest = Event.find_or_create_by_name('Film Festival',
  minutes: 480,
  location: 'Campus Auditorium',
  building_id: 2,
  description: 'All the films!',
  featured: true,
  image: File.new('db/seed-images/event-film-festival.jpg')
)

EventDate.find_or_create_by_event_id_and_starts_at(film_fest.id, '2014-11-20 11:00:00')
EventDate.find_or_create_by_event_id_and_starts_at(film_fest.id, '2014-11-21 11:00:00')
EventDate.find_or_create_by_event_id_and_starts_at(film_fest.id, '2014-11-22 11:00:00')

EventsFilter.find_or_create_by_event_id_and_filter_id(film_fest.id, other_film.id)
EventsFilter.find_or_create_by_event_id_and_filter_id(film_fest.id, pub.id)














