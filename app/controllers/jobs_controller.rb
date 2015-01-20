class JobsController < ApplicationController

  before_filter :verify_user, :except => :index

  def index
    @page_name = "Jobs & Internships"
    
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

    @scopes = [:start_date, :post_date, :position, :location]
    @scope = (params[:scope] || :start_date).to_sym
    @jobs = @jobs.send("by_#{@scope}")
  end

  def new
    @active_nav = :user
    @active_subnav = :jobs
    @job = Job.new
  end
  
  def show
    @active_nav = :user
    @active_subnav = :jobs
    @job = Job.find(params[:id])
    render :edit
  end
  
  def edit
    @active_nav = :user
    @active_subnav = :jobs
    @job = Job.find(params[:id])
  end
  
  def create
    @job = Job.new
    if @job.update_attributes(params[:job])
      redirect_to admin_jobs_path, :notice => 'Job was successfully created.'
    else
      render :new
    end
  end
  
  def update
    @job = Job.find(params[:id])
    if @job.update_attributes(params[:job])
      redirect_to admin_jobs_path, :notice => 'Job was successfully updated.'
    else
      render :edit
    end
  end

  def update_all
    Job.update params[:jobs].keys, params[:jobs].values
    redirect_to admin_jobs_path, :notice => 'Jobs were successfully updated.'
  end
  
  def destroy
    @job = Job.find(params[:id]) rescue nil
    @job.destroy if @job
    redirect_to admin_jobs_path, :notice => 'Job was successfully deleted.'
  end
  
  private
  
  def verify_user
    redirect_to root_path unless @current_user and @current_user.site_admin?
  end

end
