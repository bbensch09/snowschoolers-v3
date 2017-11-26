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
  	// console.log(this_var);
  	// console.log(id);
  	// console.log(path);
  	var request = $.ajax({
  		url: path,
  		type: "PUT",
	    // dataType: "json",
  		data: text
  	});
  	request.done(function(data){
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
  	});
  });  
}
