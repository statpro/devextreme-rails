module Devextreme
  ActionController::Renderers.add :data_table_xls do |model, options|
    if options[:filename].present?
      filename = options[:filename]
    elsif model.is_a?(DataTable::Base)
      filename = model.base_query.first ? model.base_query.first.class.model_name.human(:count => 2) : self.controller_name.titleize
    else
      raise ArgumentError "Invalid model: #{model.class}"
    end

    # TODO:: We shouldn't have a dependancy on an external object in the gem.
    #        Possible solution is to add a requirement for the gem to have a UserGridLayout store(storage mechanism independent).
    options[:columns_layout] = UserGridLayout.get_user_grid_layout(current_user, self.controller_name, self.action_name, model.class.name, model.additional_layout_key)

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
      header_font_fill = @options.dig(:styles,:header,:font_fill) || '#ffffff'
      header_font_color = @options.dig(:styles,:header,:font_color) || '#000000'

      output = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<Workbook xmlns:x="urn:schemas-microsoft-com:office:excel"
          xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
          xmlns:html="http://www.w3.org/TR/REC-html40"
          xmlns="urn:schemas-microsoft-com:office:spreadsheet"
          xmlns:o="urn:schemas-microsoft-com:office:office"> 
        <Styles>
          <Style ss:ID="Default" ss:Name="Normal">
           <Alignment ss:Vertical="Bottom"/>
           <Borders/>
           <Font/>
           <Interior/>
           <NumberFormat/>
           <Protection/>
          </Style>
          <Style ss:ID="s1">
           <Borders>
            <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
            <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
            <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
            <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
           </Borders>
           <Font x:Family="Swiss" ss:Bold="1" ss:Color="#{header_font_color}"/>
           <Interior ss:Color="#{header_font_fill}" ss:Pattern="Solid"/>
          </Style>
         </Styles>
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
        columns = @options.fetch(:columns_layout, {}).fetch('columns', [])

        if columns.present?
          @data_table.columns.each do |column|
            user_column = columns.detect{|c| c['dataField'].split('.').last == column.name.to_s} || {'visible' => false}
            column.options.merge!(:user_visible => user_column['visible'], :user_visible_index => user_column['visibleIndex'])
          end
        end

        unless @options.has_key?(:write_headers) && !@options[:write_headers]
          output << "<Row>"
          @data_table.each_header.each { |column|
            output << "<Cell ss:StyleID=\"s1\"><Data ss:Type=\"String\">#{column}</Data></Cell>"
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
