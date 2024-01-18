module DataTableHelper
  # options
  #   grid function calls supported usage
  #   :selection_changed => 'someFunctionToCall'
  def render_data_table(data_table, options = {})
    raise ArgumentError, 'Data Table does not support arrays' if data_table.base_query.is_a?(Array)

    container_id = options[:id] || "data-table-#{SecureRandom.uuid}".gsub(/-/, '')

    filter_form_id = options[:filter_form_id] || 'form'

    height = options.delete(:height)
    width = options.delete(:width)

    selection_changed = options.delete(:selection_changed)
    row_expanding = options.delete(:row_expanding)
    master_detail = options.delete(:master_detail)

    state_storing = data_table.options.delete(:state_storing)
    disable_state_storing = !state_storing.fetch(:enabled, true)
    state_storing_json = hash_to_json(state_storing)

    bulk_actions_visible = options.fetch(:bulk_actions, data_table.options.fetch(:bulk_actions, true))

    download_options = data_table.options.fetch(:download, {})
    download_visible = options.fetch(:download_visible, download_options.fetch(:visible, true))
    csv_download_visible = options.fetch(:csv_download_visible, download_options.fetch(:csv_visible, true))
    xls_download_visible = options.fetch(:xls_download_visible, download_options.fetch(:xls_visible, false))

    functions = ''

    if master_detail
      functions += <<-JS
        ,
        masterDetail: {
            enabled: true,
            template: function(container, options) {
                #{master_detail}(container, options);
             }
        }
      JS
    end

    functions += <<-JS
      ,
       onSelectionChanged: function (selecteditems) {
         if (selecteditems.selectedRowKeys.length <= 0) return;
    JS

    if selection_changed
      functions += <<-JS
        #{selection_changed}(selecteditems);
      JS
    end

    functions += <<-JS
      }
    JS

    if row_expanding
      functions += <<-JS
      ,
       onRowExpanding: function (e) {
         #{row_expanding}(e);
       }
      JS
    end

    options_json = hash_to_json(data_table.options)

    columns_json = []

    columns_json << hash_to_json(data_table.action_column) unless data_table.actions.blank?

    columns_json.concat(data_table.columns.map do |column|
      col_data = [
        "dataField: \"#{data_table.base_query.table_name}.#{begin
          column.name.join('.')
        rescue StandardError
          column.name.to_s
        end}\"",
        "dataFieldWithoutTable: \"#{column.name}\"",
        "dataFieldExtraValue: \"#{column.extra_value}\"",
        "caption: \"#{column.caption}\"",
        'allowHiding: true'
      ]

      col_data << header_filter(column, data_table)

      col_format = hash_to_json(column.options)
      col_data << col_format unless col_format.blank?
      col_data.flatten.compact.join(',')
    end)

    columns_json = columns_json.map { |c| "{#{c}}" }.join(',')

    data_options_json = data_table.data_options.each do |k, v|
      data_table.data_options[k] = (v.respond_to?(:call) ? v.call(self) : v)
    end.to_json

    compact_view = data_table.options.delete(:compact_view)
    compact_view_json = compact_view ? compact_view.to_json : [].to_json

    custom_summary_functions = []
    summaries_json = data_table.summaries.map do |summary|
      sum_data = []

      if summary.is_a?(Devextreme::DataTable::SummaryCustom)
        if (custom_summary_function = summary.options.delete(:custom_summary_function)).present?
          custom_summary_functions << "#{custom_summary_function}(options,\"#{summary.name}\");"
        end

        if (custom_summary_value = summary.options.delete(:custom_summary_value)).present?
          custom_summary_functions << "genericCustomSummary(options,\"#{summary.name}\",\"#{custom_summary_value}\");"
        end
      end

      sum_format = hash_to_json(summary.options)
      sum_data << sum_format unless sum_format.blank?
      sum_data.flatten.join(',')
    end
    summaries_json = summaries_json.map { |s| "{#{s}}" }.join(',')
    custom_summary_functions = custom_summary_functions.join('')

    group_panel_visible = data_table.options[:group_panel][:visible]
    filter_builder_visible = data_table.options[:filter_sync_enabled]
    column_picker_visible = (options[:column_picker].nil? || options[:column_picker] == true)
    reset_layout_visible = (options[:reset_layout].nil? || options[:reset_layout] == true) && !disable_state_storing
    require_total_row_count_indicator = data_table.options[:requireTotalRowCountIndicator] == true

    render(
      partial: 'data_tables/data_table',
      locals: {
        :data_table => data_table,
        :container_id => container_id,
        :functions => functions,
        :height => height,
        :width => width,
        :options_json => options_json,
        :columns_json => columns_json,
        :compact_view_json => compact_view_json,
        :summaries_json => summaries_json,
        :custom_summary_functions => custom_summary_functions,
        :filter_builder_visible => filter_builder_visible,
        :group_panel_visible => group_panel_visible,
        :column_picker_visible => column_picker_visible,
        :download_visible => download_visible,
        :csv_download_visible => csv_download_visible,
        :xls_download_visible => xls_download_visible,
        :reset_layout_visible => reset_layout_visible,
        :converted_load_options => url_params.to_json,
        :bulk_actions_visible => bulk_actions_visible,
        :disable_state_storing => disable_state_storing,
        :filter_form_id => filter_form_id,
        :requireTotalRowCountIndicator => require_total_row_count_indicator,
        :options => options,
        :data_options_json => data_options_json,
        :state_storing_json => state_storing_json
      }
    )
  end

  private

  # To use this functionality, the following values must be set
  # - call method in data_table -> header_filter_source to set global header_filter_url
  # - set header_filter_url on column level as a symbol or proc -> :header_filter_url => proc { |view_context| view_context.url_for(action: :index, controller: :composites) }
  # - set result mapping keys:
  #   - set :text_selector  => 'key of choice', default = column.name
  #   - set :value_selector => 'key of choice', default = column.name
  # - set header_filter options on column or data_table
  # - Example {
  #           :custom_data_source => {
  #             :params => {
  #               :query_class  => FinancialQuery.to_s,
  #               :query_filter => {
  #                 :class  => FinancialQueryFilter.to_s,
  #                 :params => {
  #                   :FinancialType => FinancialType::Composite.to_s
  #                 }
  #               }
  #             }
  #           },
  #           :type => 'enum'
  #         }
  #       }
  # @param column Column
  # @param data_table DataTable
  def header_filter(column, data_table)
    return nil unless column.options[:header_filter].present?

    header_filter_options = column.options.delete(:header_filter)
    custom_data_source = header_filter_options.delete(:custom_data_source)

    header_filter_format = hash_to_json(header_filter_options)
    header_filter_format << ',' if header_filter_format.present?

    data_source_format = ""
    if custom_data_source && header_filter_options.fetch(:allow_header_filtering, true)
      text_selector = custom_data_source[:text_selector] || column.name
      value_selector = custom_data_source[:value_selector] || column.name

      header_filter_url = custom_data_source[:url]

      if header_filter_url.present?
        header_filter_url = header_filter_url.respond_to?(:call) ? header_filter_url.call(self) : send(header_filter_url)
      end

      header_filter_url ||= data_table.header_filter_url(self)

      params = custom_data_source[:params] || {}

      json_params = params.respond_to?(:call) ? params.call(self).to_json : params.to_json

      data_source_format = <<-TEXT
        dataSource: {
          paginate: false,
          map: function (dataItem) {
              return {
                  text: dataItem['#{text_selector}'],
                  value: dataItem['#{value_selector}']
              };
          },
          load: function (loadOptions) {
            var d = new $.Deferred();

            var request = $.getJSON('#{header_filter_url}', #{json_params});
            request.done(function (data) {
                d.resolve(data);
            });

            return d.promise();
          }
        }
      TEXT
    end

    <<-TEXT
      headerFilter: {
        #{header_filter_format}
        #{data_source_format}
      }
    TEXT
  end

  def hash_to_json(hash_array)
    hash_array.map do |k, v|
      if k == :cell_template
        "#{k.to_s.camelize(:lower)}: #{v}"
      elsif v.is_a?(String)
        "#{k.to_s.camelize(:lower)}: \"#{j(v)}\""
      elsif v.is_a?(Hash)
        "#{k.to_s.camelize(:lower)}: {#{hash_to_json(v)}}"
      elsif v.is_a?(Array)
        "#{k.to_s.camelize(:lower)}: #{v.to_json}"
      elsif v.nil?
        "#{k.to_s.camelize(:lower)}: null"
      else
        "#{k.to_s.camelize(:lower)}: #{v}"
      end
    end.join(',')
  end
end
