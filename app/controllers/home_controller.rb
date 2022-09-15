class HomeController < ApplicationController
  def index
    # puts "OPEN #{session[:book_id]}"
    
    if Current.user.blank?
      render "home/index"
    # elsif Current.book.blank?
    #   redirect_to books_path, notice:"Default book not set or found, select a Book"
    # elsif
    else
      render "home/client"
    end
      
  end

  def client
    if Current.book.blank?
      redirect_to books_path,notice:"Current Book is not set - select a book"
    end
  end

  def redirect
    # redirect_to '/404'
    cant_do_that(params[:path])
  end

end
