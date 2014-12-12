# filmalliance

The Yale Film Alliance application

## Installation instructions

1. Configure site credentials (`config/database.yml`, `config/aws.yml`, `config/email.yml`)
  * use environment variables to prevent credentials from being committed to git,
    see example code in `database.yml`.

2. `bundle install`
  * install needed Ruby gems

3. `rake db:setup`
  * create database, import schema, load seed data.
  * depends on database and aws credentials.

4. review environment file (e.g.: `config/environments/production.rb` or `staging.rb`, depending on `RAILS_ENV`)
  * adjust `config.action_mailer.default_url_options` to reflect the URL of the site, used to form links in emails

5. for production:
  * put google analytics credentials into `config/analytics.yml`.
  * may want to repoint `ExceptionNotification` settings
