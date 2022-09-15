class BankStatement < ApplicationRecord
  belongs_to :client
  belongs_to :book
  acts_as_tenant(:client)

  serialize :summary, JSON
  attribute :bank


  # can't store ranges in json, just use string version and convert to range
  def tran_range
    from_to = summary['tran_range'].split("..")
    from_to = (from_to[0].to_date)..(from_to[1].to_date)
  end

  def fit_range
    from_to = summary['fit_range'].split("..")
    from_to = (from_to[0])..(from_to[1])
  end

  def reconcile
    self.bank = Bank.new(self.statement_date).reconcile(self)
  end


  #this is original import from rbooks, creating bt from ofx
  def self.import_transactions
    bsa = BankStatement.all 
    bsa.each do |bs| 
      next if bs.ofx_data.blank?
      acct = OFX(bs.ofx_data).account
      acct.transactions.each do |a|
        bt = BankTransaction.new(client_id:1,book_id:1)
        bt.post_date = a.posted_at.to_date
        bt.amount = a.amount_in_pennies
        bt.fit_id = a.fit_id
        bt.ck_numb = a.check_number
        bt.name = a.name
        bt.memo = a.memo

        e = Entry.find_by(fit_id: bt.fit_id)
        if e.present?
          bt.entry_id = e.id 
        end
        bt.save
      end

    end
    return nil
  end

end
