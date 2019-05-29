function ItemResize(dataGrid, height, width) {
  if (!(height || width)){
    var screenHeight = $('.navbar-fixed-bottom').offset().top - $('#' + dataGrid.attr('id') + '-holder').offset().top;
    var footerHeight = $('footer').height();
    window.setGridHolderHeight = screenHeight - footerHeight;
    dataGrid.height( screenHeight - footerHeight );
  } else {
    var dgMargin = dataGrid.outerHeight(true)-dataGrid.outerHeight();
    window.setGridHolderHeight = parseInt(height)-dgMargin;
    dataGrid.height( parseInt(height)-dgMargin );
  }
}
function genericCustomSummary(opt, name, value) {
  if (opt.name === name && opt.summaryProcess === "start") {
    opt.totalValue = value;
  }
}