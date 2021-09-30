function showModal(event){
  target = (window.event) ? window.event.srcElement /* for IE */ : event.target;
  var getModalTitle = $(target).attr("modal-title");
  var getModalBodyContent = $(target).attr("modal-data");
  var getModalSize = $(target).attr("modal-size");

  var info = $('<div />')
    .addClass('modal hide modal-position')
      .addClass(getModalSize)
    .attr('id', 'infoModal')
    .attr('tabindex', -1 )
    .appendTo($("#dialog_container"));

  var modal_header = $('<div />')
    .addClass('modal-header grab-hold')
    .appendTo(info);

  var close = $('<button />')
    .addClass('close')
    .attr('data-dismiss', 'modal')
    .html('&times;')
    .appendTo(modal_header);

  var h3 = $('<h3 />').appendTo(modal_header);

  var body = $('<div />')
    .addClass('modal-body')
    .appendTo(info);

  $(".modal-header").find('h3').html(getModalTitle);
  $('.modal-body').html(getModalBodyContent);
  $("#infoModal").on('shown', function () {
    $('.modal-backdrop').css({ opacity: 0 });
    })
    .modal()
    .draggable({ handle: ".modal-header" });
}

var column_template_label = function(container, options){
  if (options.value){
    $('<span />')
      .addClass("label label-" + options.value.label)
      .html(options.value.text)
      .appendTo(container);
  }
};

var column_template_label_with_modal = function(container, options){
  if (options.value && options.value.label && options.value.text){

    var info = $(options.value.modal_value);

    if (info.length == 0) {
      info = '<span />'
    }

    var label = $('<span />')
      .addClass("label label-" + options.value.label)
      .attr("modal-title", "Options")
      .attr("modal-size", "modal-xlarge")
      .attr("modal-data", function() {
        return $(info).html().toString();
      })
      .attr("onClick", "showModal(event)")
      .html(options.value.text)
      .appendTo(container);
  }
};

var base_column_template_timeago = function(css_class, container, options) {
  if (options.value) {
    var abbr = $('<abbr />');
    abbr.addClass(css_class);
    if (typeof options.value === 'string' || options.value instanceof String) {
      abbr.text(options.value);
    } else {
      abbr
        .attr('title', options.value.title)
        .attr('datetime', options.value.datetime)
        .text(options.value.formatted)
        .data('datetime', options.value.datetime);
    }
    abbr.appendTo(container);
  }
};

var column_template_timeago = function(container, options){
  base_column_template_timeago('timeago', container, options);
};

var column_template_timeago2 = function(container, options){
  base_column_template_timeago('timeago2', container, options);
};

var column_template_timestamp = function(container, options){
  if (options.value){
    var abbr = $('<abbr />')
      .addClass('timestamp')
      .data('datetime', options.value.datetime)
      .appendTo(container);
  }
};

var column_template_checkbox = function(container, options){
  if (options.value){
    $('<i />')
      .addClass("fa fa-check-square-o")
      .appendTo(container);
  }
};

var column_template_icon = function(container, options){
  if (options.value.title && options.value.title.length > 0){
    var $icon = $('<i />')
      .attr('rel', 'tooltip')
      .attr('title', options.value.title)
      .addClass(options.value.image);

    if (options.value.on_click) {
      $icon.attr('onClick', options.value.on_click);
      $icon.hover(function() {
        $(this).css('cursor', 'pointer');
      });
    }

    if (options.value.data_options) {
      for(var i in options.value.data_options) {
        $icon.data(i, options.value.data_options[i])
      }
    }

    $icon.appendTo(container);
  }
};

var column_template_mailto = function(container, options){
  if (options.value){
    var link = $('<a />')
      .attr('href', "mailto:"+options.value)
      .text(options.value)
      .appendTo(container);
  }
};

