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