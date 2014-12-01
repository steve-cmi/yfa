class JobsController < ApplicationController

  def index
    @active_nav = :opportunities
    @active_subnav = :jobs

    @jobs = Job.current

    @jobs = @jobs.paid if params[:paid] == 'true'
    @jobs = @jobs.unpaid if params[:paid] == 'false'
    @jobs = @jobs.alumni_affiliated if params[:alum] == 'true'
    @jobs = @jobs.not_alumni_affiliated if params[:alum] == 'false'

    @state_options = @jobs.by_location.inject(ActiveSupport::OrderedHash.new) do |countries, job|
      country = job.country || 'United States'
      state = job.state
      key = "#{state}--#{country}"
      countries[country] ||= []
      countries[country] << [state, key] unless countries[country].include?([state, key])
      countries
    end

    unless params[:state].blank?
      state, country = params[:state].split('--')
      country = nil if country == 'United States'
      @jobs = @jobs.in_country(country).in_state(state)
    end

    @scopes = [:date, :position, :location]
    @scope = (params[:scope] || :date).to_sym
    @jobs = @jobs.send("by_#{@scope}")
  end

end
