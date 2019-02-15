(function($){
  var methods = ["toggleClass"],
    i = methods.length;

  $.map(methods, function(method){
    // Store the original handler
    var originalMethod = $.fn[ method ];

    $.fn[ method ] = function(){

      if(this.length > 0){
        // Execute the original hanlder.
        var oldClass = this[0].className;
        var result = originalMethod.apply( this, arguments );
        var newClass = this[0].className;


        // trigger a custom event
        this.trigger(method, [oldClass, newClass]);

        // return the original result
        return result;
      }
      else{
        originalMethod.apply( this, arguments );

        // return the original result
        return result;
      }
    };
  });

  $.fn.exists = function () {
    return this.length !== 0;
  }
}(jQuery));

// the actual extension to find by data attribute that was set using jQuery.data(..) setter
$.fn.filterByData = function (prop, val) {
  var $self = this;
  if (typeof val === 'undefined') {
    return $self.filter(
      function () {
        return typeof $(this).data(prop) !== 'undefined';
      }
    );
  }
  return $self.filter(
    function () {
      return $(this).data(prop) == val;
    });
};

$.extend( {
  findFirst: function( elems, validateCb ){
    var i;
    for( i=0 ; i < elems.length ; ++i ) {
      if( validateCb( elems[i], i ) )
        return elems[i];
    }
    return undefined;
  }
} );
