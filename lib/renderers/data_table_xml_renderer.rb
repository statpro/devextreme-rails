module Devextreme
  ActionController::Renderers.add :data_table_xml do |model, options|
    if options[:filename].present?
      filename = options[:filename]
    elsif model.is_a?(DataTable::Base)
      filename = model.base_query.first ? model.base_query.first.class.model_name.human(:count => 2) : self.controller_name.titleize
    else
      raise ArgumentError "Invalid model: #{model.class}"
    end

    send_data(
      model,
      :type => :xml,
      :disposition => "attachment; filename=#{filename}.xml"
    )
  end

  class DataTableXmlGenerator

    def initialize(instance, options = {})
      @instance = instance
      @options = options

      @summary = @options.delete(:summary)
      @view_context = @options.delete(:view_context)
      @params = @options.delete(:params)
    end

    def run(iterator_method)
      append_xml(iterator_method)
    end

    private

    def append_xml(iterator_method)
      # nop
    end

  end
end
