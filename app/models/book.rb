class Book < ApplicationRecord
  # belongs_to :client
  acts_as_tenant(:client) ### for acts_as-tenant

  has_many :accounts, dependent: :destroy
  has_many :entries, dependent: :destroy
  has_many :bank_statements, dependent: :destroy
  has_many :bank_transactions, dependent: :destroy
  has_many :stashes, dependent: :destroy


  serialize :settings, JSON
  
  attribute :acct_transfers
  attribute :acct_placeholders
  attribute :checking_ids

  after_initialize :set_attributes
  
  #helpers to set or get attributes/settings
  def acct_tree_ids
    unless self.settings.blank?
      self.acct_transfers.keys 
    end
  end

  # def acct_transfer(id)
  #   unless self.settings.blank?
  #     self.acct_transfers(id.to_s)
  #   end
  # end

  def acct_sel_opt
    unless self.settings.blank?
      self.acct_transfers.map{|k,v| [v,k]}.prepend(['',0])
    end
  end



  def acct_sel_opt_rev
    unless self.settings.blank?
      self.acct_sel_opt.select{|i| i  unless self.acct_placeholders.include?(i[1])}.
        map{|i|[ i[0].
        split(':').reverse.join(':'),i[1]]}.
        sort_by { |word| word[0].downcase }
    end
  end

  def set_attributes
    unless self.settings.blank?
      self.acct_transfers = settings['transfers']
      self.acct_placeholders = settings['acct_placeholders']
      self.checking_ids = settings['checking_ids']
    end
  end

  def build_tree
    new_tree = []
    troot = self.root_acct
    troot.walk_tree(0,new_tree)
    new_tree.each do |a| 
      if a.level_changed?
        a.save
      end
    end
    new_tree
  end

  def destroy_book
    # for some reason dependent destroy would fail, out of order of
    # somthing, this does it in order that works
    self.entries.destroy_all
    self.bank_statements.destroy_all
    self.bank_transactions.destroy_all
    self.accounts.destroy_all
    self.destroy
  end

  # the follow xxxx_acct metheds expects a unique all uppercase name stored in :code
  # to identify the root accounts children. it also requires the parent to be
  # the to root account.
  # its up to the user to identify checking, saving and current
  def root_acct
    self.accounts.find_by(code:'ROOT',level:0)
  end

  def checking_acct
    # can be a single account or a placeholder
    self.accounts.find_by(code:'CHECKING')
  end

  def assets_acct
    self.accounts.find_by(code:'ASSET',parent_id:self.root_acct)
  end

  def liabilities_acct
    self.accounts.find_by(code:'LIABILITY',parent_id:self.root_acct)
  end

  def equity_acct
    self.accounts.find_by(code:'EQUITY',parent_id:self.root_acct)
  end

  def income_acct
    self.accounts.find_by(code:'INCOME',parent_id:self.root_acct)
  end

  def expenses_acct
    self.accounts.find_by(code:'EXPENSE',parent_id:self.root_acct)
  end

  def savings_acct
    self.accounts.find_by(code:'SAVING')
  end

  def current_assets
    self.accounts.find_by(code:'CURRENT')
  end


  def get_settings
    return {} if self.settings['skip'].present? || self.settings['tree'].present?
    reset = (Rails.application.config.x.acct_updated > self.updated_at.to_s || self.settings.blank?)
    if reset
      rebuild_settings
    end
    return self.settings
  end

  def rebuild_settings
    checking = self.checking_acct
    new_settings = {}
    # puts "CHECK ACCOUT IS #{checking}"
    accts = build_tree
    id_trans = accts.pluck(:id,:transfer)
    if checking.present?
      leafs = checking.leaf.sort
      # puts "ARE THE LEAFS SET #{leafs}"
      if leafs.blank?
        new_settings['checking_ids'] = [checking.id]
      else
        new_settings['checking_ids'] = leafs
      end
    end
    new_settings['transfers'] = id_trans.to_h
    new_settings['acct_placeholders'] = accts.select{|a| a.placeholder}.pluck(:id)
    self.settings = new_settings
    self.touch
    self.save!
  end

  

  def last_numbers(ago=6)
    from = Date.today.beginning_of_month - ago.months
    nums = self.entries.where(Entry.arel_table[:post_date].gteq(from)).pluck(:numb).uniq.sort.reverse
    obj = {numb: 0} # for numb only
    nums.each do |n|
      if n.blank? 
        next # not blank or nil
      end
      key = n.gsub(/\d+/,'')
      val = n.gsub(/\D+/,'')
      next if key+val != n # only deal with key/numb not numb/key
      is_blk  = val == '' # key only
      num_only = val == n
      if !is_blk
        val = val.to_i
        is_num = true
      else
        is_num = false
      end
      if num_only
        obj[:numb] = val if ((val > obj[:numb]) && (val < 9000))
        next
      end
      key = key.to_sym 
      unless obj.has_key?(key)
        obj[key] = val 
        next
      end
      if is_num
        obj[key] = val if val > obj[key]
        next
      else
        obj[key] = val 
      end
    end
    obj
  end

  def auto_search(params)
    desc = params[:input]
    if params[:contains].present? && params[:contains] == 'true'
      entry_ids = self.entries.where(Entry.arel_table[:description].matches("%#{desc}%"))
      .order(Entry.arel_table[:id]).reverse_order.pluck(:description,:id)
    else
      entry_ids = self.entries.where(Entry.arel_table[:description].matches("#{desc}%"))
      .order(Entry.arel_table[:id]).reverse_order.pluck(:description,:id)
    end
    filter = entry_ids.uniq{|itm| itm.first}.to_h
  end

  def contains_any_word_query(words,all=nil)
    words = words.split unless words.class == Array
    words.map!{|v| "%#{v}%"}
    query = self.entries.where(Entry.arel_table[:description].matches_any(words)).includes(:splits).order(:post_date).reverse_order
    return query if all.present?
    p = query.pluck(:description,:id)
    uids = p.uniq{ |s| s.first }.to_h.values
    query.where(id:uids).order(:post_date).reverse_order
  end

  def contains_all_words_query(words,all=nil)
    words = words.split unless words.class == Array
    words.map!{|v| "%#{v}%"}
    query = self.entries.where(Entry.arel_table[:description].matches_all(words)).includes(:splits).order(:post_date).reverse_order
    return query if all.present?
    p = query.pluck(:description,:id)
    uids = p.uniq{ |s| s.first }.to_h.values
    query.where(id:uids).order(:post_date).reverse_order
  end

  def contains_match_query(match,all=nil)
    query = self.entries.where(Entry.arel_table[:description].matches("%#{match}%")).includes(:splits).order(:post_date).reverse_order
    return query if all.present? && all == "1"
    p = query.pluck(:description,:id)
    uids = p.uniq{ |s| s.first }.to_h.values
    query.where(id:uids).order(:post_date).reverse_order
  end

  def contains_number_query(match,all=nil)
    # query = self.entries.where('entries.numb like ?',"#{match}%").order(:post_date).reverse_order
    query = self.entries.where(Entry.arel_table[:numb].matches("#{match}%")).order(:numb).reverse_order
    # puts "query.count #{match}  #{query.count}"
    return query if all.present?
    p = query.pluck(:description,:id)
    uids = p.uniq{ |s| s.first }.to_h.values
    query.where(id:uids).order(:post_date).reverse_order
  end

  def contains_amount_query(match,all=nil)
    bacct_ids = self.acct_tree_ids #- self.acct_placeholders
    eids = Split.where(account_id:bacct_ids).where(amount:match.to_i).pluck(:entry_id).uniq
    # query = self.entries.where('entries.numb like ?',"#{match}%").order(:post_date).reverse_order
    query = self.entries.where(id:eids).order(:post_date).reverse_order
    # puts "query.count #{match}  #{query.count}"
    return query if all.present?
    p = query.pluck(:description,:id)
    uids = p.uniq{ |s| s.first }.to_h.values
    query.where(id:uids).order(:post_date).reverse_order
  end

  def clone_accts_to_json
    # create a json clone of this book accounts
    accts = self.accounts.find(self.acct_tree_ids)
    tree_ids = accts.pluck(:id)
    new_tree_ids = {}
    #  create a hash with old id pointing to new id (starting a 1)
    tree_ids.each_with_index{|id,i| new_tree_ids[id]=i+1}
    # do as_json to filter accounts
    jaccts = accts.as_json(except:[:book_id, :contra,:client_id,:created_at,:updated_at,:code,:transfer,:leafs])
    jaccts.each do |ja|
      ja['id'] = new_tree_ids[ja['id']]
      ja['parent_id'] = new_tree_ids[ja['parent_id']] unless ja['parent_id'].nil?
    end
    jaccts.to_json
  end


end
