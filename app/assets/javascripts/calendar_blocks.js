// $(".toggle_availability").click(e){
//     e.preventDefault()
// 	console.log('block has been toggled');
// 	if (this.val() == "Not Available"){
// 		console.log('need to change color.')
// 	};	
// }
 console.log("listing for clicks");

$(document).ready(function(){
  exampleListener();
});

var exampleListener = function() {
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


// $('#236').click(function(e){  
//   e.preventDefault();  
  // var path = $('#update_bio').attr('action')
  // var text = $('textarea').val()
  // console.log(text)
  // console.log(path)
  // var request = $.ajax({
  //                 url: path,
  //                 type: "PUT",
  //                 data: {bio: text}
  //                 });

  // request.done(function(data) {
  //     console.log(data);
  //     console.log("bio successfully updated via ajax");
  //     $('#omniModal').modal('hide')
  //     location.reload();
  // });

// });


// $('selector').click(function(e){
//   e.preventDefault();
//   $.ajax({
//        url: "<where to post>",
//        type: "POST",//type of posting the data
//        data: "data",
//        success: function (data) {
//          //what to do in success
//        },
//        error: function(xhr, ajaxOptions, thrownError){
//           //what to do in error
//        },
//        timeout : 15000//timeout of the ajax call
//   });

// });


// $(document).on('submit', '#update_bio',function(e) {
//   e.preventDefault();

//   var path = $('#update_bio').attr('action')
//   var text = $('textarea').val()
//   console.log(text)
//   console.log(path)
//   var request = $.ajax({
//                   url: path,
//                   type: "PUT",
//                   data: {bio: text}
//                   });

//   request.done(function(data) {
//       console.log(data);
//       console.log("bio successfully updated via ajax");
//       $('#omniModal').modal('hide')
//       location.reload();
//   });

// })

