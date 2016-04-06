$(function() {
  $select = $('.js-canton-selector');
  $select.select2();
  $select.on('change', function () {
    window.location = $(this).val();
  });
});
