module Devextreme
  module DataTable

    # See documentation of the Data Grid
    #  http://js.devexpress.com/Documentation/ApiReference/UI_Widgets/dxDataGrid

    def self.data_table_for(klass)
      klass.respond_to?(:model_data_table) ?
        klass.model_data_table :
        "#{klass.to_s}DataTable".constantize
    end

    def self.new(klass, base_query = nil, &block)
      data_table = GeneratedDataTable.new(base_query || klass)
      block.call(data_table) if block_given?
      data_table
    end

    class Base

      attr_reader :columns,
                  :method,
                  :options,
                  :data_options,
                  :actions,
                  :label_decorators,
                  :summaries,
                  :source_url,
                  :source_parents,
                  :source_options,
                  :store_source_url,
                  :store_source_parents,
                  :store_source_options,
                  :highlight_row,
                  :highlight_row_class

      attr_accessor :base_query

      def initialize(base_query)
        @base_query = base_query
        @t_scope = self.class.name.gsub('DataTable', '').demodulize.underscore.to_sym

        @options = {
          :scrolling => {
            :mode => 'virtual',
            :preloadEnabled => false,
            :use_native => false,
            :scrollByContent => false
          },
          :remoteOperations => {
            :groupPaging => true,
            :grouping => false,
            :filtering => true,
            :sorting => true,
            :paging => true
          },
          :hover_state_enabled => false,
          :header_filter => {
            :visible => false,
          },
          :filter_row => {
            :visible => false,
            :show_operation_chooser => true
          },
          :filter_panel => {
            :visible => false
          },
          :filter_sync_enabled => false, # Used to sync the filter row and the filter builder,
          :search_panel => {
            :visible => false
          },
          :allow_column_reordering => true,
          :allow_column_resizing => true,
          :grouping => {
            :group_continued_message => I18n.translate(:group_continued_message, :scope => [:data_tables, :shared]),
            :group_continues_message => I18n.translate(:group_continues_message, :scope => [:data_tables, :shared])
          },
          :group_panel => {
            :emptyPanelText => I18n.translate(:group_panel, :scope => [:data_tables, :shared]),
            :allow_column_dragging => true,
            :visible => false
          },
          :row_alternation_enabled => true,
          :no_data_text => I18n.translate(:none_found, :scope => [:data_tables, @t_scope]),
          :show_column_lines => true,
          :show_row_lines => false,
          :sorting => {
            :mode => 'multiple',
            :descendingText => I18n.translate(:descending_text, :scope => [:data_tables, :shared]),
            :ascendingText => I18n.translate(:ascending_text, :scope => [:data_tables, :shared]),
            :clearText => I18n.translate(:clear_text, :scope => [:data_tables, :shared])
          },
          :loadPanel => {
            :enabled => true,
            :showIndicator => true,
            :showPane => true
          },
          :columnAutoWidth => true,
          :wordWrapEnabled => false,
          :requireTotalRowCountIndicator => true,
          :columnFixing => {
            :enabled => false
          },
          :selection => {
            :mode => 'multiple',
            :allow_select_all => false,
            :show_check_boxes_mode => 'onClick',
            :select_all_mode => 'page'
          },
          :state_storing => {
            :ignore_column_option_names => [],
            :enabled => true,
            :saving_timeout => 500,
            :type => 'custom'
          },
          #
          # DO NOT EVER REMOVE!!!!
          # This stops the grid from reloading twice.
          #
          :paging => {
            :pageSize => 25 #AppConfig.small_page_size
          },
          :download => {
            :visible => true,
            :csv_visible => true,
            :xls_visible => true
          }

        }

        @data_options = {
          :controller_name => proc { |vc| vc.controller_name },
          :action_name => proc { |vc| vc.action_name },
          :grid_name => self.class.name,
          :reset_layout_url => proc { |vc| vc.user_grid_layouts_reset_layout_path }
        }
        @actions = []
        @label_decorators = []
        @summaries = []
        @source_options = {}
        @source_parents = []
        @highlights = []
      end

      def download_file_name(view_context)
        filename = nil
        if options[:download_filename].present?
          filename = options[:download_filename]
        elsif self.base_query.is_a?(ActiveRecord::Relation)
          klass = self.base_query.klass
          if klass.respond_to?(:model_name)
            # try default to a nice name else rescue nil
            filename = klass.model_name.human(:count => 2) rescue nil
          end
        elsif self.base_query.respond_to?(:human)
          filename = self.base_query.human
        end
        filename || view_context.controller_name.titleize
      end

      def define_columns(&block)
        builder = ColumnBuilder.new(@t_scope)
        yield builder if block_given?

        if builder.columns.select{ |col| col.name == :id}.empty?
          builder.columns << ColumnInteger.new(:id, @t_scope, :visible => false, :showInColumnChooser => false, :downloadable => false, :user_visible => false)
        end

        # Add hidden columns for sorting by calculated value
        builder.columns.each do |column|
          if column.options.fetch(:calculate_sort_value, false) == true
            new_column = column.is_a?(DataTable::ColumnTimeago) ? DataTable::ColumnText.new(column.name, @t_scope, DataTableFormatters.format_hidden.merge(:data_type => 'datetime')) : column.dup
            new_column.instance_variable_set(:@name, "#{new_column.name}_calculate_sort_value".to_sym)
            new_column.instance_variable_set(:@params, {:link_to => nil, :link_to_content => nil, :new_tab => nil, :cell_css_class => nil, :remote => nil})
            if column.is_a?(DataTable::ColumnTimeago)
              new_column.instance_variable_set(:@value, proc { |i, vc| i.send(column.name).strftime("%Y/%m/%d/ %k:%M:%S") })
            else
              new_column.instance_variable_set(:@options, DataTableFormatters.format_hidden)
              new_column.instance_variable_set(:@value, proc { |i, vc| i.send(column.name) })
            end

            builder.columns << new_column

            column.options[:calculate_sort_value] = "#{base_query.table_name}.#{column.name}_calculate_sort_value"
          end

          if column.cell_css_class.present?
            new_column = ColumnText.new("#{column.name}_cell_css_class".to_sym, @t_scope, {:visible => false, :showInColumnChooser => false, :downloadable => false, :user_visible => false, :caption => "#{column.name}_cell_css_class"}, column.cell_css_class.dup)

            builder.columns << new_column
          end
        end

        @columns = builder.columns
      end

      def define_summaries(&block)
        builder = SummaryBuilder.new(@t_scope, base_query.table_name)
        yield builder if block_given?
        @summaries = builder.summaries
      end

      def tables
        @tables ||= begin
          arel = @base_query.arel

          tables = {}

          visitor = Arel::Visitors::TableVisitor.new do |object|
            # unless object.engine == ActiveRecord::Base
            #   tables[object.name] ||= object
            #   tables[object.table_alias] ||= object if object.table_alias
            # end
            tables[object.name] ||= {:arel_table => object, :arel_klass => @base_query.klass}
            tables[object.table_alias] ||= {:arel_table => object, :arel_klass => @base_query.klass} if object.table_alias
          end

          unique_projections = arel.projections.select {|p|
            p.is_a?(Arel::Attributes::Attribute)
          }.collect(&:relation).uniq(&:name)

          [*arel.froms, *arel.join_sources, *unique_projections].uniq.each do |table|
            if table.is_a?(Arel::Nodes::Binary)
              visitor.accept(table.left)
              visitor.accept(table.right)
            else
              visitor.accept(table)
            end
          end

          tables
        end
      end

      # Create a variable for the altered query
      # The reason for this is so that i dont have the pass this (query) all over the place
      # Possible additions:
      # sorters
      # joiners
      # where's
      attr_accessor :sorted_and_filtered_query
      def query!(params)
        @sorted_and_filtered_query = @base_query.arel.dup # convert to AREL
        apply_sorting(params)
        apply_filter!(params)
        apply_grouping!(params)
        @sorted_and_filtered_query
      end

      private def apply_sorting(params)

        sort_params = params.fetch('sortOptions', {})

        # got any?
        return if sort_params.blank?

        sort_params = JSON.parse(sort_params) if sort_params.is_a? String

        @sorted_and_filtered_query.orders.clear

        sort_params.each do |sorter|

          order_desc = sorter['desc'] == true
          table, attribute, assoc_attribute = sorter['selector'].split('.')

          arel_col = get_arel_column(table, attribute, assoc_attribute)
          next unless arel_col

          @sorted_and_filtered_query = @sorted_and_filtered_query.order(order_desc ? arel_col.desc : arel_col.asc)

        end
      end

      private def apply_grouping!(params)
        group_params = params.fetch('groupOptions', {})

        # got any?
        return if group_params.blank?

        group_params = JSON.parse(group_params) if group_params.is_a? String

        @sorted_and_filtered_query.projections.clear

        group_params.each do |grouper|

          table, attribute, assoc_attribute = grouper['selector'].split('.')

          arel_col = get_arel_column(table, attribute, assoc_attribute)
          next unless arel_col

          @sorted_and_filtered_query = @sorted_and_filtered_query.group(arel_col)
          @sorted_and_filtered_query = @sorted_and_filtered_query.project(arel_col)

        end
      end

      def get_arel_column(table, attribute, assoc_attribute)
        arel_col = nil
        arel_table = tables[table][:arel_table]
        arel_klass = tables[table][:arel_klass]

        # got one?
        unless arel_table
          ::Rails.logger.warn "'#{table}' table not found. Is the query for '#{arel_table.name}' correct?"
          return nil
        end

        # basic column, or association?
        if arel_klass.columns.collect(&:name).include?(attribute)
          arel_col = arel_table[attribute]

        elsif assoc_attribute

          #
          # NOTE: this only works to 1 level of association
          #  and `sorter['selector']` will have 3 parts
          #
          # reflect on the belongs to associations
          #  and attempt to find the column.
          #
          # E.g.
          #
          #   total_asset_series.currency.code
          #

          associations = arel_klass.reflect_on_all_associations(:belongs_to).inject({}) {|list, assoc|
            list[assoc.name.to_s] = assoc
            list
          }

          if associations.key?(attribute)

            # get the association
            association = associations[attribute]

            # can't handle polymorphic associations
            # since it would need to join on more than
            # one model
            return nil if association.polymorphic?

            # get the table of the associated class
            assoc_arel_table = association.klass.arel_table
            assoc_arel_engine = association.klass.arel_engine

            # table already joined in base query?
            includes_table = @sorted_and_filtered_query.join_sources.any? do |join|
              join.left.name == assoc_arel_table.name ||
                  join.right.each {|object|
                    object.is_a?(Arel::Table) && object.name == assoc_arel_table.name
                  }
            end

            unless includes_table
              @sorted_and_filtered_query = @sorted_and_filtered_query.join(assoc_arel_table)
                          .on(arel_table[association.foreign_key].eq(
                              assoc_arel_table[association.association_primary_key]))
            end

            if assoc_arel_engine.columns.collect(&:name).include?(assoc_attribute)
              arel_col = assoc_arel_table[assoc_attribute]
            else
              # associated column doesn't exist, ignore error and continue
              ::Rails.logger.warn "Associated column '#{assoc_attribute}' not found. Is the query for '#{assoc_arel_table.name}' correct?"
              return nil
            end
          else
            # relation doesn't exist, ignore error and continue
            ::Rails.logger.warn "No 'belongs_to' association for '#{attribute}' found. Is the query for '#{arel_table.name}' correct?"
            return nil
          end

        else
          # column doesn't exist, ignore error and continue
          ::Rails.logger.warn "Column '#{attribute}' not found. Is the query for '#{arel_table.name}' correct?"
          return nil
        end

        arel_col
      end

      #
      # Unary filter
      # Supported operators: binary operators, "!".
      #
      # See: https://js.devexpress.com/Documentation/ApiReference/Data_Layer/CustomStore/LoadOptions/#filter
      #
      private def apply_filter!(params)
        # filtering
        filter_options = params.fetch('filterOptions', {})

        return if filter_options.blank?

        filter_options = JSON.parse(filter_options) if filter_options.is_a? String

        conditions = build_filter_conditions(filter_options)

        @sorted_and_filtered_query = @sorted_and_filtered_query.where(
          add_arel_conditions(conditions)
        )
      end

      # Example filters:
      # [["vComposites.ShortName", "contains", "comp"],
      #  "or",
      #  [["vComposites.ShortName", "contains", "adm"], "and", ["vComposites.InceptionDate", ">=", "1800/01/02"]]]
      def build_filter_conditions(filters)
        conditions = []

        return build_arel_conditions(filters) if filters.dimension == 1

        # Binary filter
        # ie. [ "dataField", "=", 3 ]
        # Unary filter
        # ie. [ "!", [ "dataField", "=", 3 ] ]
        unary_condition = filters.shift if filters.dimension > 1 && filters.first&.is_a?(String)

        filters.each_slice(2).each do |filter, condition|

          if filter.dimension > 1
            conditions_set = build_filter_conditions(filter)

            if unary_condition.present?
              # Prepend to handle in #add_arel_conditions with Arel::Nodes::Not
              conditions << ['not', conditions_set]
            else
              conditions << conditions_set
            end

            # condition: AND | OR
            conditions << condition if condition
          else
            conditions_set = build_arel_conditions(filter, condition, conditions)

            if unary_condition.present?
              # Prepend to handle in #add_arel_conditions with Arel::Nodes::Not
              conditions = ['not', conditions_set]
            else
              conditions = conditions_set
            end
          end

        end

        conditions
      end

      # Calling .to_sql on arel conditions:
      # ["[vComposites].[ShortName] LIKE N'%comp%'",
      #  "or",
      #  ["[vComposites].[ShortName] LIKE N'%adm%'", "and", "[vComposites].[InceptionDate] >= '01-01-1800 00:00:00.0'"]]
      def add_arel_conditions(conditions)
        arel_conditions = conditions.shift
        while conditions.any? || arel_conditions.first == 'not'

          # Handle a array of AREL conditions
          if arel_conditions.is_a?(Array) && arel_conditions.first == 'not'
            use_not_node = true
            # Drop 'not' condition
            arel_conditions.shift
            arel_conditions.flatten!(1)
          end

          # Handle a single AREL condition
          if arel_conditions == 'not'
            use_not_node = true
            conditions.flatten!(1)
            return Arel::Nodes::Not.new(conditions.first) if conditions.dimension == 1
          end

          operator, right_condition = conditions.shift(2)

          if arel_conditions.is_a?(Array)
            arel_conditions = Arel::Nodes::Grouping.new(add_arel_conditions(arel_conditions))
          end

          if right_condition.is_a?(Array)
            right_condition = Arel::Nodes::Grouping.new(add_arel_conditions(right_condition))
          end

          if use_not_node
            arel_conditions = Arel::Nodes::Not.new(arel_conditions)

            if right_condition.present?
              arel_conditions = arel_conditions.send(
                operator,
                right_condition
              )
            end

            # Reset value for next iteration
            use_not_node = nil
          else
            arel_conditions = arel_conditions.send(
              operator,
              right_condition
            )
          end
        end
        arel_conditions
      end

      # Example filter:
      #
      # Binary filter:
      #   ["vComposites.ShortName", "contains", "comp"]
      #   will produce an arel statement:
      #   "[vComposites].[ShortName] LIKE N'%comp%'"
      #
      # Unary filter:
      #   "["!", ["vComposites.HasWarningsCurrent", "=", true]]"
      #   will produce an arel statement:
      #   "NOT [vComposites].[ShortName] = true"
      #
      def build_arel_conditions(filter, condition = nil, conditions = [])
        column, operator, expr = filter

        table, attribute, assoc_attribute = column.split('.')

        data_table_column = @columns.detect do |c|
          if assoc_attribute
            c.name == [attribute, assoc_attribute].map(&:to_sym)
          else
            c.name == attribute.to_sym
          end
        end

        arel_col = get_arel_column(table, attribute, assoc_attribute)
        return [] unless arel_col

        if is_date_column = expr && [Devextreme::DataTable::ColumnDate, Devextreme::DataTable::ColumnTimeago].any? { |k| data_table_column.is_a? k }
          expr = DateTime.parse(expr)
        end

        operation = case operator
                      when "="
                        arel_col.eq(expr)
                      when "<>"
                        arel_col.not_eq(expr)
                      when "<"
                        expr = expr.beginning_of_day if is_date_column
                        arel_col.lt(expr)
                      when ">"
                        expr = expr.beginning_of_day if is_date_column
                        arel_col.gt(expr)
                      when "<="
                        expr = expr.beginning_of_day if is_date_column
                        arel_col.lteq(expr)
                      when ">="
                        expr = expr.beginning_of_day if is_date_column
                        arel_col.gteq(expr)
                      when "contains"
                        arel_col.matches("%#{expr}%", nil, true)
                      when "notcontains"
                        arel_col.does_not_match("%#{expr}%", nil, true)
                      when "startswith"
                        arel_col.matches("#{expr}%", nil, true)
                      when "endswith"
                        arel_col.matches("%#{expr}", nil, true)
                      when "between"
                        arel_col.between(expr)
                      else
                        raise ArgumentError, "Unsupported operator #{operator}."
                    end
        if operation
          conditions << operation
          conditions << condition if condition
        end

        conditions
      end

      def option(option)
        @options.deep_merge!(option)
      end

      def data_option(option)
        @data_options.deep_merge!(option)
      end

      def action_builder(name, &block)
        @actions << {:name => name, :builder => block}
      end

      def label_decorator(name, &block)
        @label_decorators << {:name => name, :decorator => block}
      end

      def action(name, image, extra = nil, value = nil, visible_lambda = nil)
        value, extra = extra, nil if value.nil? && extra.respond_to?(:call)
        extra = extra || {}
        method = extra.fetch(:method, :get)
        remote = extra.fetch(:remote, nil)
        css_class  = extra.fetch(:class, nil)
        translation_params = extra.fetch(:translation_params, {})
        title = I18n.translate(name, **{:scope => [:data_tables, :actions]}.merge(translation_params))
        data = {:method => method} unless method == :none
        data[:remote] = true if remote
        data[:confirm] = "Are you sure?" if method == :delete

        @actions << {
          :name => name,
          :image => image,
          :value => value,
          :title => title,
          :data => data,
          :css_class => css_class,
          :visible_lambda => visible_lambda
        }
      end

      def include_crud_actions(path = nil, *parents)
        add_show_action(path, *parents)
        add_edit_action(path, *parents)
        add_delete_action(path, *parents)
      end

      def add_show_action(path = nil, *parents)
        action :show, :'file-text', proc { |instance, view_context| path ? view_context.send(path, *parents, instance) : view_context.url_for(:controller => view_context.controller_name, :action => :show, :id => instance.to_param) }
      end

      def add_edit_action(path = nil, *parents)
        action :edit, :pencil, proc { |instance, view_context| path ? view_context.send("edit_#{path.to_s}".to_sym, *parents, instance) : view_context.url_for(:controller => view_context.controller_name, :action => :edit, :id => instance.to_param) }
      end

      def add_delete_action(path = nil, *parents)
        action :delete, :times, {:method => :delete}, proc { |instance, view_context| path ? view_context.send(path, *parents, instance) : view_context.url_for(:controller => view_context.controller_name, :action => :destroy, :id => instance.to_param) }
      end

      def add_impact_action
        action :impact, :sitemap, { :method => :post, :remote => true}, proc { |instance, view_context| view_context.impacts_for_impact_management_index_path(:entity_id => instance.id, :entity_type =>instance.model_name.name) }
      end

      def add_lock_unlock_action
        action_builder :lock do |action, instance|
          if instance.locked?
            action[:name]  = :unlock
            action[:image] = :unlock
            action[:data] = {:method => :put, :remote => true}
            action[:value] = proc { |i, vc| vc.url_for(:action => :unlock, :controller => vc.controller_name, :id => i.id) }
          else
            action[:name]  = :lock
            action[:image] = :lock
            action[:data] = {:method => :put, :remote => true}
            action[:value] = proc { |i, vc| vc.url_for(:action => :lock, :controller => vc.controller_name, :id => i.id) }
          end
          action
        end
      end

      def source(url, *parents)
        @source_options = parents.extract_options!
        @source_url = url.to_sym
        @source_parents = parents
      end

      # Set path for custom filtering functionality
      # @param url Symbol or String
      def store_source(url, *parents)
        @store_source_options = parents.extract_options!
        @store_source_url = url.to_sym
        @store_source_parents = parents
      end

      # if this is called, then overrides source_url, source_parents and source_options
      def source_path(url_path)
        @url = url_path
      end

      def store_source_path(url_path)
        @store_url = url_path
      end

      def url(view_context, options={})
        # return what was provided to source_path
        is_master_detail = options.delete(:is_master_detail) || false
        return @url if @url && !is_master_detail

        # otherwise, build the path
        if source_url.nil?
          view_context.url_for(*source_parents, source_options.merge(options))
        else
          view_context.send(source_url, *source_parents, source_options.merge(options))
        end
      end

      def store_url(view_context, options={})
        # return what was provided to store_source_path
        return @store_url if @store_url

        # otherwise, build the path
        if store_source_url.nil?
          view_context.url_for(*store_source_parents, store_source_options.merge(options))
        else
          view_context.send(store_source_url, *store_source_parents, store_source_options.merge(options))
        end
      end

      def highlight_row(highlight_row_class, highlight_row_callback)
        @highlights << { :class => highlight_row_class, :callback => highlight_row_callback }
      end

      def use_additional_layout_key(the_key)
        @additional_layout_key = the_key
      end

      def additional_layout_key
        @additional_layout_key || 0
      end

      def action_column
        col_data = {
          :data_field => '_actions',
          :data_type => 'string',
          :width => 64, #41.66 * self.actions.length,
          :caption => '',
          :cell_template => :column_template_actions,
          :allowFixing => false,
          :allowResizing => false,
          :allowHiding => false,
          :allowReordering  => false
        }.merge(DataTableFormatters.filter_sort_disable)

        col_data.merge!({:fixed => true, :fixedPosition => 'left'}) if options.fetch(:fixed_actions, true)

        col_data
      end

      def data_field_for(name)
        "#{self.base_query.table_name}.#{name}"
      end

      def to_json(view_context, params = {})
        resultset, total_count = get_resultset_and_count(params)

        if params.key?(:dataField)
          request_column = self.columns.detect{ |c| c.name == params[:dataField].split('.').last.to_sym }
          Jbuilder.encode do |json|
            json.items(resultset) do |instance|
              value = request_column.value(instance, view_context) rescue nil
              json.set! :key, value
            end
          end
        else
          Jbuilder.encode do |json|

            json.items(resultset) do |instance|

              json.set!(@base_query.table_name) do
                self.columns.each do |c|
                  value = c.value(instance, view_context) rescue nil
                  if c.is_a? DataTable::ColumnHidden
                    json.hidden value
                  elsif c.is_a? DataTable::ColumnLookup
                    json.set! c.name.first do
                      json.set! c.name.last, value
                    end
                  else
                    json.set! c.name, value
                  end

                  highlights_to_set = @highlights.detect do |highlight|
                    highlight[:callback].call(instance)
                  end

                  json.set! '_highlight_row', {
                    :highlight_row_class =>  highlights_to_set[:class],
                    :highlight_row => highlights_to_set[:callback] }.to_json if highlights_to_set

                end
              end

              # actions
              if self.actions
                actions = self.actions.map { |action| build_action(action, instance, view_context) }.reject(&:blank?)
                json._actions actions.to_json
              end
            end

            json.total_count(total_count) if total_count
          end
        end
      end

      def get_resultset_and_count(params, options = {})

        query = self.query!(params)

        no_limit = options.fetch(:no_limit, false) || params.fetch(:no_limit, false).to_b

        unless no_limit
          query.offset = params.fetch('skip', 0).to_i
          query.limit = params.fetch('take', 1000).to_i # putting hard limit unless no_limit to prevent issues (not ideal of course)
        end

        # NB: TODO message about OFFSET in SQL Server requiring an ORDER
        if is_connection_sql_server? && query.orders.empty? && !no_limit
          query = query.order("(SELECT NULL)")
        end

        resultset = @base_query.model.unscoped.from(
          @base_query.arel_table.create_table_alias(query, @base_query.model.table_name)
        )

        # avoid n+1's
        begin
          ActiveRecord::Associations::Preloader.new.preload(resultset, @base_query.includes_values) if @base_query.includes_values.present?
        rescue ActiveModel::MissingAttributeError
          # Do nothing here
        end

        require_count = params.fetch('requireTotalCount', 'false') == 'true'

        total_count = if require_count
                        # Need to dup the arel object
                        # Changing attributes on the arel object will alter the query used for getting the 'resultset'
                        count_query = query.dup
                        count_query.projections.clear
                        count_query.orders.clear
                        count_query.offset = nil
                        count_query.limit = nil

                        # Need to run off the base class for STI model.
                        # Activerecord will add the default scope back for STI models
                        sql = @base_query.model.base_class.unscoped.from(
                          @base_query.arel_table.create_table_alias(
                            count_query.project(Arel.star.count.as('row_count')
                            ), @base_query.model.base_class.table_name)
                        ).to_sql

                        @base_query.model.connection.exec_query(sql).first['row_count']
                      end

        return resultset, total_count
      end

      def build_action(action, instance, view_context)
        # shitty! methods are too coupled, need to inject an instance of action
        action = action[:builder].call({}, instance, view_context) if action[:builder]

        # Skip action when not setup using action_builder
        # e.g. /app/data_tables/exchange_rate_value_data_table.rb line 18
        return nil if action.blank?

        is_visible = if action[:visible_lambda]
                       action[:visible_lambda].call(instance)
                     else
                       instance.respond_to?(:system_record?) && action[:name] != :show ? !instance.system_record? : true
                     end

        return nil if !is_visible

        build_action_hash(action, instance, view_context)
      end

      def build_action_hash(action, instance, view_context)
        css_class = action[:css_class] || ''
        data = {
          :name   => action[:name],
          :url    => action[:value].call(instance, view_context),
          :method => action[:method].to_s,
          :image  => view_context.icon_class(action[:image]).join(' '),
          :title  => action[:title] || I18n.translate(action[:name], :scope => [:data_tables, :actions]),
          :data   => action[:data],
          :css_class => css_class
        }
        data.merge!(:rel => "nofollow") if action[:method] == :delete
        data
      end

      def to_csv(view_context, params, options)

        #
        # NOTE: this implementation has the potential to run out of memory
        #       since it loads all the data in memory...
        #
        # TODO: refactor to use `send_data` so that the data is streamed to the browser instead
        #

        header = []
        rows = []

        cols = @columns.select{ |col| col.downloadable? }

        if @options.fetch(:write_headers, :true)
          header << cols.collect{|c| c.caption}.join(',')
        end

        resultset, _ = get_resultset_and_count(params, options)

        resultset.each do |instance|
          rows << cols.collect do |c|
            value = c.to_csv_text(instance, view_context) rescue nil
            value.is_a?(Hash) ? value[:text] : value
          end.join(',')
        end

        (header + rows).join("\n")
      end

      def to_xls(view_context, params, options)

        #
        # NOTE: this implementation has the potential to run out of memory
        #       since it loads all the data in memory...
        #
        # TODO: refactor to use `send_data` so that the data is streamed to the browser instead
        #

        resultset, _ = get_resultset_and_count(params, options)

        DataTableXlsGenerator.new(self, view_context, resultset, options).run

      end

      # NOTE: these methods consumed by DataTableXlsGenerator

      def each_header
        @columns
          .select {|column| column.options.fetch(:user_visible, true) == true}
          .sort_by {|column| column.options[:user_visible_index]}
          .collect(&:caption)
      end

      def each_row(instance, view_context)
        @columns
          .select{ |column| column.options.fetch(:user_visible, true) == true }
          .sort_by{ |column| column.options[:user_visible_index] }
          .collect{ |column| column.to_xls_text(instance, view_context) rescue nil }
      end

      private

      def is_connection_sql_server?
        @base_query.model.connection.adapter_name == "SQLServer"
      end

      def parameter_binding_character
        is_connection_sql_server? ? /[\$@].+/ : /\$.+/
      end

    end

    class Column

      attr_reader :name,
                  :caption,
                  :options,
                  :params,
                  :sorter,
                  :filterer,
                  :extra_value

      def initialize(name, t_scope, options = nil, value = nil)
        @name = name
        @t_scope = t_scope
        extract_arguments!(options, value)

        # disable filtering and sorting if a value is present unless a sorter/filter is provided
        if @value
          option(DataTableFormatters.sort_disable) unless @sorter
          option(DataTableFormatters.filter_disable) unless @filterer
        end

        # default ':allow_grouping => false'
        option(DataTableFormatters.grouping_disable)

        # hide group column name if hide_grouping_column_name = true
        if @options.delete(:hide_grouping_column_name)
          option(DataTableFormatters.hide_grouping_column_name)
        end

      end

      def option(option)
        @options.reverse_merge!(option)
      end

      def downloadable?
        @options[:downloadable] != false
      end

      def link_to?
        @link_to ||= @params[:link_to].present?
      end

      def cell_css_class
        @cell_css_class ||= @params[:cell_css_class]
      end

      def link_to_content?
        @link_to_content ||= @params[:link_to_content].present?
      end

      def remote?
        @remote ||= @params.fetch(:remote, false);
      end

      def value_as_lambda?
        @value.respond_to? :call
      end

      # returns the value that will be displayed in the grid.
      # gets transformed and formatted depending on the column type.
      def value(instance, view_context)
        text = get_value(instance, view_context)
        text = extra_text_formatting(instance, view_context, text)
        text
      end

      # override this method if you want to transform the value in any way before displaying on the grid.
      def transform(instance, view_context, text)
        text
      end

      def to_csv_text(instance, view_context)
        get_value(instance, view_context)
      end

      # calling to_csv_text for overridden methods when exporting
      # Keeping the methods separate for future overrides and diff's between implementations
      def to_xls_text(instance, view_context)
        to_csv_text(instance, view_context)
      end

      # returns the raw value with no transformations. N.B. You shouldn't override this method
      def get_value(instance, view_context)
        if @value.is_a? String
          @value
        elsif value_as_lambda?
          @value.call(instance, view_context)
        else
          instance.send(@name)
        end
      end

      def text(instance, view_context)
        get_value(instance, view_context)
      end

      protected

      def extra_text_formatting(instance, view_context, text)
        text = transform(instance, view_context, text)
        text = extra_link_formatting(instance, view_context, text)
        text = extra_css_formatting(instance, text)
        text
      end

      def extra_link_formatting(instance, view_context, text)
        if link_to?
          text = {:href => @params[:link_to].call(instance, view_context), :text => text, :'data_remote' => remote?, :value => text}
          text.merge!(:target => '_blank') if @params[:new_tab]
        elsif link_to_content?
          text = {:content => @params[:link_to_content].call(instance, view_context), :text => text, :value => text}
        end
        text
      end

      def extra_css_formatting(_instance, text)
        text
      end

      private

      def extract_arguments!(options = nil, value = nil)
        value, options = options, nil if value.nil? && options.respond_to?(:call)
        @options = options || {}
        @value = value
        transform_options!

        @caption = @options.delete(:caption) || @name
        unless @caption.is_a?(String)
          translation_params = @options.delete(:translation_params) || {}
          @caption = @name.first if @name.is_a? Array
          @caption = I18n.translate(@caption, **{:scope => [:data_tables, @t_scope]}.merge(translation_params))
        end
        @params = {}
        @params[:link_to] = @options.delete(:link_to)
        @params[:link_to_content] = @options.delete(:link_to_content)
        @params[:new_tab] = @options.delete(:new_tab)
        @params[:cell_css_class] = @options.delete(:cell_css_class)
        @params[:remote] = @options.delete(:remote)

        option(DataTableFormatters.format_linkto) if @params[:link_to]
        option(DataTableFormatters.format_linkto_content) if @params[:link_to_content]

        @extra_value = @options.delete(:extra_value) || ''
      end

      def transform_options!
        @options[:css_class] = @options.delete(:class).to_s if @options.has_key?(:class)
      end

    end

    class ColumnText < Column
      def transform(_instance, _view_context, text)
        text.to_s
      end

      def to_csv_text(instance, view_context)
        "\"#{get_value(instance, view_context)}\""
      end
    end

    class ColumnAsOf < Column
      def transform(instance, view_context, text)
        instance.as_of(@options[:date]).send(@name) if instance.respond_to? @name
      end
    end

    class ColumnHidden < Column
      def initialize(name, t_scope, options = nil, value = nil)
        super name, t_scope, options, value
        option(DataTableFormatters.format_hidden)
      end

      def downloadable?
        false
      end
    end

    class ColumnHtml < Column
      def initialize(name, t_scope, options = nil, value = nil)
        super name, t_scope, options, value
        option(DataTableFormatters.format_html)
        option(:allow_sorting => false)
      end
    end

    class ColumnEmail < Column
      def initialize(name, t_scope, options = nil, value = nil)
        super name, t_scope, options, value
        option(DataTableFormatters.format_mailto)
      end
    end

    class ColumnTimeago < Column
      def initialize(name, t_scope, options = nil, value = nil)
        super name, t_scope, options, value
        option(DataTableFormatters.format_timeago)
      end

      def transform(instance, view_context, text)
        if text.present? && text.respond_to?(:strftime)
          {:title => text.to_time.iso8601, :datetime => text.getutc.iso8601, :formatted => text.to_time.to_formatted_s(:long) }
        elsif @options[:allow_non_date_values]
          text
        else
          nil
        end
      end

      def to_csv_text(instance, view_context)
        value = get_value(instance, view_context)
        value.strftime(DEFAULT_EXPORT_DATE_TIME_FORMAT)
      end
    end

    class ColumnTimeago2 < ColumnTimeago
      def initialize(name, t_scope, options = nil, value = nil)
        super name, t_scope, options, value
        @options.merge!(DataTableFormatters.format_timeago2)
      end
    end

    class ColumnTimeStamp < ColumnTimeago
      def initialize(name, t_scope, options = nil, value = nil)
        super name, t_scope, options, value
        @options.merge!(DataTableFormatters.format_timestamp)
      end
    end

    class ColumnBool < Column
      def initialize(name, t_scope, options = nil, value = nil)
        super name, t_scope, options, value
        option(self.options.delete(:format){|k| DataTableFormatters.format_bool})
      end
    end

    class ColumnJson < Column
      def initialize(name, t_scope, options = nil, value = nil)
        super name, t_scope, options, value
        option(options.delete(:format))
        option(:allow_sorting => false)
      end

      def text(instance, view_context)
        "\"#{super}\""
      end

      def to_csv_text(instance, view_context)
        # RFC-4180, paragraph "If double-quotes are used to enclose fields,
        # then a double-quote appearing inside a field must be escaped by preceding it with another double quote."
        # https://tools.ietf.org/html/rfc4180
        val = get_value(instance, view_context)
        val.each { |k, v| val[k] = "\"#{v.strip.gsub('"', '""')}\"" if v.is_a? String }
      end
    end

    class ColumnDecimal < Column
      def initialize(name, t_scope, options = nil, value = nil)
        super name, t_scope, options, value
        option(DataTableFormatters.format_fixed)
      end

      def extra_link_formatting(instance, view_context, text)
        if link_to?
          text = {:href => @params[:link_to].call(instance,view_context), :text => view_context.format_number(text, :precision => @options[:precision]), :value => text}
        elsif link_to_content?
          text = {:content => @params[:link_to_content].call(instance,view_context), :text => view_context.format_number(text, :precision => @options[:precision]), :value => text}
        else
          text
        end
        text
      end

      def to_csv_text(instance, view_context)
        value = get_value(instance, view_context)
        # this will produce '123123123.0'
        view_context.number_with_delimiter(value, delimiter: "", separator: ".")
      end
    end

    class ColumnPercentage < Column
      def initialize(name, t_scope, options = nil, value = nil)
        super name, t_scope, options, value
        option(DataTableFormatters.format_percentage)
      end

      def transform(instance, view_context, text)
        view_context.as_percentage(text, :precision => @options.dig(:format, :precision))
      end
    end

    class ColumnInteger < Column
      def initialize(name, t_scope, options = nil, value = nil)
        super name, t_scope, options, value
        option(DataTableFormatters.format_fixed(0))
      end
    end

    class ColumnLookup < Column
      def initialize(*args)
        super
        option(:allow_sorting => false)
      end

      def get_value(instance, view_context)
        if @value
          super
        else
          instance.send(@name.first).send(@name.last)
        end
      end
    end

    class ColumnDate < Column
      def initialize(name, t_scope, options = nil, value = nil)
        super name, t_scope, options, value
        option(DataTableFormatters.format_date)
      end

      def transform(instance, view_context, text)
        safe_parse(text, Date::DATE_FORMATS[:default])
      end

      def to_csv_text(instance, view_context)
        value = get_value(instance, view_context)
        # this will produce '23-JAN-2014'
        safe_parse(value, DEFAULT_EXPORT_DATE_FORMAT)
      end

      private

      def safe_parse(value, format)
        value = Date.parse(value) if value.present? && value.is_a?(String)
        value = value.strftime(format) if value
        value
      end
    end

    class ColumnTime < Column
      def initialize(name, t_scope, options = nil, value = nil)
        super name, t_scope, options, value
        option(DataTableFormatters.format_time)
      end

      def transform(instance, view_context, text)
        if text.is_a? Time
          text = text.to_time
        end
        text.iso8601
      end
    end

    class ColumnIcon < Column
      attr_reader :image, :on_click_fn, :link, :tooltip
      def initialize(name, t_scope, image, options = nil, value = nil)
        super name, t_scope, options, value
        @image = image
        @on_click_fn = @options && @options.delete(:on_click_fn)
        @link = @options && @options.delete(:link)
        @tooltip = @options.delete(:tooltip)
        option(DataTableFormatters.format_icon)
        option(:allow_sorting => false)
      end

      def transform(instance, view_context, text)
        click = on_click_fn.respond_to?(:call) ? on_click_fn.call(instance, view_context) : on_click_fn
        # If a function name is specified, then handle it by calling the function with 'this' as a parameter.
        click = "#{click.to_s.camelize(:lower)}(this)" if click.is_a?(Symbol) || (click.present? && !%w{) ;}.include?(click[-1]))
        # Allow title to be either the field value, a specified tooltip, or the name of the field.
        title = instance.send(name) if instance.respond_to?(name)
        title ||= tooltip || name
        title = I18n.t(title, :scope => :tooltips) if title.is_a?(Symbol)
        {
          :image  => view_context.icon_class(image).join(' '),
          :title  => title,
          :on_click => click,
          :data_options => {
            :href => link.respond_to?(:call) ? link.call(instance, view_context) : link
          }
        }
      end
    end

    class ColumnEnum < Column
      def initialize(name, t_scope, enum_module, options = nil)
        enum_helper = -> { enum_module.list_for_select.map do |enum|
          "SELECT '#{enum[0]}' AS name, #{enum[1]} AS id"
        end.join(' UNION ')
        }

        @sorter = enum_helper
        @filterer = enum_helper
        super name, t_scope, options, proc { |instance| enum_module.display_for(instance.send(name)) }
      end
    end

    # todo - generalize this. Somehow specify which column is super so it can work for all column types?
    class ColumnEnumLabel < ColumnEnum
      def initialize(name, t_scope, enum_module, label_lambda, options = nil)
        super name, t_scope, enum_module, options
        @label_lambda = label_lambda
        option(DataTableFormatters.format_label)
        option(:allow_sorting => false)
      end

      def transform(instance, view_context, text)
        {
          :text  => text,
          :label  => @label_lambda.call(instance)
        }
      end
    end

    class ColumnBuilder

      attr_accessor :columns

      def initialize(t_scope)
        @t_scope = t_scope
        @columns = []
      end

      # Signitures:
      #
      # text :column
      # text :column, :caption => :column2
      # text :column, :caption => :column2, lambda {}
      # text :column, lambda {}

      def text(name, options = nil, value = nil)
        @columns << ColumnText.new(name, @t_scope, options, value)
      end

      def hidden(name, options = nil, value = nil)
        @columns << ColumnHidden.new(name, @t_scope, options, value)
      end

      def lookup(name, options = nil, value = nil)
        @columns << ColumnLookup.new(name, @t_scope, options, value)
      end

      def date(name, options = nil, value = nil)
        @columns << ColumnDate.new(name, @t_scope, options, value)
      end

      def time(name, options = nil, value = nil)
        @columns << ColumnTime.new(name, @t_scope, options, value)
      end

      def timeago(name, options = nil, value = nil)
        @columns << ColumnTimeago.new(name, @t_scope, options, value)
      end

      def timeago2(name, options = nil, value = nil)
        @columns << ColumnTimeago2.new(name, @t_scope, options, value)
      end

      def timestamp(name, options = nil, value = nil)
        @columns << ColumnTimeStamp.new(name, @t_scope, options, value)
      end

      def email(name, options = nil, value = nil)
        @columns << ColumnEmail.new(name, @t_scope, options, value)
      end

      def bool(name, options = nil, value = nil)
        @columns << ColumnBool.new(name, @t_scope, options, value)
      end

      def json(name, options = nil, value = nil)
        @columns << ColumnJson.new(name, @t_scope, options, value)
      end

      def html(name, options = nil, value = nil)
        @columns << ColumnHtml.new(name, @t_scope, options, value)
      end

      def integer(name, options = nil, value = nil)
        @columns << ColumnInteger.new(name, @t_scope, options, value)
      end

      def decimal(name, options = nil, value = nil)
        @columns << ColumnDecimal.new(name, @t_scope, options, value)
      end

      def percentage(name, options = nil, value = nil)
        @columns << ColumnPercentage.new(name, @t_scope, options, value)
      end

      def enum(name, enum_module, options = nil)
        @columns << ColumnEnum.new(name, @t_scope, enum_module, options)
      end

      def enum_label(name, enum_module, label_lambda, options = nil)
        @columns << ColumnEnumLabel.new(name, @t_scope, enum_module, label_lambda, options)
      end

      def icon(name, image, options = nil, value = nil)
        @columns << ColumnIcon.new(name, @t_scope, image, options, value)
      end

      def as_of(name, options = nil, value = nil)
        if options && options.keys.include?(:date)
          date_string = options[:date].is_a?(Date) ? options[:date].to_formatted_s(:db) : options[:date].to_s
          options.merge!(:date => date_string)
        end

        @columns << ColumnAsOf.new(name, @t_scope, options, value)
      end

    end

    class Summary < Column

      attr_reader :type

      def initialize(name, t_scope, table_name, options = nil, value = nil)
        @name = name
        @t_scope = t_scope
        @table_name = table_name
        @options = options || {}
        @value = value
      end

      def transform_options!()
        prefix = "#{@table_name}."
        @name = "#{prefix}#{@name}" unless @name.to_s.include?(prefix)
        @options[:name] = @name
        @options[:column] = "#{prefix}#{@options[:column]}" if @options.has_key?(:column) && !@options[:column].to_s.include?(prefix)
        @options[:show_in_column] = "#{prefix}#{@options[:show_in_column]}" if @options.has_key?(:show_in_column) && !@options[:show_in_column].to_s.include?(prefix)
      end
    end

    class SummarySum < Summary
      def initialize(name, t_scope, table_name, options = nil, value = nil)
        super name, t_scope, table_name, options, value
        option(DataTableFormatters.summary_sum)
        option(:column => name)

        transform_options!
      end
    end

    class SummaryMin < Summary
      def initialize(name, t_scope, table_name, options = nil, value = nil)
        super name, t_scope, table_name, options, value
        option(DataTableFormatters.summary_min)
        option(:column => name)

        transform_options!
      end
    end

    class SummaryMax < Summary
      def initialize(name, t_scope, table_name, options = nil, value = nil)
        super name, t_scope, table_name, options, value
        option(DataTableFormatters.summary_max)
        option(:column => name)

        transform_options!
      end
    end

    class SummaryAvg < Summary
      def initialize(name, t_scope, table_name, options = nil, value = nil)
        super name, t_scope, table_name, options, value
        option(DataTableFormatters.summary_avg)
        option(:column => name)

        transform_options!
      end
    end

    class SummaryCount < Summary
      def initialize(name, t_scope, table_name, options = nil, value = nil)
        super name, t_scope, table_name, options, value
        option(DataTableFormatters.summary_count)
        option(:column => name)

        transform_options!
      end
    end

    class SummaryCustom < Summary
      def initialize(name, column, t_scope, table_name, options = nil, value = nil)
        super name, t_scope, table_name, options, value
        option(DataTableFormatters.summary_custom)
        option(:show_in_column => column, :column => column)

        transform_options!
      end
    end

    class SummaryBuilder < ColumnBuilder

      attr_accessor :summaries

      def initialize(t_scope, table_name)
        @t_scope = t_scope
        @summaries = []
        @table_name = table_name
      end

      # Signitures:
      #
      # sum    :column
      # min    :column
      # max    :column
      # avg    :column
      # count  :column

      # TODO:: Fix custom summary height issue
      # custom :column

      def sum(name, options = nil, value = nil)
        @summaries << SummarySum.new(name, @t_scope, @table_name, options, value)
      end

      def min(name, options = nil, value = nil)
        @summaries << SummaryMin.new(name, @t_scope, @table_name, options, value)
      end

      def max(name, options = nil, value = nil)
        @summaries << SummaryMax.new(name, @t_scope, @table_name, options, value)
      end

      def avg(name, options = nil, value = nil)
        @summaries << SummaryAvg.new(name, @t_scope, @table_name, options, value)
      end

      def count(name, options = nil, value = nil)
        @summaries << SummaryCount.new(name, @t_scope, @table_name, options, value)
      end

      def custom(name, column, options = nil, value = nil)
        @summaries << SummaryCustom.new(name, column, @t_scope, @table_name, options, value)
      end
    end

  end
end
