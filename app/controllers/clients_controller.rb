class ClientsController < ApplicationController
  before_action :require_super, except: %i[signin logout login]
  before_action :set_client, only: %i[ show edit update destroy ]

  # GET /clients
  def index
    @clients = Client.all
  end

  # GET /clients/1
  def show
  end

  # GET /clients/new
  def new
    @client = Client.new
  end

  # GET /clients/1/edit
  def edit
  end

  # POST /clients
  def create
    @client = Client.new(client_params)

    if @client.save
      redirect_to @client, notice: "Client was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /clients/1
  def update
    if @client.update(client_params)
      redirect_to @client, notice: "Client was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /clients/1
  def destroy
    @client.destroy
    redirect_to clients_url, notice: "Client was successfully destroyed."
  end

  def signin
    user = User.find_by(username:params[:email].downcase) || User.find_by(email:params[:email].downcase)
    if user && user.authenticate(params[:password])
      reset_session
      session[:user_id] = user.id
      session[:client_id] = user.client_id
      session[:full_name] = user.full_name

      session[:expires_at] = Time.now + 60.minutes
      if user.default_book.present?
        book = user.client.books.find_by(id:user.default_book)
        if book.present?
          helpers.set_book_session(book) 
          puts helpers.inspect_session
        end
      end
      redirect_to home_index_path, notice: "Logged in!"
    else
      redirect_to login_url, alert:"Email or password is invalid"
    end
  end

  def logout
    reset_session
    redirect_to root_url, notice: "Logged out!"
  end

  def visit
    super_id = session[:user_id]
    full_name = session[:full_name]
    reset_session
    session[:user_id] = super_id
    session[:full_name] = full_name
    session[:client_id] = params[:id]
    redirect_to root_path
  end

  def leave
    reset_session unless Current.user.is_super?
    redirect_to root_path
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client
      @client = Client.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def client_params
      params.require(:client).permit(:name, :acct, :address, :city, :state, :zip, :phone, :subdomain, :domain)
    end
end
