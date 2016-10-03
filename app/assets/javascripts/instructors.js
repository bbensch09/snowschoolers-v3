$(document).ready(function(){
    applyFormListener();
    console.log("listening for form changes");
});

var applyFormListener = function() {
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
        console.log("successfully captured the email for "+data.email+" via ajax");
      });

  });
  }
