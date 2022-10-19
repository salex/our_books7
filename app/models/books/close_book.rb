module Books
  class CloseBook
    attr_accessor :book,:range, :old_to_new, :retained_earnings

    def initialize(book,from,to)
      @book = book
      @range = (from.to_date)..(to.to_date)
      ActsAsTenant.without_tenant do
        @next_book = Book.maximum(:id) + 1
        @next_acct = Account.maximum(:id) + 1
      end
      old_to_new_acct_ids
      income = book.income_acct.family_balance_on(to)
      expense = book.expenses_acct.family_balance_on(to)
      @retained_earnings = income - expense
      assets = book.assets_acct
      family_summary = assets.family_summary(from,to)
      @opening = {assets: family_summary[assets.id][:ending],sum:0,splits:[]}
      assets.leafs.each do |l|
        @opening[:splits] << {id:l,name:family_summary[l][:name],ending:family_summary[l][:ending]}
        @opening[:sum] += family_summary[l][:ending]
      end
    end

    def old_to_new_acct_ids
      @old_to_new = {}
      @book.acct_tree_ids.each do |id| 
        old_to_new[id] = id.to_i + @next_acct - 1
      end
    end

  end
end