var column_template_linkto = function(container, options){
  if (options.value){
    var text = options.value.text;

    if (options.column.format != undefined && options.column.format.type == "fixedPoint") {
      var value = options.value.value;

      if (!isNaN(value)) {
        text = Globalize.format(value, "n" + options.column.format.precision);
      }
    }

    var link = $('<a />')
      .attr('href', options.value.href)
      .attr('data-remote', options.value.data_remote )
      .text(text)
      .appendTo(container);

    if (options.value.target) {
      link.attr('target', options.value.target )
    }
  }
};

var column_template_cell_content = function(container, options){
  if (options.value){
    container.addClass(options.value.cell_css_class).text(safe_text(options.value.text));

    if (!options.value.text && !options.value.ignore_nulls && options.value.cell_css_class != "") {
      var color = $(container).css('background-color');
      var new_cell_background_color_class = (color == 'transparent' ? "dx-cell-error-odd" : "dx-cell-error-even");

      container.addClass(new_cell_background_color_class);
    }
  }
};

var column_template_linkto_content = function(container, options){
  if (options.value && options.value.content){
    var href = $.parseHTML(options.value.content);

    if (options.column.format != undefined && options.column.format.type == "fixedPoint") {
      var value = options.value.value;

      if (!isNaN(value)) {
        text = Globalize.format(value, "n" + options.column.format.precision);

        // 3 == Text
        // see https://www.w3schools.com/jsref/prop_node_nodetype.asp
        if (href[0].nodeType == 3) {
          href[0] = text;
        } else {
          $(href[0]).text(text);
        }
      }
    }

    container.append(href)
  }
};

var column_template_background_task_info = function(container, options){
  if (options.value && options.value.length > 0){

    var info = $('<div />');
    var ul = $('<ul />').appendTo(info);

    for(var i = 0; i < options.value.length; i++){
      var li = $('<li />').text(options.value[i]).appendTo(ul);
	}

  var label = $('<span />')
    .addClass("label label-info")
    .attr("modal-title", "Calculation Info")
    .attr("type", "button")
    .attr("modal-data", function() {
	    return $(info).html().toString();
	  })
    .attr("onClick", "showModal(event)")
    .text("detail")
    .appendTo(container);
  }
};

var column_template_progress_bar = function(container, options){
  if (options.value && options.value.width > 0){
    var progress = $('<div />')
      .addClass('progress no-bottom-margin')
      .appendTo(container);

    var bar = $('<div />')
      .addClass('bar as_tooltip')
      .addClass(options.value.style)
      .attr('style', 'width: ' + options.value.width + '%')
      .attr('title', options.value.width + '%')
      .appendTo(progress);
  }
};

var column_template_background_task_descriptor = function(container, options){
  if (JSON.stringify(options.value) == "{}")
    return;

  var div = $('<div />')
    .appendTo(container);

  var table = $('<table />')
    .addClass('table table-condensed')
    .attr('style', 'margin-bottom: 0px')
    .appendTo(div);

  header = $('<tr />').appendTo(table);
  data = $('<tr />').appendTo(table);

  cols = 0;
  for (var key in options.value)
    cols++;

  width = 100 / cols;

  for (var key in options.value) {
    $('<th/>')
      .text(key)
      .attr('style', 'border-top: 0px; padding-top: 0px; width: ' + width + '%' )
      .appendTo(header);
    $('<td />')
      .text(options.value[key])
      .appendTo(data);
  }
};

var column_template_background_task_args = function(container, options){
  if (options.value){

    var info = $('<div />');

    var pre = $('<pre />')
      .addClass('json-highlight')
      .html(syntaxHighlight(JSON.stringify(options.value, undefined, 4)))
      .appendTo(info);

    var label = $('<span />')
      .addClass("label label-info")
      .attr("modal-title", "Options")
      .attr("type", "button")
      .attr("modal-data", function() {
        return $(info).html().toString();
      })
      .attr("onClick", "showModal(event)")
      .text("detail")
      .appendTo(container);
  }
};

