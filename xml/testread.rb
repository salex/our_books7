filepath = Rails.root.join("xml","acctslf")
accts = File.read(filepath)
h = JSON.parse(accts)