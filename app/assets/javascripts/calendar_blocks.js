$(document).ready(function(){
  availabilityListener();
});

var availabilityListener = function() {
  $('.toggle-availability').click(function(e){
    e.preventDefault();
  	console.log('click detected.');
  	var text = $(this).html();
  	var id = $(this).attr('id'); 
  	var path = "/toggle-availability/"+id
  	var this_var = $(this).parent().parent();
  	console.log('text is: '+text);
  	// console.log(id);
  	// console.log(path);
  	$.ajax({
  		url: path,
  		type: "POST",
	    dataType: "JSON",
  		data: text,
      success: function() {
        console.log('received a successfully ajax response.');
          // console.log(data);
        $("#"+id).parent().parent().toggleClass('availability-blocked');
        $("#"+id).parent().parent().toggleClass('availability-open');
        console.log($("#"+id).html());
        if ($("#"+id).html() == "Mark as Available"){
          $("#"+id).html("Mark as Not Available");
        } else {
          $("#"+id).html("Mark as Available");
        }
      }
  	});
  	});  
}
