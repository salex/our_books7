class BooksController < ApplicationController
  before_action :require_user
  before_action :set_book, only: %i[ show edit update destroy  open]

  # GET /books
  def index
    # @books = Current.client.books.all.order(:id)
    @books = Book.all.order(:id)

  end

  # GET /books/1
  def show
  end

  # GET /books/new
  def new
    @book = Book.new
  end

  # GET /books/1/edit
  def edit
  end

  # POST /books
  def create
    @book = Book.new(book_params)

    if @book.save
      redirect_to @book, notice: "Book was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /books/1
  def update
    if @book.update(book_params)
      redirect_to @book, notice: "Book was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /books/1
  def destroy
    @book.settings = {skip:true}.with_indifferent_access
    @book.destroy_book
    session.delete(:book_id)
    Current.book = nil
    redirect_to books_url, notice: "Book was successfully destroyed."
  end

  def open
    session[:book_id] = @book.id
    @book.settings = {}
    @book.save
    @book.get_settings
    checking_account = @book.checking_acct
    session[:recent]= {}
    if checking_account.present?
      leafs = checking_account.leaf.sort
      session[:recent][checking_account.id.to_s] = checking_account.name
      sub_accts = Account.find(leafs)
      sub_accts.each do |l|
        session[:recent][l.id.to_s] = l.name
      end
    end
    redirect_to home_index_path, notice: "Current Book set"
  end

 
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_book
      @book = Book.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def book_params
      params.require(:book).permit(:client_id, :name, :date_from, :date_to, :settings)
    end
end
