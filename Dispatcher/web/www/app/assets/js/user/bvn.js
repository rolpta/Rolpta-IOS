$(function() {

  populate('#form', {
    "bvn": user_data.bvn,
    "address": user_data.address
  }, 0);



  $('#form').on('submit', function() {

    fdata = $(this).serializeJson();

    fetch_data(
      'profile/update/bvn', fdata,
      function(response) {
          authorize(response);
          location.reload();
      });

    return false;
  });



});
