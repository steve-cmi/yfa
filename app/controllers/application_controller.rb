class ApplicationController < ActionController::Base
  protect_from_forgery

	# Add this before filter to force CAS Authentication on all controllers + actions
	# before_filter :dummy_user #if Rails.env.development?
	before_filter :force_auth
	before_filter :find_user
	before_filter :force_user
	
	def logged_in?
		!!@current_user
	end
	
	# And their protected methods
	protected

	def dummy_user
		dummy_netid = 'cmi1'
		session[:cas_user] = dummy_netid
		@current_user = Person.where(:netid => dummy_netid).first
	end
	
	# force auth is always run after check_user, so we might have been successful
	def force_auth
		logger.debug "  Callback: force_auth"
		session[:last_ts] = nil
		CASClient::Frameworks::Rails::Filter.filter self unless @current_user
	end
	
	def find_user
		logger.debug "  Callback: find_user"
		# first visit, or stale visit, try to gateway auth
		if !session[:last_ts] && !@current_user
				CASClient::Frameworks::Rails::GatewayFilter.filter self
		end
		
		session[:last_ts] = Time.now
		
		if session[:cas_user]
			# User is CAS Authed, try to make an account for them
			# Check if we actually created an account, and if so, redirect them to profile flow
			@current_user = Person.where(:netid => session[:cas_user]).first
		end
		
	end

	def force_user
		logger.debug "  Callback: force_user"
		if session[:cas_user] && !@current_user
			# This is their first visit, trigger the new user flow
			session[:user_flow_entry] ||= request.url
			redirect_to new_person_path
		end
	end

  def render_404
    render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found
  end

end
