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
      'filterOptions' => options[:columns_layout]['filterOptions'],
      'sortOptions' => options[:columns_layout]['sortOptions']
    )

    send_data(
      model.to_csv(view_context, new_params, options),
      :type => mime_type,
      :disposition => "attachment; filename=#{filename}.#{extension}"
    )
  end
end
