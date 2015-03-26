# Load the rails application
require File.expand_path('../application', __FILE__)

# Site emails. Needed by config/environments/.
YFA_EMAIL = 'yalefilmalliance@gmail.com'
YCA_EMAIL = 'ycarts@yale.edu'
DEV_EMAIL = ['david.preschel@yale.edu', 'steve.friedman@commonmediainc.com', YCA_EMAIL]

# Initialize the rails application
Yfa::Application.initialize!

CASClient::Frameworks::Rails::Filter.configure(
  :cas_base_url => "https://secure.its.yale.edu/cas/",
  :username_session_key => :cas_user,
  :extra_attributes_session_key => :cas_extra_attributes
)

ActionMailer::Base.raise_delivery_errors = true
