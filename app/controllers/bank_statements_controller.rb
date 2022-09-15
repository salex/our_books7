class BankStatementsController < ApplicationController
  before_action :require_book
  before_action :set_bank_statement, only: %i[ show edit update destroy transactions reconcile update_reconcile ]

  # GET /bank_statements
  def index
    @bank_statements = Current.book.bank_statements.order(:statement_date).reverse
  end

  # GET /bank_statements/1
  def show
    session[:latest_ofx_path] = @bank_statement.id
    if @bank_statement.statement_date < "2018-07-31".to_date
      range = ("2018-01-01".to_date)..("2018-06-30".to_date)
    else
      range = Ledger.statement_range(@bank_statement.statement_date)
    end
    @transactions = Current.book.bank_transactions.where(post_date:range).order(:post_date).reverse
  end

  # GET /bank_statements/new
  def new
    last_statement = current_book.bank_statements.where.not(reconciled_date:nil).order(:reconciled_date).last
    bb = 0
    if last_statement.present?
      next_month = last_statement.statement_date.end_of_month + 1.day
      statement_range = Ledger.statement_range(next_month)
      bb = last_statement.ending_balance
    else
      statement_range = Ledger.statement_range(Date.today)
    end
    @bank_statement = current_book.bank_statements.new(statement_date:statement_range.last,beginning_balance:bb,ending_balance:0)
  end

  # POST /bank_statements
  # POST /bank_statements.json
  def create
    @bank_statement = current_book.bank_statements.new(bank_statement_params)

    respond_to do |format|
      if @bank_statement.save
        format.html { redirect_to @bank_statement, notice: 'Bank statement was successfully created.' }
        format.json { render :show, status: :created, location: @bank_statement }
      else
        format.html { render :new }
        format.json { render json: @bank_statement.errors, status: :unprocessable_entity }
      end
    end
  end


  # GET /bank_statements/1/edit
  def edit
  end

  # POST /bank_statements

  # PATCH/PUT /bank_statements/1
  def update
    if @bank_statement.update(bank_statement_params)
      redirect_to @bank_statement, notice: "Bank statement was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /bank_statements/1
  def destroy
    @bank_statement.destroy
    redirect_to bank_statements_url, notice: "Bank statement was successfully destroyed."
  end

  # def transactions
  #   # could also use fit range?
  #   range = Ledger.statement_range(@bank_statement.statement_date)
  #   @transactions = Current.book.bank_transactions.where(post_date:range)
  # end

  def unlinked
    # @transactions = Current.book.bank_transactions.where(entry_id:nil).where.not(ck_numb:[nil,''])
    @transactions = Current.book.bank_transactions.where(entry_id:nil)
    @unlinked = true
    render template: 'bank_statements/transactions'
  end

  def reconcile
    session[:reconcile_id] = @bank_statement.id
    @reconcile = @bank_statement.reconcile
  end

  def clear_splits
    @bank_statement = BankStatement.find(session[:reconcile_id])
    entry = Entry.find(params[:id])
    splits = entry.splits.where(reconcile_state:'n')
    splits.update_all(reconcile_state:'c')
    @reconcile = @bank_statement.reconcile
    # render partial: 'bank_statements/reconcile'
    render turbo_stream: turbo_stream.replace(
      'entries',
      partial: '/bank_statements/reconcile')

  end

  def unclear_splits
    @bank_statement = BankStatement.find(session[:reconcile_id])
    entry = Entry.find(params[:id])
    splits = entry.splits.where(reconcile_state:'c')
    splits.update_all(reconcile_state:'n')
    @reconcile = @bank_statement.reconcile
    # render partial: 'bank_statements/reconcile'
    render turbo_stream: turbo_stream.replace(
      'entries',
      partial: '/bank_statements/reconcile')
  end

  def update_reconcile
    # puts @bank_statement.nil?

    @bank_statement.reconcile

    @reconcile = @bank_statement.bank
    respond_to do |format|
      if @reconcile.cleared_splits.blank?
        format.html { redirect_to @bank_statement, notice: 'Bank statement was already reconciled.' }
      elsif @reconcile.reconcile_diff.zero?
        @reconcile.cleared_splits.update_all(reconcile_state:'y',reconcile_date:@bank_statement.statement_date + 1.day)
        @bank_statement.update(reconciled_date:@bank_statement.statement_date + 1.day)
        # update reconcile_state and reconcile_date
        session.delete(:reconcile_id)
        format.html { redirect_to @bank_statement, notice: 'Bank statement was successfully reconciled.' }
      else
        format.html { redirect_to @bank_statement, alert: "Bank statement was not reconciled. Difference = #{@reconcile[:difference]} "}
        format.json { render json: @bank_statement.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bank_statement
      @bank_statement = Current.book.bank_statements.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def bank_statement_params
      params.require(:bank_statement).permit(:client_id, :book_id, :statement_date, :beginning_balance, :ending_balance, :summary, :reconciled_date, :ofx_data)
    end
end
