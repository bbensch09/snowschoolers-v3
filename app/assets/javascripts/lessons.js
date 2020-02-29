$(document).ready(function(){
    console.log("#1 loading lessons.js");

});


console.log("#2Lesson.js loaded");

var dt = new Date();
var time = dt.getHours() + ":" + dt.getMinutes() + ":" + dt.getSeconds();
var hour = dt.getHours();
console.log("hour of day is "+hour);

if (hour < 15) { //if before 3pm PST, allow bookings for next day
    var DATES_BUFFER = 1
  } else {
    var DATES_BUFFER = 2
  };

var day = dt.getDate();
var day = day+DATES_BUFFER
console.log("The day values is set to "+day)
var month = dt.getMonth() + 1;
console.log("The month values is set to "+month)
var year = dt.getYear() +1900;
console.log("The year values is set to "+year)
var date = year + "-" + month + "-" + day;
var opening_date = new Date("2019-12-14");

// logs today's date
console.log("DATES_BUFFER is set to: "+DATES_BUFFER);
var MIN_DATE = date
console.log("The minimum bookable date is "+MIN_DATE);
if (MIN_DATE == '2020-2-30') {
  MIN_DATE = '2020-03-01';
  console.log("The minimum bookable date was changed to 2020-03-01.");
}
if (MIN_DATE == '2020-3-32') {
  MIN_DATE = '2020-04-01';
  console.log("The minimum bookable date was changed to 2020-04-01.");
}


if (Date.now() <= opening_date) {
  var MIN_DATE = '2019-12-14';
  // logs the season start date
  console.log(MIN_DATE);
}
if (month == 12 && year == 2019 && day ==33) {
  var MIN_DATE = '2020-01-01';
  // logs the season start date
  console.log('MIN date set to: '+MIN_DATE);
}

