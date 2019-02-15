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

    has_s3_download = options.delete(:has_s3_download)

    selection_changed = options.delete(:selection_changed)
    master_detail = options.delete(:master_detail)

    state_storing = options.delete(:disable_state_storing)
    disable_state_storing = state_storing.presence ? state_storing : false

    bulk_actions = (options[:bulk_actions] || data_table.options[:bulk_actions])
    bulk_actions_visible = bulk_actions.presence ? bulk_actions : true

    functions = ''

    if master_detail
      functions += <<-JS
        ,
        masterDetail: {
            enabled: true,
            template: function(container, options) {
                container.addClass('internal-grid-container').attr('id', options.rowIndex);
                #{master_detail}(options);
             }
        }
      JS
    end

    functions += <<-JS
      ,
       onSelectionChanged: function (selecteditems) {
    JS

    if selection_changed
      functions += <<-JS
        #{selection_changed}(selecteditems);
      JS
    end

    functions += <<-JS
      }
    JS

    options_json = hash_to_json(data_table.options)

    columns_json = data_table.columns.map do |column|
      col_data = [
        "dataField: '#{data_table.base_query.table_name}.#{column.name.join('.') rescue column.name.to_s}'",
        "dataFieldWithoutTable: '#{column.name.to_s}'",
        "dataFieldExtraValue: \"#{column.extra_value.to_s}\"",
        "caption: '#{column.caption}'",
        "allowHiding: true"
      ]

      col_format = hash_to_json(column.options)
      col_data << col_format unless col_format.blank?
      col_data.flatten.join(',')
    end

    columns_json << hash_to_json(data_table.action_column) unless data_table.actions.blank?
    columns_json = columns_json.map{|c| "{#{c}}"}.join(',')

    compact_view = data_table.options.delete(:compact_view)
    compact_view_json = compact_view ? compact_view.to_json : [].to_json

    summaries_json = data_table.summaries.map do |summary|
      if summary.is_a?(DataTable::SummaryCustom)
        showInColumn = summary.options.delete(:showInColumn)
        column = summary.options.delete(:column)
        sum_data = [
          "name: '#{data_table.base_query.table_name}.#{summary.name.join('.') rescue summary.name.to_s}'",
          "showInColumn: '#{data_table.base_query.table_name}.#{showInColumn}'",
          "column: '#{data_table.base_query.table_name}.#{column}'"
        ]
      else
        sum_data = [
          "column: '#{data_table.base_query.table_name}.#{summary.name.join('.') rescue summary.name.to_s}'"
        ]
      end
      sum_format = hash_to_json(summary.options)
      sum_data << sum_format unless sum_format.blank?
      sum_data.flatten.join(',')
    end
    summaries_json = summaries_json.map{|s| "{#{s}}"}.join(',')

    group_panel_visible = data_table.options[:group_panel][:visible]
    column_picker_visible = (options[:column_picker].nil? || options[:column_picker] == true)
    download_visible = (options[:download].nil? || options[:download] == true)
    reset_layout_visible = (options[:reset_layout].nil? || options[:reset_layout] == true) && !disable_state_storing
    requireTotalRowCountIndicator = data_table.options[:requireTotalRowCountIndicator] == true
    
    render( :partial => 'data_tables/data_table',
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
              :group_panel_visible => group_panel_visible,
              :column_picker_visible => column_picker_visible,
              :download_visible => download_visible,
              :has_s3_download => has_s3_download,
              :reset_layout_visible => reset_layout_visible,
              :converted_load_options => url_params.to_json,
              :bulk_actions_visible => bulk_actions_visible,
              :disable_state_storing => disable_state_storing,
              :filter_form_id => filter_form_id,
              :requireTotalRowCountIndicator => requireTotalRowCountIndicator,
              :options => options})
  end

  private

  def hash_to_json(hash_array)
    hash_array.map do |k, v|
      if k == :cell_template
        "#{k.to_s.camelize(:lower)}: #{v}"
      elsif v.is_a?(String)
        "#{k.to_s.camelize(:lower)}: '#{v}'"
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
