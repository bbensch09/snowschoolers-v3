$(function () {
	$('.datetimepicker1').datetimepicker({
        sideBySide: true,
        useCurrent: true,
        format: 'YYYY-MM-DD HH:mm A'
	});
});


var user = {
	"first_name" : "Test First", 
	"Last Name" : "Test Last", 
	"Email" : "Test Email"	
};


$(document).ready(function(){

	$('.new-example-button').click(function(){
		console.log("User properties logged: " + user["Last Name"]);
		heap.identify('bbensch');
		heap.addUserProperties({user});

	})

})