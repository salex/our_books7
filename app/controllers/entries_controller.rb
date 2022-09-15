class EntriesController < ApplicationController
  before_action :set_entry, only: [:show, :edit, :update, :destroy, :duplicate]
  before_action :require_book
  # GET /entries
  # GET /entries.json
  def index
    redirect_to accounts_path, notice:'Entries can only be accsessed through Accounts'
  end

  # GET /entries/1
  # GET /entries/1.json
  def show
  end

  # GET /entries/new
  def new
    # authorize Entry, :trustee?
    if params[:account_id].present?
      account = Account.find(params[:account_id])
    else 
      account = Account.new
      ououoiuo = redirect to somewhere
    end
    @entry = Current.book.entries.new(post_date:Date.today)
    # puts "ENTRY #{@entry.inspect}"
    # puts "ACCOUNT #{account.id}"

    session[:current_acct] = account.id
    1.upto(3) do |i|
      aid = i == 1 ? account.id : nil
      splits = @entry.splits.build(reconcile_state:'n',account_id: aid, amount:0, debit:0)
    end

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @list }
    end
  end

  # GET /entries/1/edit
  def edit
    2.times{@entry.splits.build(reconcile_state:'n')}

  end

  # POST /entries
  # POST /entries.json
  def create
    @entry = Current.book.entries.new(entry_params)
    # authorize Entry, :trustee?
    @bank_dup = @entry.fit_id.present?
    # fit should be nil unless it was created from a bank transaction
    respond_to do |format|

      if @entry.valid_params?(entry_params) && @entry.save
        if @bank_dup
          @entry.bank_transaction
        end
        format.html { redirect_to redirect_path, notice: 'Entry was successfully created.' }
        format.json { render :show, status: :created, location: @entry }
      else
        format.html { render :new }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end  # PATCH/PUT /entries/1
  # PATCH/PUT /entries/1.json
  def update
    respond_to do |format|
      puts entry_params
      if @entry.valid_params?(entry_params) && @entry.update(entry_params)
        format.html { redirect_to redirect_path, notice: 'Entry was successfully updated.' }
        format.json { render :show, status: :ok, location: @entry }
      else
        format.html { render :edit }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
    rescue ActiveRecord::StaleObjectError
      respond_to do |format|
        format.html {
          flash[:alert] = "This project has been updated while you were editing. Please refresh to see the latest version."
          render :edit
        }
        format.json { render json: { error: "Stale object." } }
      end
    
  end

  # DELETE /entries/1
  # DELETE /entries/1.json
  def destroy
    @entry.destroy
    respond_to do |format|
      format.html { redirect_to redirect_path, notice: 'Entry was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def link
    puts "got her #{params.inspect}"
    # authorize Entry, :trustee?
    entry = current_book.entries.find_by(id:params[:id])
    if entry.blank?
      redirect_to latest_ofxes_path, alert:  "ERROR Entry to link to was not found!."
      #this should not happen, but just in case
    elsif entry.fit_id.present?
      redirect_to latest_ofxes_path, alert:  "The Entry has already been linked!."
    else
      entry.link_ofx_transaction(params[:fit_id])
      # head :ok
      redirect_to latest_ofxes_path, notice: "Entry Linked to OFX fit_id"
    end

  end

  def new_bt
    # authorize Entry, :trustee?
    # account = current_book.accounts.new
    # @options  = current_book.settings[:acct_sel_opt]
    @entry = current_book.entries.new(post_date:params[:date],
      fit_id:params[:id], numb:params[:check_number],
      description:params[:memo])
    amt = (params[:amount].to_i).abs
    1.upto(2) do |i|
      if i == 1
        aid = nil
        if params[:type_tran] == 'debit'
          cr = amt
          db = ''
        else
          db = amt
          cr = ''
        end
      else
        aid = nil
        if params[:type_tran] == 'debit'
          db = amt
          cr = ''
        else
          cr = amt
          db = ''
        end
      end
      splits = @entry.splits.build(reconcile_state:'c',
        account_id: aid,amount:params[:amount].to_i,debit:db,credit:cr)
    end
    @entry.splits.build(reconcile_state:'n') # add extra split
    render template:'entries/new'
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def redirect_path
      if @bank_dup.present?
        latest_ofxes_path
      elsif session[:current_acct].present?
        account_path(session[:current_acct])
      else
        account_path(@entry.splits.order(:id).first.account)
      end
    end

    def set_entry
      @entry = Current.book.entries.find_by(id:params[:id])
      # puts "WAS CALLED #{@entry.blank?} #{params[:id]}"
      redirect_to( accounts_path, alert:'Entry not found for Current Book') if @entry.blank?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def entry_params
      params.require(:entry).permit(:numb, :post_date, :description, :fit_id, :book_id,
        splits_attributes: [:id,:action,:memo,:amount,:reconcile_state,:account_id,:debit,:credit,:_destroy])
    end
end