var column_template_html = function(container, options){
    if (options.value){

        var info = $('<div />').html(options.value);

        var label = $('<span />')
            .addClass("label label-info")
            .attr("modal-title", "Options")
            .attr("modal-size", "modal-xlarge")
            .attr("modal-data", function() {
                return $(info).html().toString();
            })
            .attr("onClick", "showModal(event)")
            .text("detail")
            .appendTo(container);
    }
};

var column_template_actions = function(container, options){
  var actions = jQuery.parseJSON(options.value);

  if (actions.length > 0) {

    var group = $('<div />')
      .addClass('btn-group grid-btn-group dropdown dropdown-overflow')
      .on("toggleClass", function(e, oldClass, newClass){
        handleDropdownOpenPosition(e, oldClass, newClass);
      })
      .appendTo(container);

    var button = $('<a />')
      .attr('href', actions[0].url)
      .attr('title', actions[0].title)
      .addClass(actions[0].css_class + ' btn btn-micro as_tooltip grid-btn')
      .appendTo(group);

    set_data_properties(button, actions[0].data);

    $('<i />')
      .addClass(icon_class(actions[0].image))
      .appendTo(button);

    var actions_link = $('<a />')
      .addClass('btn btn-micro as_tooltip dropdown-toggle grid-btn')
      .attr('data-toggle', 'dropdown')
      .attr('href', '#')
      .appendTo(group);

    $('<i />')
      .addClass(icon_class('caret-down'))
      .appendTo(actions_link);

    if (actions.length == 1) {
      actions_link.addClass('disabled');
    }

    // only add dropdown menu items if there are more than 1 action
    if (actions.length > 1) {

      var dropdown = $('<ul />')
        .addClass('dropdown-menu')
        .appendTo(group);

      for (var i = 1; i < actions.length; i++) {
        var list_item = $('<li />').appendTo(dropdown);

        var link = $('<a />')
          .addClass(actions[i].css_class + ' grid-btn-actions')
          .attr('href', actions[i].url)
          .appendTo(list_item);

        if (actions[i].rel) {
          link.attr('rel', actions[i].rel);
        }

        set_data_properties(link, actions[i].data);

        $('<i />').addClass(actions[i].image).appendTo(link);

        link.append(actions[i].title);
      }
    }
  }
};

function set_data_properties(link, action_data) {
  for (var key in action_data) {
    if (action_data.hasOwnProperty(key)) {
      link.attr('data-' + key, action_data[key]);
    }
  }
}

function syntaxHighlight(json) {
  json = json.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  return json.replace(/("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?|\b(true|false|null)\b|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)/g, function (match) {
    var cls = 'number';
    if (/^"/.test(match)) {
      if (/:$/.test(match)) {
        cls = 'key';
      } else {
        cls = 'string';
      }
    } else if (/true|false/.test(match)) {
      cls = 'boolean';
    } else if (/null/.test(match)) {
      cls = 'null';
    }
    return '<span class="' + cls + '">' + match + '</span>';
  });
}

