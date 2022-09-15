class Books::SetupController < BooksController
  before_action :require_admin

  def index
    render 'setup/index'
  end

  def preview

    if params[:setup_id] == 'clone'
      jfile = Current.book.clone_accts_to_json
    else
      file_name = params[:setup_id]+'.json'
      jfile = File.read(Rails.root.join("xml/json/#{file_name}"))
    end
    @accounts = []
    accounts = JSON.parse(jfile)

    accounts.each do |acct|
      # symbolize_keys since most access is by symbol
      acct = acct.symbolize_keys
      @accounts << acct unless acct[:level].blank?
      if acct[:account_type] == 'ROOT'
        acct[:code] = acct[:account_type]
      end
      # set root's children. these are unique
      if acct[:level] == 1
        acct[:code] = acct[:account_type]
      end
      # set specal accounts
      if acct[:name].include?('Checking')
        acct[:code] = 'CHECKING'
      end
      if acct[:name].include?('Saving')
        acct[:code] = 'SAVING'
      end
      if acct[:name].include?('Current') && acct[:account_type] == "ASSET"
        acct[:code] = 'CURRENT'
      end
    end
    render 'setup/show'
  end

  def create
    if params[:setup_id] == 'clone'
      jfile = Current.book.clone_accts_to_json
    else
      file_name = params[:setup_id]+'.json'
      jfile = File.read(Rails.root.join("xml/json/#{file_name}"))
    end
    @accounts = []
    accounts = JSON.parse(jfile)
    @accounts = []
    accounts = JSON.parse(jfile)

    accounts.each do |acct|
      # symbolize_keys since most access is by symbol
      acct = acct.symbolize_keys
      @accounts << acct unless acct[:level].blank?
      if acct[:account_type] == 'ROOT'
        acct[:code] = acct[:account_type]
      end
      # set root's children. these are unique
      if acct[:level] == 1
        acct[:code] = acct[:account_type]
      end
      # set specal accounts
      if acct[:name].include?('Checking')
        acct[:code] = 'CHECKING'
      end
      if acct[:name].include?('Saving')
        acct[:code] = 'SAVING'
      end
      if acct[:name].include?('Current') && acct[:account_type] == "ASSET"
        acct[:code] = 'CURRENT'
      end
    end
    # this is going to call the create action in Book, not setup
    book = Books::Setup.create_book_tree(@accounts,params[:setup_id])
    redirect_to books_path, notice:'New Book and Accounts created'

  end

  private
    

end