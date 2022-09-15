class BankTransactionsController < ApplicationController
  before_action :require_book
  before_action :set_bank_transaction, only: %i[ show edit update destroy ]

  # GET /bank_transactions
  # def index
  #   @bank_transactions = BankTransaction.all
  # end

  # GET /bank_transactions/1
  def show
  end

  # GET /bank_transactions/new
  def new
    @bank_transaction = BankTransaction.new
  end

  # GET /bank_transactions/1/edit
  def edit
  end

  # POST /bank_transactions
  def create
    @bank_transaction = BankTransaction.new(bank_transaction_params)

    if @bank_transaction.save
      redirect_to @bank_transaction, notice: "Bank transaction was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /bank_transactions/1
  def update
    if @bank_transaction.update(bank_transaction_params)
      redirect_to @bank_transaction, notice: "Bank transaction was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /bank_transactions/1
  def destroy
    @bank_transaction.destroy
    redirect_to bank_transactions_url, notice: "Bank transaction was successfully destroyed."
  end

  def upload_ofx
    session[:latest_ofx_path] = params[:bs_id] # only set if called from deposit
  end

  def update_ofx
    @uploaded_io = params['ofx']
    @ofx_data = @uploaded_io.read
    @acct = OFX(@ofx_data).account
    render :ofx_data, data:{turbo:false}
  end

  def import_ofx
    @bank_statement = Current.book.bank_statements.find_by(id:session[:latest_ofx_path])
    ofx_data = params["ofx"]
    BankTransaction.import_transactions(ofx_data,@bank_statement)
    redirect_to root_path, notice: "Bank Transctions imported"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bank_transaction
      @bank_transaction = Current.book.bank_transactions.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def bank_transaction_params
      params.require(:bank_transaction).permit(:book_id, :client_id, :entry_id, :post_date, :amount, :fit_id, :ck_numb, :name, :memo)
    end
end
