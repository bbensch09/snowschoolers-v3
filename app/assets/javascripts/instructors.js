$(document).ready(function(){
    applyFormListener();
    selectAllLevelsListener();
    console.log("capturing form entries");
});

var applyFormListener = function() {
  // listen for and capture email
    $('#instructor_username').change(function(e){
      e.preventDefault();
      var first_name = $('#instructor_first_name').val();
      var last_name = $('#instructor_last_name').val();
      var email = $('#instructor_username').val();
      console.log("A user has entered their "+first_name+" "+last_name+" as their name and "+email+" as their email in the application form.");

      var request = $.ajax({
            url: "/notify_admin",
            type: "POST",
            data: {first_name: first_name, last_name: last_name, email: email}
      });
      request.done(function(data){
        console.log(data);
        console.log("applicant email logged via ajax");
      });

  });
    // listen for and capture ph number
    $('#instructor_phone_number').change(function(e){
      e.preventDefault();
      var first_name = $('#instructor_first_name').val();
      var last_name = $('#instructor_last_name').val();
      var email = $('#instructor_username').val();
      var phone_number = $('#instructor_phone_number').val();
      console.log("A user has entered their phone_number.");

      var request = $.ajax({
            url: "/notify_admin",
            type: "POST",
            data: {first_name: first_name, last_name: last_name, email: email, phone_number: phone_number}
      });
      request.done(function(data){
        console.log(data);
        console.log("applicant has entered email & phone");
      });
    });
  }






  var selectAllLevelsListener = function() {
    $('#selectAllSkiLevels').click(function() {
    if (this.checked) {
       $('.ski-checkbox').each(function() {
           this.checked = true;
       });
    } else {
      $('.ski-checkbox').each(function() {
           this.checked = false;
       });
    }
    });

    $('#selectAllSnowboardLevels').click(function() {
    if (this.checked) {
       $('.snowboard-checkbox').each(function() {
           this.checked = true;
       });
    } else {
      $('.snowboard-checkbox').each(function() {
           this.checked = false;
       });
    }
    });
  }
