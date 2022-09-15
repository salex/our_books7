class Bank

  attr_accessor :checking_ids,
    :checking_account,
    :closing_date,
    :reconciled_balance,
    :cleared_entries,
    :cleared_balance,
    :uncleared_entries,
    :uncleared_balance,
    :closing_balance,
    :balance, 
    :statement_range, 
    :checking_ending_balance,
    :checking_beginning_balance,
    :bank_beginning_balance,
    :bank_ending_balance,
    :range_reconciled_balance,
    :reconcile_diff,
    :cleared_splits


  def initialize(closing_date=nil,closing_balance=nil)
    self.closing_date = Ledger.set_date(closing_date)
    if closing_balance.blank?
      self.closing_balance = 0
    else
      # self.closing_balance = closing_balance.to_s.gsub(/\D/,'').to_i
      self.closing_balance = Ledger.to_amount(closing_balance)
    end
    set_checking_ids
  end

  def checkbook_balance
    set_balances
    self.balance = self.reconciled_balance + self.cleared_balance + self.uncleared_balance
    return self
  end

  def reconcile(bank_statement)
    checkbook_balance
    self.statement_range = Ledger.statement_range(self.closing_date)
    self.checking_ending_balance = checking_account.family_balance_on(self.closing_date)
    self.checking_beginning_balance = checking_account.family_balance_on(statement_range.first)
    self.bank_beginning_balance = bank_statement.beginning_balance
    self.bank_ending_balance = bank_statement.ending_balance ||= 0
    set_range_reconciled_balance
    test_balance = checking_ending_balance  -  uncleared_balance - range_reconciled_balance
    self.reconcile_diff = test_balance - bank_ending_balance
    return self
  end

  # def all_uncleared_entries
  #   splits = Split.where(reconcile_state:'n',account_id:checking_ids).
  #   joins(:entry).
  #   order(Entry.arel_table[:post_date],Entry.arel_table[:numb])
  #   entries = split_entries(splits)
  # end

  # def all_recent_entries(from=Date.today)
  #   dt = (from - 45.days)..(from + 1.day)
  #   e = Current.book.entries.where(Entry.arel_table[:post_date].between(dt)).where(fit_id:[nil,''])
  #   eid = e.pluck(:id)
  #   # check on reconciled state will ignore old cleared tranasactions
  #   splits = Split.where(entry_id:eid,account_id:checking_ids,reconcile_state:'n')
  #   entry_ids = splits.pluck(:entry_id).uniq
  #   entries = Entry.find(entry_ids)
  #   entries.each do |e|
  #     e.amount = e.splits.where(account_id:Current.book.checking_ids).sum(:amount)
  #   end
  #   entries
  # end

  # def find_recent_entries_amount(amt,from=Date.today)
  #   all_recent_entries(from).select{|e| e.amount == amt}
  # end

  # def find_uncleared_entries_amount(amt)
  #   all_uncleared_entries.select{|e| e.amount == amt}
  # end

  def cleared_splits
    splits = Split.where(reconcile_state:'c',account_id:checking_ids).
    joins(:entry).where(Entry.arel_table[:post_date].lteq(closing_date)).
    order(Entry.arel_table[:post_date],Entry.arel_table[:numb])
    self.cleared_balance = splits.sum(:amount)
    self.cleared_splits = splits
  end

  def self.get_bt_unlinked_entries(bt)
    amt_opt = []
    btw = (bt.post_date - 25.days)..bt.post_date
    entries = Entry.where(fit_id:[nil,''],post_date:btw)
    entries.each do |e|
      # get checking_acct splits and sum the amount and stuff in entry
      # amount attribute. should not be called unless the entry
      # has checking_ids splits
      ca_splits = e.splits.where(account_id:Current.book.checking_ids)
      if ca_splits.present?
        chk_amt = ca_splits.sum(:amount)
        puts "ENT #{chk_amt} #{e.id} BT #{bt.amount}  #{bt.id}  #{chk_amt == bt.amount}"
        if chk_amt == bt.amount
          e.amount = chk_amt 
          amt_opt << e
        end
      end
    end
    amt_opt

  end

  def self.get_unlinked_checking_entries_by_amount(bt)
    return(Bank.get_bt_unlinked_entries(bt)) if bt.post_date < "2018-07-01".to_date
    amt_opt = []
    btw = (bt.post_date - 25.days)..bt.post_date

    splits = Split.where(account_id:Current.book.checking_ids, reconcile_state:'n')
    # get all splits in current book that match account, and amount
    # pluck uniq entry ids 
    entry_ids = splits.pluck(:entry_id).uniq
    # get unlinked entries that are unliked and have amount
    # if from.present?
    #   entries = Entry.where(id:entry_ids,fit_id:[nil,'']).where(Entry.arel_table[:post_date].gt(from.to_date))
    # else
    #   entries = Entry.where(id:entry_ids,fit_id:[nil,''])
    # end
    entries = Entry.where(id:entry_ids,fit_id:[nil,''],post_date:btw)

    entries.each do |e|
      # get checking_acct splits and sum the amount and stuff in entry
      # amount attribute. should not be called unless the entry
      # has checking_ids splits
      ca_splits = e.splits.where(account_id:Current.book.checking_ids)
      if ca_splits.present?
        chk_amt = ca_splits.sum(:amount)
        if chk_amt == bt.amount
          e.amount = chk_amt 
          amt_opt << e
        end
      end
    end
    amt_opt
  end

  def self.fix_old_check_number_links
    bt = Current.book.bank_transactions.where.not(ck_numb: '' ).
      where(BankTransaction.arel_table[:entry_id].eq(nil))
    bt.each do |t| 
      e = Current.book.entries.where(numb:t.ck_numb)
      if e.size == 1
        e[0].update(fit_id:t.fit_id)
        t.update(entry_id:e[0].id)
      else
        puts "MULTILE"
      end
    end
  end

  def self.fix_old_amount_links
    bt = Current.book.bank_transactions.where(BankTransaction.arel_table[:entry_id].eq(nil))
    bt.each do |t| 
      e = Bank.get_bt_unlinked_entries(t)
      # puts "HOW MANy MATCHES #{amt_opt.size}"
      if e.size == 1
        e[0].update(fit_id:t.fit_id)
        t.update(entry_id:e[0].id)
        # puts "WOULD LINK #{amt_opt[0].amount} with #{t.amount}"
      end
    end
  end

  private

  def set_checking_ids
    self.checking_account = Current.book.checking_acct
    self.checking_ids = Current.book.checking_ids
    # if checking account does not have childeren, it's just the account
    self.checking_ids = self.checking_account if self.checking_ids.blank?
  end

  def set_reconciled_balance
    self.reconciled_balance = Split.where(reconcile_state:'y',account_id:checking_ids).
    joins(:entry).where(Entry.arel_table[:post_date].lteq(closing_date)).sum(:amount)
  end

  def set_range_reconciled_balance
    self.range_reconciled_balance = Split.where(reconcile_state:'y',account_id:checking_ids).
    joins(:entry).where(Entry.arel_table[:post_date].between(statement_range)).sum(:amount)
  end

  def set_cleared_entries
    self.cleared_entries = split_entries(cleared_splits)
  end

  def set_uncleared_entries
    self.uncleared_entries = split_entries(uncleared_splits)
  end

 
  def uncleared_splits
    splits = Split.where(reconcile_state:'n',account_id:checking_ids).
    joins(:entry).where(Entry.arel_table[:post_date].lteq(closing_date)).
    order(Entry.arel_table[:post_date],Entry.arel_table[:numb])
    self.uncleared_balance = splits.sum(:amount)
    splits
  end

  def split_entries(splits)
    puts "GOto SP:initializet ENTRIES"
    entries = Entry.where(id:splits.pluck(:entry_id).uniq).order(:post_date,:numb)
    entries.each do |e|
      esplits = e.splits.where(account_id:checking_ids)
      rstate = esplits.pluck(:reconcile_state).uniq
      case rstate
      when %w{v}
        e.reconciled = 'v'
      when %w{y}
        e.reconciled = 'y'
      when %w{n}
        e.reconciled = 'n'
      when %w{c}
        e.reconciled = 'c'
      else
        e.reconciled = '?'
        # this is an error, have not seen it happen. any blank state should be set to 'n'
      end
      e.amount = esplits.sum(:amount)
    end
    entries
  end

  def set_balances
    set_reconciled_balance
    set_uncleared_entries
    set_cleared_entries
  end


end