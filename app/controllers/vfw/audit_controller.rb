module Vfw
  class AuditController < ApplicationController
    before_action :require_book

    def index
      @audits = Current.book.stashes.where(key:'audit_config').order(:date).reverse
    end

    def edit
      @report = Audit.new(params[:qtr_date])
      @report.get_audit_config
      @vfwcashconfig = @report.audit_yaml
    end

    def update_config
      yaml = params[:yaml].gsub(/\r\n?/, "\n")
      respond_to do |format|
        if  Audit.new.put_audit_config(yaml,params[:qtr_date])
          format.html { redirect_to vfw_audit_index_path, notice: 'Truestee Audit Confiuration saved' }
        else
          format.html { render :edit_config }
        end
      end
    end


    def print
      @audit = Vfw::Audit.new(params[:qtr_date]).get_audit
      render template: 'vfw/audit/print'
    end

    def pdf
      ta_pdf = TrusteeAudit.new(params[:qtr_date])
      send_data ta_pdf.render, filename: "trustee_audit",
        type: "application/pdf",
        disposition: "inline"
    end


    private

    # def get_audit
    #   filepath = Rails.root.join("xml/yaml","audit_config.yaml")
    #   if params[:date].present?
    #     date = Ledger.set_date(params[:date])
    #     bolq = date.beginning_of_quarter
    #   else
    #     bolq = Date.today.beginning_of_quarter - 3.months
    #   end
    #   eolq = bolq.end_of_quarter
    #   @range = bolq..eolq
    #   @config = helpers.to_struct(YAML.load_file(filepath))
    #   # puts @config.inspect
    #   # @config = Audit.new.get_audit_config.to_o
    #   @summary = Current.book.current_assets.family_summary(@range.first,@range.last)
    #   @assets = helpers.assets(@summary)
    #   # puts @assets.inspect
    # end

  end
end