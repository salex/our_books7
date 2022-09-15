module ClientsHelper
  def to_struct(ahash)
    struct = ahash.to_struct
    struct.members.each do |m|
      struct[m] = to_struct(struct[m]) if struct[m].is_a? Hash
    end
    struct 
  end

  def get_assets(summary)
    pcash = checking = savings = total = nil
    summary.each do |k,v|
      pcash = v if v[:name] == 'Cash'
      checking =  v if v[:name] == 'Checking'
      savings =  v if v[:name] == 'Savings'
      total = v if v[:name] == 'Current'
    end
    bsave = savings[:ending]
    bcash = pcash[:ending]
    btotal = total[:ending]
    bcheck = checking[:ending]

    funds = checking[:children].count

    ojb = to_struct({pcash:pcash,
      checking:checking,
      savings:savings,
      total:total,
      bsave:bsave,
      bcash:bcash,
      btotal:btotal,
      bcheck:bcheck,
      funds:funds})
  end


end
