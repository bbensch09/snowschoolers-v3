console.log("Custom validation JS loaded");

$(document).ready(function(){


    $('.continue-to-payment-btn').click(function(e){
          slot = $('#lesson_lesson_time_slot').val();
          console.log("slot value is "+slot);
          if (slot == "") {
            e.preventDefault();
            $('#lesson_lesson_time_slot').focus();
            $('#time-slot-warning').toggleClass('hidden');
            console.log ("prompt user to select time slot");
          // focus on Time slot field.
          }
      });



});
