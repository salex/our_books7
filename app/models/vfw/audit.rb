module Vfw
  class Audit
    include ClientsHelper
    attr_accessor :audit_yaml, :config, :range, :summary, :assets

    def initialize(qtr_date=nil)
      if qtr_date.present?
        date = Ledger.set_date(qtr_date)
        bolq = date.beginning_of_quarter
      else
        bolq = Date.today.beginning_of_quarter - 3.months
      end
      eolq = bolq.end_of_quarter
      self.range = bolq..eolq      

    end

    def get_audit
      get_audit_config
      @audit_yaml = YAML.load(@audit_yaml)
      @config = to_struct(@audit_yaml)
      @summary = Current.book.current_assets.family_summary(@range.first,@range.last)
      @assets = get_assets(@summary)
      return self
    end

    def put_audit_config(audit_config,qtr_date)
      ac = Current.book.stashes.find_by(key:'audit_config',date:qtr_date)
      ac.yaml = audit_config
      ac.save
    end

    def get_audit_config
      ac = Current.book.stashes.find_by(key:'audit_config',date:self.range.first)
      if ac.blank?
        filepath = Rails.root.join("xml/yaml","audit_config.yaml")
        self.audit_yaml = File.read(filepath)
        new_ac = Current.book.stashes.new(book_id:Current.book.id,
          client_id:Current.book.client_id,
          date:self.range.first,
          key:'audit_config',
          yaml:self.audit_yaml)
        new_ac.save

      elsif ac.date != self.range.first 
        # same as last but with new date, start of quarter
        new_ac = ac.dup
        new_ac.date = self.range.first
        new_ac.save
        self.audit_yaml = new_ac.yaml
      else
        self.audit_yaml = ac.yaml
      end
    end

  end
end