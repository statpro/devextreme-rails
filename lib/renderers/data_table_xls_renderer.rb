module Devextreme
  ActionController::Renderers.add :data_table_xls do |model, options|
    if options[:filename].present?
      filename = options[:filename]
    elsif model.is_a?(DataTable::Base)
      filename = model.base_query.first ? model.base_query.first.class.model_name.human(:count => 2) : self.controller_name.titleize
    else
      raise ArgumentError "Invalid model: #{model.class}"
    end

    send_data(
      model.to_xls(view_context, params, options),
      :type => :xls,
      :disposition => "attachment; filename=#{filename}.xls"
    )
  end

  class DataTableXlsGenerator

    def initialize(data_table, view_context, query, options = {})
      @data_table = data_table
      @view_context = view_context
      @query = query
      @options = options
      @summary = @options.delete(:summary)
    end

    def run
      append_xls
    end

    private

    def append_xls
      output = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<Workbook xmlns:x="urn:schemas-microsoft-com:office:excel"
          xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
          xmlns:html="http://www.w3.org/TR/REC-html40"
          xmlns="urn:schemas-microsoft-com:office:spreadsheet"
          xmlns:o="urn:schemas-microsoft-com:office:office">
  <Worksheet ss:Name="Sheet1">
    <Table>
      XML

      if @summary && @summary.count > 0
        @summary.each do |row|
          output << "<Row>"
          row.each do |column|
            output << "<Cell><Data ss:Type=\"String\">#{column}</Data></Cell>"
          end
          output << "</Row>"
        end
        output << "<Row></Row>"
      end

      if @query.any?

        unless @options.has_key?(:write_headers) && !@options[:write_headers]
          output << "<Row>"
          @data_table.each_header.each { |column|
            output << "<Cell><Data ss:Type=\"String\">#{column}</Data></Cell>"
          }
          output << "</Row>"
        end

        @query.each do |instance|
          output << "<Row>"
          @data_table.each_row(instance, @view_context).each do |value|
            if value.is_a?(Hash) && (value.has_key?(:href) || value.has_key?(:content))
              output << "<Cell><Data ss:Type=\"#{resolve_type(value)}\">#{value[:text]}</Data></Cell>"
            else
              output << "<Cell><Data ss:Type=\"#{resolve_type(value)}\">#{value}</Data></Cell>"
            end
          end
          output << "</Row>"
        end

      end

      output << "</Table></Worksheet></Workbook>"

    end

    # http://msdn.microsoft.com/en-us/library/aa140066%28v=office.10%29
    # sypported ss:Type are ->  Number, DateTime, Boolean, String, and Error
    def resolve_type(value)
      return 'Number' if value.is_a?(Float)
      return 'String'
    end

  end
end