var column_template_exports_portfolio_filters = function(container, options, popup_header) {
  if (options.value && options.value.length > 0) {
    var filters = JSON.parse(options.value);
    var groups_present = filters.groups && filters.groups.length > 0;
    var workflow_groups_present = filters.workflow_groups && filters.workflow_groups.length > 0;
    var entities_present = filters.entities && filters.entities.length > 0;
    var info = $('<div />');

	// Only render if groups_present or workflow_groups_present or entities_present
	if (groups_present || workflow_groups_present || entities_present) {
	  // Only render if groups_present
    if (groups_present) {
      var groups_info = $('<strong />').html($('<i />')
        .addClass('fa fa-angle-right')
        .text(' ' + filters.groups_text))
        .attr('style', 'color: black;')
        .appendTo(info);
	    var groups_ul = $('<ul />')
        .attr('style', 'color: black;')
        .appendTo(groups_info);

      // Loop through groups and build list
      var group_filters = filters.groups;
      for (var i = 0; i < group_filters.length; i++) {
        var li = $('<li />')
          .attr('style', 'color: black;')
          .text(group_filters[i])
          .appendTo(groups_ul);
      }
	  }

    // Only render if workflow_groups
    if (workflow_groups_present) {
      var workflow_groups_info = $('<strong />').html($('<i />')
        .addClass('fa fa-angle-right')
        .text(' ' + filters.workflow_groups_text))
        .attr('style', 'color: black;')
        .appendTo(info);
      var workflow_groups_ul = $('<ul />')
        .attr('style', 'color: black;')
        .appendTo(workflow_groups_info);

      // Loop through workflow_groups and build list
      var workflow_groups_filters = filters.workflow_groups;
      for (var i = 0; i < workflow_groups_filters.length; i++) {
        var li = $('<li />')
          .attr('style', 'color: black;')
          .text(workflow_groups_filters[i])
          .appendTo(workflow_groups_ul);
      }
    }

	  // Only render if entities_present
    if (entities_present) {
		  var entities_info = $('<strong />')
        .html($('<i />')
        .addClass('fa fa-angle-right')
        .text(' ' + filters.entities_text)
		  )
		  .attr('style', 'color: black;')
		  .appendTo(info);

      var entities_ul = $('<ul />')
        .attr('style', 'color: black;')
        .appendTo(entities_info);

		  // Loop through entities and build list
		  var entities_filters = filters.entities
		  for (var i = 0; i < entities_filters.length; i++) {
		    var li = $('<li />')
        .text(entities_filters[i])
        .attr('style', 'color: black;')
        .appendTo(entities_ul);
		  }
	  }

	  var label = $('<span />')
      .addClass("label label-info")
      .text(filters.cell_text)
      .attr("modal-title", filters.popup_header)
      .attr("type", "button")
      .attr("modal-data", function () {
        return $(info).html().toString();
		  })
		  .attr("onClick", "event.stopPropagation(); showModal(event);")
		  .appendTo(container);
    }
  }
};

var column_template_popup = function(container, options, popup_header) {
  if (options.value && options.value.length > 0) {
    var filters = JSON.parse(options.value);
    var info = $('<div />');

    var filter_present = false
    // Loop through fields and build rows
    var rows = filters.rows
    for (var i = 0; i < rows.length; i++) {
      var values = rows[i].values;

      if (!Array.isArray(values)) {
        if(values == null)
          values = [];
        else
          values = [values];
      }

      // Only render if present
      if (values.length > 0) {
        var fields_info = $('<strong />')
          .html($('<i />')
            .addClass('fa fa-angle-right')
            .text(' ' + rows[i].text)
          )
          .attr('style', 'color: black;')
          .appendTo(info);

        var fields_ul = $('<ul />')
          .attr('style', 'color: black;')
          .appendTo(fields_info);

        // Loop through array and build list
        for (var j = 0; j < values.length; j++) {
          filter_present = true
          $('<li />')
            .attr('style', 'color: black;')
            .text(values[j])
            .appendTo(fields_ul);
        }
      }
    }

    if (filter_present) {
      $('<span />')
        .addClass("label label-info")
        .text(filters.cell_text)
        .attr("modal-title", filters.popup_header)
        .attr("type", "button")
        .attr("modal-data", function () {
          return $(info).html().toString();
        })
        .attr("onClick", "event.stopPropagation(); showModal(event);")
        .appendTo(container);
    }
  }
};

