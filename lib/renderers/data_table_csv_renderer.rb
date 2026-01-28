require 'csv'
module Devextreme
  ActionController::Renderers.add :data_table_csv do |model, options|
    extension   = options[:extension] || 'csv'
    mime_type   = options[:mime_type] || Mime[:csv]
    if options[:filename].present?
      filename = options[:filename]
    elsif model.is_a?(DataTable::Base)
      filename = model.download_file_name(self)
    else
      raise ArgumentError "Invalid model: #{model.class}"
    end

    options[:columns_layout] = UserGridLayout.get_user_grid_layout(current_user, self.controller_name, self.action_name, model.class.name, model.additional_layout_key)

    new_params = params.merge(
      'filterOptions' => options.dig(:columns_layout, 'filterOptions'),
      'sortOptions'   => options.dig(:columns_layout, 'sortOptions')
    )

    send_data(
      model.to_csv(view_context, new_params, options),
      :type        => mime_type,
      :disposition => "attachment; filename=#{filename}.#{extension}"
    )
  end

  class DataTableCsvGenerator
    def initialize(data_table, view_context, query, options = {})
      @data_table = data_table
      @view_context = view_context
      @query = query
      @options = options
      @summary = @options.delete(:summary)
    end

    def run
      generate_csv
    end

    private

    def generate_csv
      csv_rows = []

      if @summary && @summary.count > 0
        @summary.each do |row|
          csv_rows << row
        end
        csv_rows << []
      end

      columns = @options.fetch(:columns_layout, {}).fetch('columns', [])

      if columns.present?
        @data_table.columns.each do |column|
          # column.name can be an array (related column), so we need to join it with '.'
          column_name = "#{@data_table.base_query.table_name}.#{column.name.is_a?(Array) ? column.name.join('.') : column.name.to_s}"
          user_column = columns.detect { |c| c['dataField'] == column_name } || { 'visible' => false }
          column.options.reverse_merge!(:user_visible => user_column['visible'], :user_visible_index => user_column['visibleIndex'])
        end
      end

      if @options.fetch(:write_headers, :true)
        headers = @data_table.each_header
        csv_rows << headers
      end

      @query.each do |instance|
        row = []
        @data_table.each_csv_row(instance, @view_context).each do |value|
          if value.is_a?(Hash) && (value.has_key?(:href) || value.has_key?(:content))
            row << value[:text]
          else
            row << value
          end
        end
        csv_rows << row
      end

      csv_string = CSV.generate(:headers => false, :quote_char => '', :encoding => Encoding.find("UTF-8")) do |csv|
        csv_rows.each do |row|
          csv << row
        end
      end

      csv_string
    end
  end
end
