class ApplicationController < ActionController::Base
  set_current_tenant_through_filter  ### for acts_as-tenant
  include UsersHelper
  before_action :current_user
  before_action :session_expiry


  def require_user
    if Current.user.blank?
      deny_access
    end
  end
  helper_method :require_user


  def require_book
    if Current.user.blank?
      deny_access
    else
      redirect_to(books_path, alert:'Current Book is required') if Current.book.blank?
    end
  end
  helper_method :require_book

  def require_super
    if Current.user.blank? || !Current.user.is_super?
      redirect_to root_url, alert: "I'm sorry. I can't - or You can't do that."
    end
  end
  helper_method :require_super

  def require_admin
    if Current.user.blank? || !Current.user.is_admin?
      redirect_to root_url, alert: "I'm sorry. I can't - or You can't do that."
    end
  end
  helper_method :require_admin
  
  # TODO Not called, cancancan like call
  def require_trustee
    if Current.user.blank? || !Current.user.is_trustee?
      redirect_to root_url, alert: "I'm sorry. I can't - or You can't do that."
    end
  end
  helper_method :require_trustee

  def current_user
    @current_user ||= User.find_by(id:session[:user_id]) if session[:user_id]
    Current.user = @current_user
    if Current.user
      if session[:client_id].present?
        Current.client = Client.find(session[:client_id])
      else
        Current.client = Current.user.client
      end
      set_current_tenant(Current.client)### for acts_as-tenant
      current_book
    end
  end
  helper_method :current_user

  def current_book
    if session[:book_id].present?
      Current.book = Current.client.books.find_by(id:session['book_id'])
    end
  end

  def latest_ofxes_path
    if session[:latest_ofx_path].present?
      bank_statement_path(session[:latest_ofx_path])
    else
      bs = Current.book.bank_statements.last 
      bank_statement_path(bs.id)
    end
  end

  def cant_do_that(msg=nil)
    redirect_to root_url, alert: "I'm sorry. I can't - or You can't do that. #{msg}"
  end
  helper_method :cant_do_that

  def session_expiry
    if current_user.present? && session[:expires_at].present?
      get_session_time_left
      unless @session_time_left > 0
        if @current_user.present?
          # sign_out and redirect for new login
          sign_out
          deny_access 'Your session has timed out. Please log back in.'
        else
          # just kill session and start a new one
          sign_out
        end
      else
        session[:expires_at] = Time.now + 60.minutes
      end
    else
      # expire all sessions, even if not user to midnight
      session[:expires_at] = Time.now + 5.minutes
    end

  end
  
  def get_session_time_left
    expire_time = Time.parse(session[:expires_at]) || Time.now
    @session_time_left = (expire_time - Time.now).to_i
    # @expires_at = expire_time.strftime("%I:%M:%S%p")
  end




end