var column_header_template_precision = function(itemData, itemIndex, itemElement) {

  itemElement.append(
    $('<form/>').append(
      $('<div class="input-prepend input-append"/>')
        .addClass('input-prepend input-append')
        .css('margin-bottom', 0)
        .append(
          $('<span>')
            .addClass('add-on')
            .text('Precision')
            .css('height', 'initial')
        )
        .append(
          $('<input>')
            .addClass('span1 right number spinner')
            .attr('id', 'precisionInput')
            .attr('type', 'number')
            .attr('min', 0)
            .attr('max', 100)
            .attr('step', 1)
            .attr('value', itemData.column.format.precision)
            .attr('required', 'required')
            .css('height', 'initial')
        )
        .append(
          $('<input>')
            .addClass('btn')
            .attr('id', 'precisionButton')
            .val('Set')
            .attr('type', 'submit')
            .on('click', {container_id: itemData.container_id, columnDataField: itemData.column.dataField}, handlePrecisionUpdate)
        )
    )
  )
};

var hide_grouping_column_name_group_cell_template = function(cellElement, cell){
  cellElement.text(cell.displayValue);
};

function handlePrecisionUpdate(e){
  var grid = $('#' + e.data.container_id).dxDataGrid('instance');
  var new_precision = parseInt($('#precisionInput').val(), 10);
  var min_precision = parseInt($('#precisionInput').attr('min'), 10);
  var max_precision = parseInt($('#precisionInput').attr('max'), 10);

  if (!isNaN(new_precision) && new_precision >= min_precision && new_precision <= max_precision) {
    grid.columnOption(e.data.columnDataField, 'format.precision', new_precision);

    // This is a hack for the context menu not to close when your input value is invalid
    // See /app/views/data_tables/_data_table.html.haml:209
    $('#precisionButton').attr('type', 'button');
  }
}

function handleDropdownOpenPosition(e, oldClass, newClass){
  if(oldClass == 'btn-group grid-btn-group dropdown dropdown-overflow' && newClass == 'btn-group grid-btn-group dropdown dropdown-overflow open'){
    var show_dropup = findIntersectors($(e.currentTarget).find('.dropdown-menu'), $(e.target).closest('.dx-datagrid-rowsview')).length > 0;

    if(show_dropup){
      $(e.currentTarget).addClass("dropup");
    }
  }

  if(newClass == 'btn-group grid-btn-group dropdown dropdown-overflow' && oldClass == 'btn-group grid-btn-group dropdown dropdown-overflow dropdown-overflow open'){
    $(e.currentTarget).removeClass('dropup');
  }
}

function handlePopoverPosition(e, popup_header, info){
  var popover_options = {
    html: true,
    title: popup_header,
    placement: 'bottom',
    container: $(e.target).parent(),
    content: function() {
      return $(info).html();
    }
  }

  // Show popover
  var pop_over = $(e.target).popover(popover_options);
  $(e.target).popover('show');

  var show_on_top = findIntersectors($('.popover.bottom'), $(e.target).closest('.dx-datagrid-rowsview')).length > 0;

  if(show_on_top){
    $('.popover.bottom').removeClass('bottom in').addClass('top in');
    $(e.target).popover('destroy');

    popover_options.placement = 'top';
    var pop_over = $(e.target).popover(popover_options);
    $(e.target).popover('show');
  }

  return true;
}

function findIntersectors(targetSelector, intersectorsSelector) {
  var intersectors = [];
  var $target = $(targetSelector);
  var tAxis = $target.offset();

  if(tAxis){
    var t_x = [tAxis.left, tAxis.left + $target.outerWidth()];
    var t_y = [tAxis.top, tAxis.top + $target.outerHeight()];

    $(intersectorsSelector).each(function() {
      var $this = $(this);
      var thisPos = $this.offset();
      var i_x = [thisPos.left, thisPos.left + $this.outerWidth()];
      var i_y = [thisPos.top, thisPos.top + $this.outerHeight()];

      // if bottom of target is lower than intersector
      if ( t_y[1] > i_y[1]) {
        intersectors.push($this);
      }
    });
  }

  return intersectors;
}

function safe_text(value) {
  if(value == null)
    return "";
  else
    return value;
}