var LESSON = {
  init: function(){
    // important objects
    LESSON._date = $('#datepicker');
    LESSON._date2 = $('#datepicker2');
    LESSON._slot = $('#lesson_lesson_time_slot');
    LESSON._duration = $('#lesson_duration');
    LESSON._durations = {
      'one': $('#lesson_duration option:eq(1)'),
      'two': $('#lesson_duration option:eq(2)'),
      'three': $('#lesson_duration option:eq(3)'),
      'six': $('#lesson_duration option:eq(4)')
    };
    LESSON._startTime = $('#timepicker');
    LESSON._actualStartTime = $('#start-timepicker');
    LESSON._actualEndTime = $('#end-timepicker');

    // set datepicker
    LESSON.setDatepicker();

    // set and toggle duration enablement
    LESSON.toggleDuration();
    LESSON._slot.change(LESSON.toggleDuration);

    // set and toggle start_time enablement
    LESSON.toggleStartTime();
    LESSON._duration.change(LESSON.toggleStartTime);

    // configure and update timepickers
    LESSON.setTimepickers();
    LESSON._slot.change(LESSON.updateRequesterTimepicker);
    LESSON._duration.change(LESSON.updateRequesterTimepicker);
    LESSON._actualStartTime.change(LESSON.updateInstructorTimepickers);
  },

  // setDatepicker: function() { LESSON._date.datepicker({ minDate: '2016-12-16', dateFormat: 'yy-mm-dd' }); },

  // setDatepicker: function() { LESSON._date.datepicker({ minDate: MIN_DATE, maxDate: '2018-04-15', dateFormat: 'yy-mm-dd' }); },

  setDatepicker: function() {
  var blocked_dates_array = ['2019-12-17','2019-12-18','2019-12-19',
  '2020-01-07','2020-01-08','2020-01-09',
  '2020-01-14','2020-01-15','2020-01-16',
  '2020-01-21','2020-01-22','2020-01-23',
  '2020-01-28','2020-01-29','2020-01-30',
  '2020-02-04','2020-02-05','2020-02-06',
  '2020-02-11','2020-02-12','2020-02-13','2020-02-21','2020-02-24',
  '2020-02-25','2020-02-26','2020-02-27',
  '2020-03-03','2020-03-04','2020-03-05',
  '2020-03-10','2020-03-11','2020-03-12',
  '2020-03-17','2020-03-18','2020-03-19',
  '2020-03-24','2020-03-25','2020-03-26',
  '2020-03-31','2020-04-01','2020-04-02',
  '2020-04-07','2020-04-08','2020-04-09',
  ];
  LESSON._date.datepicker({
    beforeShowDay: function(date){
      var string = jQuery.datepicker.formatDate('yy-mm-dd', date);
      return [ blocked_dates_array.indexOf(string) == -1 ]
    },
    minDate: MIN_DATE,
    maxDate: '2020-04-12',
    dateFormat: 'yy-mm-dd'
  });
  LESSON._date2.datepicker({
    beforeShowDay: function(date){
      var string = jQuery.datepicker.formatDate('yy-mm-dd', date);
      return [ blocked_dates_array.indexOf(string) == -1 ]
    },
    minDate: MIN_DATE,
    maxDate: '2020-04-12',
    dateFormat: 'yy-mm-dd'
    });
  },

  // var TODAYS_DATE = new Date().getDate();
  // var LAUNCH_DATE = new Date('2016','11','16').getDate();
  // if ((launch - today) > 0 ){
  //   setDatepicker: function() { LESSON._date.datepicker({ minDate: '2016-12-16', dateFormat: 'yy-mm-dd' }); }
  // } else {
  //   setDatepicker: function() { LESSON._date.datepicker({ minDate: 0, dateFormat: 'yy-mm-dd' }); }
  // }

  toggleDuration: function() {
    if (LESSON.slotValid()) {
      LESSON.enable(LESSON._duration);
      LESSON.configureDuration();
    } else {
      LESSON.clearAndDisable(LESSON._duration);
      LESSON.clearAndDisable(LESSON._startTime);
    }
  },

  toggleStartTime: function() {
    if (LESSON.slotValid() && LESSON.durationValid()) { LESSON.enable(LESSON._startTime);
    } else { LESSON.clearAndDisable(LESSON._startTime); }
  },

  setTimepickers: function() {
    LESSON._startTime.timepicker({ 'step': 30 });
    LESSON.configureRequesterTimepicker();
    LESSON.configureConfirmTimepickers();
  },

  updateRequesterTimepicker: function() { LESSON.configureRequesterTimepicker(true); },

  updateInstructorTimepickers: function() { LESSON.configureConfirmTimepickers(); },

  // private methods

  slotValid: function() {
    var slot = LESSON._slot.val();
    return (slot === 'Morning' || slot === 'Afternoon' || slot === 'Full Day');
  },

  durationValid: function() {
    var duration = LESSON._duration.val();
    return (duration === '2' || duration === '3' || duration === '6');
  },

  enable: function(object) { object.prop('disabled', false); },

  disable: function(object) { object.prop('disabled', true); },

  setValue: function(object, value) { object.val(value); },

  clearAndDisable: function(object) {
    LESSON.setValue(object, null);
    LESSON.disable(object);
  },

  configureDuration: function() {
    var slot = LESSON._slot.val();
    var duration = LESSON._duration.val();
    LESSON.setDurationValue(slot, duration);
    LESSON.setDurationOptions(slot);
  },

  setDurationValue: function(slot, duration) {
    if (slot === 'Full Day') { LESSON.setValue(LESSON._duration, 6);
    } else if (duration === '6') { LESSON.setValue(LESSON._duration, null); }
  },

  setDurationOptions: function(slot) {
    if (slot === 'Full Day') { LESSON.configureDurationOptions('disable', 'enable');
    } else { LESSON.configureDurationOptions('enable', 'disable'); }
  },

  configureDurationOptions: function(slotStatus, fullDayStatus) {
    LESSON[slotStatus](LESSON._durations.two);
    LESSON[slotStatus](LESSON._durations.three);
    LESSON[fullDayStatus](LESSON._durations.six);
  },

  configureRequesterTimepicker: function(u) {
    var updating = typeof u !== 'undefined' ? u : false;

    if (LESSON.slotValid() && LESSON.durationValid()) {
      LESSON.setMinAndMaxTime();
      LESSON.checkStartTime(updating);
      LESSON.updateMinAndMaxTime();
    }
  },

  setMinAndMaxTime: function() {
    var slot = LESSON._slot.val();
    var duration = LESSON._duration.val();
    LESSON.setMinTime(slot);
    LESSON.setMaxTime(slot, duration);
  },

  setMinTime: function(slot) { LESSON.minTime = (slot === 'Afternoon' ? '1:00pm' : '9:00am'); },

  setMaxTime: function(slot, duration) {
    var cases = {
      "Morning|2": '10:30am',
      "Morning|3": '9:30am',
      "Afternoon|2": '2:00pm',
      "Afternoon|3": '1:00pm',
      'Full Day|6': '9:30am'
    };

    LESSON.maxTime = cases[slot + "|" + duration];
  },

  checkStartTime: function(updating) {
    if (LESSON.minTime === LESSON.maxTime) {
      if (updating) { LESSON.setValue(LESSON._startTime, LESSON.minTime); }
      LESSON.maxTime = '1:01pm';
    } else if (updating) { LESSON._startTime.val(null); }
  },

  updateMinAndMaxTime: function() {
    LESSON._startTime.timepicker('option', 'minTime', LESSON.minTime);
    LESSON._startTime.timepicker('option', 'maxTime', LESSON.maxTime);
  },

  configureConfirmTimepickers: function() {
    LESSON.initializeConfirmTimepickers();
    LESSON.updateActualEndTimepicker();
  },

  initializeConfirmTimepickers: function() {
    LESSON._actualStartTime.timepicker({ 'minTime': '9:00am', 'maxTime': '1:00pm', 'step': 60 });
    LESSON._actualEndTime.timepicker({ 'minTime': '10:00am', 'maxTime': '4:00pm', 'step': 60 });
    LESSON.disable(LESSON._actualEndTime);
  },

  updateActualEndTimepicker: function() {
    var actualStartTime = LESSON._actualStartTime.val();
    if (actualStartTime !== null) {
      LESSON._actualEndTime.timepicker('option', 'minTime', actualStartTime);
      LESSON.enable(LESSON._actualEndTime);
    }
  }
};

