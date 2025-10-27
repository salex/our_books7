class Conversion

  def hello
    return "Hello World"
  end

  def statements_to_json
    statements = BankStatement.where(BankStatement.arel_table[:statement_date].gt('2020-12-31'.to_date)).as_json(except:[:created_at,:updated_at,:summary,:bank,:transactions])
    # j = statements.to_json
    # j = j.gsub("},{","},\n{")
    res = File.write(Rails.root+"zdumps/vfw_statements.json",statements.to_json)
    puts "IT DID SO<ETHONG #{res} size #{statements.size}"
    json = JSON.parse(File.read(Rails.root+"zdumps/vfw_statements.json"))
  end

  def account_to_json
    accts = Account.all.order(:id).as_json(except:[:created_at,:updated_at,:transfer,:leafs])
    
    File.write(Rails.root+"zdumps/json/vfw_accounts.json",accts.to_json)
  end

  def entries_to_json
    entries = Entry.all.order(:id).as_json(except: [:amount,:reconciled])
    File.write('/Users/salex/work/rails8/mybooks/app/objects/conversions/json/set_entries.json',entries.to_json)

    # entries = Entry.all.order(:id).as_json(except:[:amount,:reconciled, :created_at,:updated_at,:lock_version])

    # File.write(Rails.root+"zdumps/json/vfw_entries.json",entries.to_json)
  end

  def splits_to_json
    splits = Split.all.order(:id).as_json(except: [:debit,:credit,:transfer])
    File.write('/Users/salex/work/rails8/mybooks/app/objects/conversions/json/set_splits.json',splits.to_json)

    # splits = Split.all.order(:id).as_json(except:[:created_at,:updated_at,:debit,:credit,:transfer,:lock_version])
    
    # File.write(Rails.root+"zdumps/json/vfw_splits.json",splits.to_json)
  end

  def audits_to_json
    audits = Stash.all.order(:id).as_json(only: [:date,:yaml])
    File.write('/Users/salex/work/rails8/mybooks/app/objects/conversions/json/set_audits.json',audits.to_json)
  end

end