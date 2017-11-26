$(".toggle_availability").click(e){
    e.preventDefault()
	console.log('block has been toggled');
	if (this.val() == "Not Available"){
		console.log('need to change color.')
	};	
}
 