function ItemResize(dataGrid, height, width) {
  if (!(height || width)){
    var screenHeight = $('.navbar-fixed-bottom').offset().top - $('#' + dataGrid.attr('id') + '-holder').offset().top;
    var footerHeight = $('footer').height();
    dataGrid.height( screenHeight - footerHeight );
  } else {
    var dgMargin = dataGrid.outerHeight(true)-dataGrid.outerHeight();
    dataGrid.height( parseInt(height)-dgMargin );
  }
}

function genericCustomSummary(opt, name, value) {
  if (opt.name === name && opt.summaryProcess === "start") {
    opt.totalValue = value;
  }
}

function getDataGrid(container_id) {
  return $(container_id).dxDataGrid('instance');
}

function getSelectedRowKeys(container_id) {
  var dataGrid = getDataGrid(container_id);
  return dataGrid.getSelectedRowKeys();
}

function getSelectedRowsAsParams(container_id, filter_form_id = '') {
  var keys = getSelectedRowKeys("#" + container_id);

  var params = {};

  if (keys.length > 0) {
    params = {
      ids: keys,
      container_id: container_id
    };
  }
  else {
    // FIXME: this isn't a specific enough jQuery selector when filter_form_id == "form"
    //   since if there is more than one form, it will include them all
    var search_params = $("" + filter_form_id + ".auto-submit").serializeArray();
    var data = {
      name: 'container_id',
      value: container_id
    };
    search_params.push(data);
    params = search_params;
  }

  return params;
}

function submit_bulk_action(caller, container_id, fn_callback, confirm_message_selector) {
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

function download_file(event, type, container_id, allow_large_files) {
  container_id = getSelectedContainerId(container_id);

  /* This links to the -xls_download and -csv_download buttons, depending on type */
  var file_location = $('#btn_' + type + '_download_' + container_id).attr('href');
  /* This check is here in case there is no download button found */
  if (file_location && file_location.length > 0) {
    window.location = file_location;
    var total_count = getDataGrid('#' + container_id).totalCount();

    if(total_count > 999  && allow_large_files) {
      $('#' + container_id + '-download_modal').modal({backdrop: false}).modal('show');
    }
  }

  if (event) {
    event.preventDefault();
  }

  return false;
}

function show_column_chooser(container_id) {
  var dataGrid = getDataGrid('#' + getSelectedContainerId(container_id));
  dataGrid.showColumnChooser();
}

function refresh_grid(container_id) {
  var dataGrid = getDataGrid('#' + getSelectedContainerId(container_id));
  dataGrid.refresh();
}

function initiate_grid_reset(container_id) {
  container_id = getSelectedContainerId(container_id);
  var $dataGrid = $('#' + container_id);

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

function getSelectedContainerId(default_container_id) {
  var is_master_detail = JSON.parse($('#is_master_detail').val().toLowerCase());
  return (is_master_detail === true) ? $('#selected_container_id').val() : default_container_id;
}