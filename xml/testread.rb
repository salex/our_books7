filepath = Rails.root.join("xml","acctslf")
accts = File.read(filepath)
h = JSON.parse(accts)
#  ^\.[^{]+
filepath = Rails.root.join("app/assets/stylesheets","ported.css")
accts = File.read(filepath)
