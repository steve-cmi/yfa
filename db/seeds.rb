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

Filter.find_or_create_by_name('Screenings')
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

# Admins
Person.
  find_or_create_by_email('steve.friedman@commonmediainc.com').
  update_attributes(
    fname: 'Steve',
    lname: 'Friedman',
    year: 2015,
    college: 'CC',
    active: true,
    email_allow: true,
    site_admin: true,
    admin_admin: true,
    netid: 'sf583'
  )

Person.
  find_or_create_by_email('derek.webster@yale.edu').
  update_attributes(
    fname: 'Derek',
    lname: 'Webster',
    year: 1999,
    college: 'PC',
    active: true,
    email_allow: true,
    site_admin: true,
    admin_admin: true,
    netid: 'dereks'
  )

Person.
  find_or_create_by_email('dara.eliacin@yale.edu').
  update_attributes(
    fname: 'Dara',
    lname: 'Eliacin',
    year: 2015,
    college: 'BR',
    active: true,
    email_allow: true,
    site_admin: true,
    admin_admin: true,
    netid: 'dye2'
  )

Person.
  find_or_create_by_email('darice.corey@yale.edu').
  update_attributes(
    fname: 'Darice',
    lname: 'Corey-Gilbert',
    year: 2019,
    college: 'BK',
    active: true,
    email_allow: true,
    site_admin: true,
    admin_admin: true,
    netid: 'dic59'
  )

# -------- PAGES --------

# MAIN MENU

Page.find_or_create_by_slug('film-fest',
  title: 'Yale College Film Festival',
  content: '<h4>This page is under construction</h4>',
  menu: 'main',
  menu_title: 'Film Fest'
)

Page.find_or_create_by_slug('board',
  title: 'Meet the Board',
  content: '<h4>This page is under construction</h4>',
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
  content: '<h4>This page is under construction</h4>',
  menu: 'resources',
  menu_title: 'Campus Film Groups'
)

Page.find_or_create_by_slug('institutional-resources',
  title: 'Institutional Resources',
  content: '<h4>This page is under construction</h4>',
  menu: 'resources',
  menu_title: 'Institutional Resources'
)

Page.find_or_create_by_slug('academic-studies-in-film',
  title: 'Academic Studies in Film',
  content: '<h4>This page is under construction</h4>',
  menu: 'resources',
  menu_title: 'Academic Studies in Film'
)

Page.find_or_create_by_slug('online-resources',
  title: 'Online Resources',
  content: '<h4>This page is under construction</h4>',
  menu: 'resources',
  menu_title: 'Online Resources'
)

# HOW TOS

Page.find_or_create_by_slug('pre-production',
  title: 'Pre-production',
  lead: 'This page is under construction',
  content: '<h4>This page is under construction</h4>',
  menu: 'howtos',
  menu_title: 'Pre-production'
)

Page.find_or_create_by_slug('production',
  title: 'Production',
  lead: 'This page is under construction',
  content: '<h4>This page is under construction</h4>',
  menu: 'howtos',
  menu_title: 'Production'
)

Page.find_or_create_by_slug('faq',
  title: 'FAQ',
  lead: 'This page is under construction',
  content: '<h4>This page is under construction</h4>',
  menu: 'howtos',
  menu_title: 'FAQ'
)

Page.find_or_create_by_slug('how-to-title',
  title: 'How To Title',
  lead: 'This page is under construction',
  content: '<h4>This page is under construction</h4>',
  menu: 'howtos',
  menu_title: 'How To Title'
)
