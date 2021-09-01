module DataTableHelper

  # options
  #   grid function calls supported usage
  #   :selection_changed => 'someFunctionToCall'
  def render_data_table(data_table, options = {})

    raise ArgumentError, "Data Table does not support arrays" if data_table.base_query.is_a?(Array)
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

    columns_json = data_table.columns.map do |column|
      col_data = [
        "dataField: \"#{data_table.base_query.table_name}.#{column.name.join('.') rescue column.name.to_s}\"",
        "dataFieldWithoutTable: \"#{column.name.to_s}\"",
        "dataFieldExtraValue: \"#{column.extra_value.to_s}\"",
        "caption: \"#{column.caption}\"",
        "allowHiding: true"
      ]

      col_format = hash_to_json(column.options)
      col_data << col_format unless col_format.blank?
      col_data.flatten.join(',')
    end

    columns_json << hash_to_json(data_table.action_column) unless data_table.actions.blank?
    columns_json = columns_json.map{|c| "{#{c}}"}.join(',')

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
    summaries_json = summaries_json.map{|s| "{#{s}}"}.join(',')
    custom_summary_functions = custom_summary_functions.join('')

    group_panel_visible = data_table.options[:group_panel][:visible]
    column_picker_visible = (options[:column_picker].nil? || options[:column_picker] == true)
    reset_layout_visible = (options[:reset_layout].nil? || options[:reset_layout] == true) && !disable_state_storing
    requireTotalRowCountIndicator = data_table.options[:requireTotalRowCountIndicator] == true
    
    render(
      :partial => 'data_tables/data_table',
      :locals => {
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
        :requireTotalRowCountIndicator => requireTotalRowCountIndicator,
        :options => options,
        :data_options_json => data_options_json,
        :state_storing_json => state_storing_json
      }
    )
  end

  private

  def hash_to_json(hash_array)
    hash_array.map do |k, v|
      if k == :cell_template
        "#{k.to_s.camelize(:lower)}: #{v}"
      elsif v.is_a?(String)
        "#{k.to_s.camelize(:lower)}: \"#{v}\""
      elsif v.is_a?(Hash)
        "#{k.to_s.camelize(:lower)}: {#{hash_to_json(v)}}"
      elsif v.is_a?(Array)
        "#{k.to_s.camelize(:lower)}: #{v.to_json}"
      else
        "#{k.to_s.camelize(:lower)}: #{v}"
      end
    end.join(',')
  end

end
