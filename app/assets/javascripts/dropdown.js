(function() {
  var ready;

  ready = function() {
    $('.dropdown').on('click', '.dropdown-togle', function() {
      var dropdown = this.closest('.dropdown');
      $(dropdown).find('.dropdown-content').toggleClass( "active" );
    });
  };

  $(document).ready(ready);
}).call(this);
