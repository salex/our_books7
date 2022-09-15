class BankTransaction < ApplicationRecord
  belongs_to :book
  # belongs_to :client
  belongs_to :entry, optional: true
  acts_as_tenant(:book)
  acts_as_tenant(:client)

  # attribute :ofx
  # attribute :accts
  def self.import_transactions(ofx_data,bs)
    puts "IT GOT TO IMPORT "
    acct = OFX(ofx_data).account
    acct.transactions.each do |t|
      unless Current.book.bank_transactions.find_by(fit_id:t.fit_id).present?
        bt = Current.book.bank_transactions.new(
          post_date:t.posted_at.to_date,
          amount:t.amount_in_pennies,
          memo:t.memo,
          name:t.name,
          ck_numb:t.check_number,
          fit_id:t.fit_id
          )
        bt.save
      end
      balance = acct.balance.amount_in_pennies
      bs.update(ending_balance:balance,ofx_data:ofx_data) if bs.present?
      # puts "PFX BALAmce #{balance}"
    end

  end

  def set_unlinked_options
    options = {ck_numb:[],amt:[]}
    if self.ck_numb.present?
      options[:ck_numb]= self.book.entries.where(numb: self.ck_numb)
    end
    if options[:ck_numb].blank?
      dt = (self.post_date - 30.days)
      options[:amt] = Bank.get_unlinked_checking_entries_by_amount(self)
      # options[:amt] = Bank.get_bt_unlinked_entries(self)

    end
    # puts options.inspect
    options 
  end 
end
