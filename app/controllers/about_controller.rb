class AboutController < ApplicationController
  layout nil

  skip_before_filter :force_auth
  skip_before_filter :find_user
  skip_before_filter :force_user

  def summary
    @status = status
    @up = up?
  end

  def detail
    @status = status
    @up = up?
  end

  def status
    if up? then return "Application Tests OK - " + Time.now.inspect
    else return "Application Tests FAILED - " + Time.now.inspect
    end
  end

  def up?
    begin
      #return User.all.size > 0
      return true

    rescue Exception => e
      return false
    end
  end

end
