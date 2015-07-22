(function() {
  ($('#cancel_link')).click(function(event) {
    event.preventDefault();
    ($('.no-objects-found')).show();
    ($('#new_image_link')).show();
    return ($('#images')).html('');
  });

}).call(this);
