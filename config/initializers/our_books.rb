ACCT_TYPES =  %w{ASSET BANK CASH CREDIT EQUITY EXPENSE INCOME LIABILITY PAYABLE RECEIVABLE ROOT}.freeze

ROOT_ACCOUNTS = %w{ROOT ASSET LIABILITY EQUITY INCOME EXPENSE}

OurBooks::Application.config.x.acct_updated = Time.now.utc.to_s

Hash.class_eval do
  def to_struct
    Struct.new(*keys.map(&:to_sym)).new(*values)
  end
end
