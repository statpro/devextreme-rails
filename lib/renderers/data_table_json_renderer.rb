require 'json'
module Devextreme
  ActionController::Renderers.add :data_table_json do |model, options|
    send_data(model.to_json(view_context, params), :type => Mime[:json])
  end
end