$(function() { LESSON.init(); });
$(window).bind('page:change', function() { LESSON.init(); });
// pre-load first student form



$(document).ready(function(){
  if($('.remove-student').length <=1){
    $('#add-student-button').click();
    // console.log("loaded first student.");
  };
  if($('#preSeasonModalButton').length > 0){
    $('#preSeasonModalButton').click();
    console.log("triggered preSeasonModal");
  }
  calculatePriceListener();
  // calculateTotalListener();
  toggleElementListener();
  abilityLevelWarningListener();
  maxStudentsListener();

});

var maxStudentsListener = function(){
  $('#add-student-button').click(function(e){
    var studentCount = $('.nested-fields').length
    console.log('student count is '+studentCount);
    if (studentCount >= 20){
      $('#add-student-button').addClass('hidden');
      $('#max-students-warning').removeClass('hidden');
      console.log('hide button to add more students.');
    }
  });
}

var abilityLevelWarningListener = function(){
  $('#add-student-button').click(function(e){
    $('#ability-level-warning').removeClass('hidden');
    console.log("removed hidden status of ability warning line.");
  });
}

var calculatePriceListener = function() {
  var hourlyRate = 75;
  $('.lesson-length-input').change(function(e){
    e.preventDefault();
    console.log("listening for changes to lesson_length");
    var lesson_length = $('.lesson-length-input').val();
      console.log("the input value is:" + lesson_length);
    var lesson_price = lesson_length*hourlyRate;
      console.log("the lesson price is:" +lesson_price);
    $('#donation-amount').html(lesson_price);
  });
  $('.lesson-slot-input').change(function(e){
    console.log("detected slot change.");
    if ( $('.lesson-slot-input').val() == 'Full Day'){
    console.log("the lesson slot is now full day.");
    var lesson_price = 6*hourlyRate;
    console.log("lesson price is: "+lesson_price)
    $('#donation-amount').html(lesson_price);
    };
  });
}

// Abandoned this approach for now
var calculateTotalListener = function() {
  console.log("totalListener is listening...");
  $('tip-amount-input').change(function(e){
    e.preventDefault();
    console.log("listening for changes to the tip");
    var tip_amount = $('tip-amount-input').val();
    var base_amount = $('base-amount-input').val();
      console.log("the tip amount is:" + tip_amount);
    var total_amount = base_amount + tip_amount;
      console.log("the lesson price is:" +total_amount);
    $('#transaction_final_amount').html(total_amount);
  });
}

