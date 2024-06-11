/**
 * DEPRECATED
 * @param dataGrid
 * @param height E.g 50%, 50vh, 500px
 * @param width E.g 60%, 60vw, 600px
 * @constructor
 */
 window.ItemResize = function(dataGrid, height, width) {
  if (!(height || width)){
    var screenHeight = $('.navbar-fixed-bottom').offset().top - $('#' + dataGrid.attr('id') + '-holder').offset().top;
    var footerHeight = $('footer').height();
    dataGrid.height( screenHeight - footerHeight );
  } else {
    var dgMargin = dataGrid.outerHeight(true)-dataGrid.outerHeight();
    // Sets the height in its orignal value E.g 50%, 50vh, 500px
    dataGrid.height(height);
    // Gets the height in pixels then subtracts the dgMargin
    dataGrid.height( parseInt(dataGrid.height())-dgMargin );
  }
}

window.genericCustomSummary = function(opt, name, value) {
  if (opt.name === name && opt.summaryProcess === "start") {
    opt.totalValue = value;
  }
}

window.getDataGrid = function(container_id) {
  return $(container_id).dxDataGrid('instance');
}

window.getSelectedRowKeys = function(container_id) {
  var dataGrid = getDataGrid(container_id);
  return dataGrid.getSelectedRowKeys();
}

window.getSelectedRowsAsParams = function(container_id, filter_form_id) {
  var keys = getSelectedRowKeys("#" + container_id);

  var params = {};

  if (keys.length > 0) {
    params = {
      ids: keys,
      container_id: container_id
    };
  }
  else {
    // Only want to default filter_form_ito blank string if it is undefined or null, not other falsy values.
    if (filter_form_id === undefined || filter_form_id == null) {
      filter_form_id = ''
    }
    // FIXME: this isn't a specific enough jQuery selector when filter_form_id == "form"
    //   since if there is more than one form, it will include them all
    var search_params = $("" + filter_form_id  + ".auto-submit").serializeArray();
    var data = {
      name: 'container_id',
      value: container_id
    };
    search_params.push(data);
    params = search_params;
  }

  return params;
}

window.submit_bulk_action = function(caller, container_id, fn_callback, confirm_message_selector) {
  var $caller = $(caller);
  var dataGrid = getDataGrid('#' + container_id);
  var keys = dataGrid.getSelectedRowKeys();
  var value_count = keys.length > 0 ? keys.length : dataGrid.totalCount();

  if (fn_callback) {
    fn_callback(keys);
  }

  var confirmation_message = $caller.data('confirmMessage').replace('{0}', value_count);
  if (confirm_message_selector) {
    $(confirm_message_selector).text(confirmation_message);
  }
  else {
    $caller.data('confirm', confirmation_message);
  }
}

window.show_column_chooser = function(container_id) {
  var dataGrid = getDataGrid('#' + getSelectedContainerId(container_id));
  dataGrid && dataGrid.showColumnChooser();
}

window.refresh_grid = function(container_id) {
  var dataGrid = getDataGrid('#' + getSelectedContainerId(container_id));
  dataGrid && dataGrid.refresh();
}

window.initiate_grid_reset = function(container_id) {
  container_id = getSelectedContainerId(container_id);
  var $dataGrid = $('#' + container_id);

  if ($dataGrid.length === 0) return;

  alertify.confirm($('#btn_grid_reset_' + container_id).data('reset-layout-message'), function(e){
    if(e){
      $.ajax({
        url: $dataGrid.data('reset_layout_url'),
        type: 'PUT',
        dataType: 'script',
        data: {
          container_id: container_id,
          user_grid_layout: {
            controller_class_name: $dataGrid.data('controller_name'),
            action_name: $dataGrid.data('action_name'),
            grid_name: $dataGrid.data('grid_name')
          }
        }
      });
    }
  });
}

window.getSelectedContainerId = function(default_container_id) {
  var is_master_detail = JSON.parse($('#is_master_detail').val().toLowerCase());
  return (is_master_detail === true) ? $('#selected_container_id').val() : default_container_id;
}

window.getVisibleButtonFor = function(btnIdSelectorPrefix, currentContainerId) {
  let is_master_detail = JSON.parse($('#is_master_detail').val().toLowerCase());
  return (is_master_detail === true) ? $(`#${btnIdSelectorPrefix}_level_1_grid`) : $(`#${btnIdSelectorPrefix}_${currentContainerId}`);
}

window.hide_download_modal = function(event, container_id) {
  event.preventDefault();

  // Hide the modal
  var modal_selector = '#' + container_id + '-download_modal';
  $(modal_selector).modal('hide');

  // Run the callback if it exists
  if (typeof hide_download_modal_callback == 'function') {
    hide_download_modal_callback(event, container_id);
  }
}

window.show_download_modal = function(container_id) {
  container_id = getSelectedContainerId(container_id);

  // Show the modal
  var modal_selector = '#' + container_id + '-download_modal';
  $(modal_selector).modal('show');
}