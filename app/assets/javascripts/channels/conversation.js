// App.room = App.cable.subscriptions.create("ConversationChannel", {
//   connected: function() {},

//   disconnected: function() {

//   },

//   received: function(data) {
//     if (data.author_id == getCookie('userId')) {
//       $('.chat').append(data.my_message)
//     } else {
//       $('.chat').append(data.their_message)
//     }
//   },

//   speak: function(message) {
//     return this.perform('speak', {message: message});
//   }
// });


// $(document).on('submit', 'form[id=new_message]' , function(event) {
//   event.preventDefault();
//   console.log("listening for submit....");
//   var formDataJson = {};
//   var allFormTags = $(this).serializeArray();
//   $.each(allFormTags, function() {
//     formDataJson[this.name] = this.value;
//   })
//   App.room.speak(formDataJson);
//   $('#btn-input').val('');
// });

// function getCookie(name) {
//   var value = "; " + document.cookie;
//   var parts = value.split("; " + name + "=");
//   if (parts.length == 2) return parts.pop().split(";").shift();
// }
