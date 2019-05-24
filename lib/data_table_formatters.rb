module Devextreme
  module DataTableFormatters

    class << self

      def format_percentage(precision = 3)
        {:format => 'fixedPoint', :precision => precision, :css_class => 'numeric-column', :alignment => 'right'}
      end

      def format_fixed(precision = 2)
        {:format => 'fixedPoint', :precision => precision, :css_class => 'numeric-column', :alignment => 'right'}
      end

      def format_date(format = 'MMM dd, yyyy')
        {:format => format, :data_type => 'date', :css_class => 'date-column'}
      end

      def format_time(format = 'shortTime')
        {:format => format, :data_type => 'date', :css_class => 'time-column'}
      end

      def format_timeago
        {:data_type => 'date', :cell_template => :column_template_timeago, :css_class => 'time-ago-column'}.merge(grouping_disable)
      end

      def format_timestamp
        {:data_type => 'date', :cell_template => :column_template_timestamp, :css_class => 'time-ago-column'}.merge(grouping_disable)
      end

      def format_hidden
        {:data_type => 'string',:allow_grouping => false, :visible => false , :css_class => 'hidden'}.merge(grouping_disable)
      end

      def format_icon
        {:alignment => 'center', :cell_template => :column_template_icon}.merge(grouping_disable)
      end

      def format_mailto
        {:data_type => 'string', :cell_template => :column_template_mailto}.merge(grouping_disable)
      end

      def format_linkto
        {:data_type => 'string', :cell_template => :column_template_linkto}.merge(grouping_disable)
      end

      def format_linkto_content
        {:data_type => 'string', :cell_template => :column_template_linkto_content}.merge(grouping_disable)
      end

      def format_cell_content
        {:data_type => 'string', :cell_template => :column_template_cell_content}.merge(grouping_disable)
      end

      def format_bool
        {:data_type => 'boolean', :show_editor_always => false, :false_text => 'No', :true_text => 'Yes', :css_class => 'boolean-column'}.merge(filter_disable)
      end

      def format_background_task_info
        {:cell_template => :column_template_background_task_info}.merge(grouping_disable)
      end

      def format_background_task_args
        {:cell_template => :column_template_background_task_args}.merge(grouping_disable)
      end

      def format_to_html
        {:cell_template => :column_template_html}.merge(grouping_disable)
      end

      def format_background_task_descriptor
        {:cell_template => :column_template_background_task_descriptor}.merge(grouping_disable)
      end

      def format_progress_bar
        {:cell_template => :column_template_progress_bar}.merge(grouping_disable)
      end

      def column_template_exports_portfolio_filters
        {:cell_template => :column_template_exports_portfolio_filters}.merge(grouping_disable)
      end

      def format_checkbox
        self.format_bool.merge(:cell_template => :column_template_checkbox)
      end

      def format_html
        { :encode_html => false }
      end

      def format_label
        {:cell_template => :column_template_label, :alignment => 'center'}
      end

      def format_label_with_modal
        {:cell_template => :column_template_label_with_modal}
      end

      def filter_disable
        {:allow_filtering => false}
      end

      def sort_disable
        {:allow_sorting => false}
      end

      def filter_sort_disable
        filter_disable.merge(sort_disable)
      end

      def grouping_disable
        {:allow_grouping => false}
      end

      def summary_sum(precision = 2)
        {:summaryType => 'sum'}
      end

      def summary_min(precision = 2)
        {:summaryType => 'min'}
      end

      def summary_max(precision = 2)
        {:summaryType => 'max'}
      end

      def summary_avg(precision = 2)
        {:summaryType => 'avg'}
      end

      def summary_count
        {:summaryType => 'count'}
      end

      def summary_custom
        {:summaryType => 'custom'}
      end

    end

  end
end