var toggleElementListener = function(){
  $('#jobs-cta').click(function(e){
    e.preventDefault();
    $('#recruiting-landing-page').toggleClass('hidden');
    $('#header-creative').toggleClass('hidden');
    $('#learn-more').toggleClass('hidden');
    // $('#jobs-contact-us-footer').toggleClass('hidden');
    console.log("jobs-cta clicked; begin on-boarding questions.");
  });
// begin question prompts
  $('#submit-question1a').click(function(e){
    e.preventDefault();
    $('#question1').toggleClass('hidden');
    $('#question2').toggleClass('hidden');
    console.log("question 1 answered, next question revealed.");
  });
  $('#submit-question1b').click(function(e){
    e.preventDefault();
    $('#question1').toggleClass('hidden');
    $('#question2').toggleClass('hidden');
    console.log("question 1 answered, next question revealed.");
  });
  $('#submit-question1c').click(function(e){
    e.preventDefault();
    $('#question1').toggleClass('hidden');
    $('#question2').toggleClass('hidden');
    console.log("question 1 answered, next question revealed.");
  });
  $('#submit-question1d').click(function(e){
    e.preventDefault();
    $('#question1').toggleClass('hidden');
    $('#question2').toggleClass('hidden');
    console.log("question 1 answered, next question revealed.");
  });
  $('#submit-question1e').click(function(e){
    e.preventDefault();
    $('#question1').toggleClass('hidden');
    $('#question2').toggleClass('hidden');
    console.log("question 1 answered, next question revealed.");
  });
  $('#submit-question1f').click(function(e){
    e.preventDefault();
    $('#question1').toggleClass('hidden');
    $('#question2').toggleClass('hidden');
    console.log("question 1 answered, next question revealed.");
  });
// question 2
  $('#submit-question2').click(function(e){
    e.preventDefault();
    $('#question2').toggleClass('hidden');
    $('#question3').toggleClass('hidden');
    console.log("question 2 answered, next question revealed.");
  });
  $('#submit-question2b').click(function(e){
    e.preventDefault();
    $('#thinking-face').toggleClass('hidden');
    console.log("question 2 answered incorrectly....");
  });


// question 3
  $('#submit-question3').click(function(e){
    e.preventDefault();
    $('#question3').toggleClass('hidden');
    $('#apply-form').toggleClass('hidden');
    console.log("question 3 answered, show application.");
  });
  $('#submit-question3b').click(function(e){
    e.preventDefault();
    $('#thinking-face3b').toggleClass('hidden');
    console.log("question 2 answered incorrectly....");
  });


// old toggle elements
  //  $('#toggle-upcoming-lessons').click(function(e){
  //   e.preventDefault();
  //   $('#upcoming-lessons').toggleClass('hidden');
  //   console.log("lessons revealed, buttons switched.");
  // });
  //   $('#toggle-available-lessons').click(function(e){
  //   e.preventDefault();
  //   $('#available-lessons').toggleClass('hidden');
  //   console.log("lessons revealed, buttons switched.");
  // });
  //   $('#toggle-filter-options').click(function(e){
  //   e.preventDefault();
  //   $('#secondary-search-filters').toggleClass('hidden-unless-desktop');
  //   console.log("filters revealed.");
  // });
  //   $('#toggle-more-info').click(function(e){
  //   e.preventDefault();
  //   $('#more-info').toggleClass('hidden');
  //   console.log("info revealed.");
  // });
  //   $('.needs-rental').change(function(e){
  //   e.preventDefault();
  //   // $('.student-rental-information').toggleClass('hidden');
  //   rental_state = $('.needs-rental').val();
  //   console.log("current rental_state is "+rental_state);
  //   if (rental_state == 'true') {
  //   $('.lodging-reservation-input').removeClass('hidden');
  //   console.log("lodging info revealed");
  //   } else {
  //     $('.lodging-reservation-input').addClass('hidden');
  //     console.log('keep lodging info hidden');
  //   };
  // });


  // toggle feedback boxes
     $('.btn-toggleFeedback').click(function(e){
    e.preventDefault();
    $('.qualitative_feeback').toggleClass('hidden');
    console.log("show or hide qualitative_feeback text area");
  });

}

$(function(){
  $("#search_date").datepicker();
})
