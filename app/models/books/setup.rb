module Books
  class Setup < Book
    # require 'csv'
    # csv no longer used, moved to json. Accounts will be pure json
    def self.create_book_tree(accounts,kind="unknown")
      ActsAsTenant.without_tenant do
        @next_book = Book.maximum(:id) + 1
        @next_acct = Account.maximum(:id) + 1
      end
      new_book = Current.client.books.new(name:"#{kind} #{Date.today}")
      new_book.id = @next_book
      new_book.settings = {'skip':true,'tree':true} #not sure if still valid - skipped load
      new_book.save  if new_book.valid?# got book with only id and name
      accounts.each do |acct|
        new_acct = Account.new(acct)
        new_acct.id = new_acct.id + @next_acct 
        new_acct.parent_id = new_acct.parent_id + @next_acct unless new_acct.account_type == 'ROOT'
        new_acct.book_id = new_book.id
        new_acct.client_id = Current.client.id
        ok = new_acct.save if new_acct.valid?
      end
      # reset all id to last of for model dependant on book
      ActiveRecord::Base.connection.reset_pk_sequence!('books')
      ActiveRecord::Base.connection.reset_pk_sequence!('accounts')
      ActiveRecord::Base.connection.reset_pk_sequence!('bank_statements')
      ActiveRecord::Base.connection.reset_pk_sequence!('bank_transactions')
      new_book.settings = {}
      new_book.save
      new_book.rebuild_settings
    end
  end
end

    # def self.clone_book_tree
    #   next_book = Book.maximum(:id) + 1
    #   next_acct = Account.maximum(:id)
    #   accts = Account.find(Current.book.settings["tree_ids"])
    #   accounts = []
    #   accts.each do |a|
    #     accounts << {
    #       account_type:a.account_type,
    #       name:a.name,
    #       description:a.description,
    #       placeholder:a.placeholder,
    #       id:a.id+next_acct,
    #       level:a.level,
    #       parent_id: (a.parent_id.nil? ? nil : a.parent_id + next_acct)
    #     }
    #   end
    #   accounts
    # end

    # def create_cloned_tree
    #   @accounts = Books::Setup.clone_book_tree
    #   @accounts.each do |acct|
    #     new_acct = self.accounts.new(acct)
    #      new_acct.save
    #   end
    #   # fix_uuids
    #   self.settings = nil
    #   self.get_settings
    #   ActiveRecord::Base.connection.reset_pk_sequence!('accounts')
    #   return true

    # end


 

    # def fix_uuids
    #   book = self
    #   root = book.accounts.find_by(account_type:"ROOT",parent_id:nil)
    #   book.root = root.uuid
    #   children = root.children
    #   children.each do |acct|
    #     case acct['account_type']
    #     when 'ASSET'
    #       book.assets = acct.uuid
    #     when 'INCOME'
    #       book.income = acct['uuid']
    #     when 'LIABILITY'
    #       book.liabilities = acct['uuid']
    #     when 'EXPENSE'
    #       book.expenses = acct['uuid']
    #     when 'EQUITY'
    #       book.equity = acct['uuid']
    #     else
    #       raise "A root child account has invalid account_type"
    #     end
    #   end
    #   this_checking = self.accounts.where(account_type:"BANK").where(Account.arel_table[:name].matches("checking%"))
    #   if this_checking.count == 1
    #     book.checking = this_checking.first.uuid
    #   end
    #   this_savings = self.accounts.where(account_type:"BANK").where(Account.arel_table[:name].matches("savings%"))
    #   if this_savings.count == 1
    #     book.savings = this_savings.first.uuid
    #   end
    #   if  book.changed?
    #     book.save
    #   end

    #   self.fix_placeholders
    # end

    # def fix_placeholders
    #   self.accounts.each do |a|
    #     if a.has_children? && !a.placeholder
    #       a.placeholder = true
    #       a.save 
    #     end
    #   end
    #   # self.get_settings
    # end

    # def self.parse_csv(csv_file)
    #   acct_path = Rails.root.join("xml/csv/#{csv_file}")
    #   next_book =  1 #Book.maximum(:id).nil? ? 1 : Book.maximum(:id) + 1
    #   next_account = 1 #Account.maximum(:id).nil? ? 1 : Account.maximum(:id) + 1
    #   accts = CSV.parse(File.read(acct_path))
    #   keys = accts.delete_at(0)
    #   type = 0
    #   full_name = 1
    #   name_desc = 2
    #   placeholder = 11
    #   id = next_account
    #   book_id = next_book
    #   last_level = 0
    #   this_type = ''
    #   parent_id = next_account
    #   parent_ids = [nil,next_account]
    #   accounts = [{account_type:'ROOT',name:'Root Account',description:'Root Account',level:0, parent_id:nil,id:id,placeholder:true}]
    #   accts.each_with_index do |a,idx|
    #     this_level = a[full_name].split(':').count
    #     this_id = idx + 1 + id
    #     if this_level == 1
    #       # we have a root child
    #       this_type = a[type]
    #       this_parent_id = next_account
    #       parent_ids[this_level] = this_id
    #       accounts << {account_type:this_type,name:a[name_desc],description:a[full_name],level:1, parent_id:this_parent_id,id:this_id,placeholder:true}

    #     elsif this_level == last_level
    #       # we have a sibling of the last acct that could be a parent
    #       this_type = a[type]
    #       this_parent_id = parent_ids[this_level -1]
    #       parent_ids[this_level] = this_id
    #       accounts << {account_type:this_type,name:a[name_desc],description:a[full_name],level:this_level, parent_id:this_parent_id,id:this_id,placeholder:false}

    #     elsif this_level > last_level
    #       # we have a new branch with level > 1
    #       this_type = a[type]
    #       this_parent_id = parent_ids[last_level]
    #       parent_ids[this_level] = this_id
    #       accounts << {account_type:this_type,name:a[name_desc],description:a[full_name],level:this_level, parent_id:this_parent_id,id:this_id,placeholder:false}

    #     elsif this_level < last_level
    #       # we have a new branch with level > 1
    #       this_type = a[type]
    #       this_parent_id = parent_ids[this_level -1]
    #       parent_ids[this_level] = this_id
    #       accounts << {account_type:this_type,name:a[name_desc],description:a[full_name],level:this_level, parent_id:this_parent_id,id:this_id,placeholder:false}

    #     end
    #     last_level = this_level
    #   end
    #   # accounts
    #   trees = {next_account => []}
    #   accounts.each do |a|
    #     if trees.has_key?(a[:parent_id])
    #       trees[a[:parent_id]] << a[:id]
    #     else
    #       trees[a[:parent_id]] = [a[:id]]
    #     end
    #   end
    #   trees.delete(nil)
    #   return [accounts,trees]
    

