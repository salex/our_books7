module BankTransactionsHelper

  def get_summary(o)
    summary = {}
    summary[:balance_date] = o.balance.posted_at.to_date
    bal = o.balance.amount_in_pennies
    summary[:balance] = to_money(bal)
    summary[:available_balance] = to_money o.available_balance.amount_in_pennies
    from = o.transactions.last.posted_at.to_date
    to = o.transactions.first.posted_at.to_date
    fit_start = o.transactions.last.fit_id
    fit_end = o.transactions.first.fit_id
    diff = o.transactions.collect{|t| t.amount_in_pennies}.sum
    summary[:beginning_balance] =  to_money(bal - diff)
    summary[:diff] = to_money(diff)
    summary[:tran_range] = from..to
    summary[:fit_range] = fit_start..fit_end
    summary
  end

end
