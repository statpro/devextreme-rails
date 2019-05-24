function ItemResize(dataGrid, height, width) {
  if (!(height || width)){
    let screenHeight = $('.navbar-fixed-bottom').offset().top - $('#' + dataGrid.attr('id') + '-holder').offset().top;
    let footerHeight = $('footer').height();
    window.setGridHolderHeight = screenHeight - footerHeight;
    dataGrid.height( screenHeight - footerHeight );
  } else {
    let dgMargin = dataGrid.outerHeight(true)-dataGrid.outerHeight();
    window.setGridHolderHeight = parseInt(height)-dgMargin;
    dataGrid.height( parseInt(height)-dgMargin );
  }
}