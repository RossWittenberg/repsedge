$(function() {

	displayConfirmedToggleNew();
	confirmedToggleEditListener();

	
	if ( $('.calendar-error').find('p').text().length > 0 && $('#calendar').length ){
		console.log("visit errors!");
		$('#newVisitModal').modal('show');
	} else{
		console.log("no visit errors!")
	}

  console.log( "ready!" );
  if ($('#calendar').length){
		var userId = $('#calendar').attr('user');
		getVisitsForCalendar(userId);
		$('.calendar-sync-container').tabs();
	};
	
	$('select#visit_start_time_raw_4i').on("change", function (e) {
		oneHourAdjuster("select2:select", e)
	});

	$('select#visit_start_time_raw_5i').on("change", function (e) {
		minuteAdjuster("select2:select", e)
	});

	$("select#user_time_zone").change(function(event) {
		$.ajax({
			url: "/users",
			type: 'PUT',
			data: {user: {time_zone: $(this).val()}, calendar: true}
		}).done(function(data) {
			console.log("!success!");
			location.reload();
		})
	});


	function get_high_schools_by_name(request, response){
	  var params = {name_or_ceeb_query: request.term};
	  $.getJSON(
	    "/high_schools/name_or_ceeb_query_auto_complete",
	    params 
	    ).done(function(data){
    		var highSchoolsArray = [];
    		for (var i = 0; i < data.high_schools.length; i++) {
    			var highSchoolInfoString = data.high_schools[i].name 
    			+ " - " + data.high_schools[i].city + ", " + data.high_schools[i].state.abbreviation + " - " + data.high_schools[i].id
    			highSchoolsArray.push(highSchoolInfoString)
    		};
        response(highSchoolsArray)
      }); 
	};

	// $( "input#new-vist-high-school-name-search").autocomplete({ 
 //    source: get_high_schools_by_name, 
 //    minLength: 2,
 //    response: function(event, ui){
 //    	for (var i = 0; i < ui.content.length; i++) {
 //    		var highSchoolString = ui.content[i].value;
 //    		var autocompleteContainer = $('.visit-high-school');
 //    		$('<div>').addClass('high-school-autocomplete-div')
 //    							.text(highSchoolString)
 //    							.appendTo(autocompleteContainer);
 //    	};
 //    }
 //  });

$( "input#new-vist-high-school-name-search").autocomplete({ 
    source: get_high_schools_by_name, 
    minLength: 2,
    select: function (event, ui) {
      console.log(ui)
      console.log(event)
      params = { high_school: ui.item.value }
      $.get('/high_schools/high_school', 
        params
        ).success(function(data) {
	        console.log(data.name)
	    //     var name = "You selected " + data.name;
	    //     $("#newVisitModal #high-school-name-label").show()
					// $("#newVisitModal #high-school-name").text(data.name)

					// $("#newVisitModal #high-school-address-label").show()
					// $("#newVisitModal #high-school-address").text(data.address)

					// $("#newVisitModal #high-school-city-label").show()
					// $("#newVisitModal #high-school-city").text(data.city)

					// $("#newVisitModal #high-school-state-label" ).show()
					// $("#newVisitModal #high-school-state").text(data.state_abbreviation)

					$('#newVisitModal input#visit_title').val(data.name);
					$('#newVisitModal input#visit_location').val(data.address + " " + data.city + ", " + data.state_abbreviation );
					
					if (data.hs_phone_num.length > 0){
						$(".new_visit_phone_num").show()
						$('#newVisitModal span#visit_phone_num').text(data.hs_phone_num);
					} else{
						$(".new_visit_phone_num").show()
						$('#newVisitModal span#visit_phone_num').text("N/A")
					};

					$("#newVisitModal #visit_high_school_id").empty().val("")
					$("#newVisitModal #visit_high_school_id").val(parseInt(data.id));

      });
    }
  });

$( "input#edit-vist-high-school-name-search").autocomplete({ 
    source: get_high_schools_by_name, 
    minLength: 2,
    select: function (event, ui) {
      console.log(ui)
      console.log(event)
      params = { high_school: ui.item.value }
      $.get('/high_schools/high_school', 
        params
        ).success(function(data) {
	        console.log(data.name)
	        var name = "You selected " + data.name;
					
					if (data.hs_phone_num.length > 0){
						$('.editVisitForm span#visit_phone_num').text(data.hs_phone_num);
					} else{
						$('.editVisitForm span#visit_phone_num').text("N/A")
					};
	    		// $(".editVisitForm #high-school-name-label").show()
					// $(".editVisitForm #high-school-name").text(data.name)

					// $(".editVisitForm #high-school-address-label").show()
					// $(".editVisitForm #high-school-address").text(data.address)

					// $(".editVisitForm #high-school-city-label").show()
					// $(".editVisitForm #high-school-city").text(data.city)

					// $(".editVisitForm #high-school-state-label" ).show()
					// $(".editVisitForm #high-school-state").text(data.state_abbreviation)

					$('.editVisitForm input#visit_title').val(data.name);
					$('.editVisitForm input#visit_location').val(data.address + " " + data.city + ", " + data.state_abbreviation );
					
			 		// $('.editVisitForm input#visit_contact').val(data.visit.contact);

					$(".editVisitForm #visit_high_school_id").empty().val("")
					$(".editVisitForm #visit_high_school_id").val(parseInt(data.id));

      });
    }
  });


	$('input#visit_start_date_raw.newDatePicker').val(getToday())
	$('input#visit_end_date_raw.newDatePicker').val(getToday())

	$('input#visit_start_date_raw.newDatePicker').on("change", function(){
		var startDate = $(this).val()
		var endDateElement = $('input#visit_end_date_raw.newDatePicker').val(startDate);
	})

	$('input#visit_start_date_raw.editDatePicker').on("change", function(){
		var startDate = $(this).val()
		var endDateElement = $('input#visit_end_date_raw.editDatePicker').val(startDate);
	})

	$('#editVisitModal').on('hidden.bs.modal', function () {
		$('form.updateForm').removeAttr('action');
	})

});

function Visit(id, title, location, category, userId, time_zone ) {
  // change 'id' and 'end' as it likely is reserved in js 
	var userId = $('#calendar').attr('user');
  this.id = id;
  this.title = title;
  this.location = location; 
  // this.contact = contact; 
  this.category = category; 
  this.userId = userId; 
  this.time_zone = time_zone;
}
function setVisitColor (visitCategory, visitConfirmed) {
	if ( visitCategory == "College Fair" ) {
		return "#79c2df";
	}
	else if ( visitCategory == "Hotel" ) {
		return "#363636";
	}
	else if ( visitCategory == "Reminder" ) {
		return "#E66E00";
	}
	else if ( visitCategory == "High School Visit" && (visitConfirmed === true) ) {
		return "#456f88";
	}
	else if ( visitCategory == "High School Visit" && (visitConfirmed !== true ) ) {
		return "#B61F1F ";
	}
	else {
		return "#615177";
	}
};
function renderShowModal( calEvent ){
	console.log("rendering show modal...");
	// build modal header	
	var showModalHeader = $('.modal#showVisitModal .modal-header')
	var showVisitModalHeaderContainer = $('.modal#showVisitModal .modal-header .showVisitModalHeaderContainer')
	showVisitModalHeaderContainer.empty();
	if ( calEvent.high_school_id === null ){
		var header = $('<h4>').addClass('modal-header')
													.text(calEvent.title)
													.appendTo(showVisitModalHeaderContainer)
													.css('border-bottom', 'none');	
	} else {
		var link = $('<a>').attr('href', '/high_schools/'+calEvent.high_school_id)
											 .appendTo(showVisitModalHeaderContainer)
											 .append($('<h5>').text("View Profile Page")
											 .css('border-bottom', 'none'))
		
		var header = $('<h4>').addClass('modal-header')
													.text(calEvent.title)
													.prependTo(showVisitModalHeaderContainer)
													.css('border-bottom', 'none');
	}
	// build modal body
	var showModalBody = $('.modal#showVisitModal .modal-body')
	showModalBody.empty();
	var userTimeZone = calEvent.user_time_zone;
	var adjustedStart =	moment.tz(calEvent.start, calEvent.time_zone).format('MMMM Do YYYY, h:mm a z');
	var adjustedEnd =	moment.tz(calEvent.end, calEvent.time_zone).format('MMMM Do YYYY, h:mm a z');

	var title = $('<div>').addClass('visit-title')
												.append($('<label>')
												.addClass('visit-label')
												.text('Title: '))
												.append($('<p>').text(calEvent.title));
	
	var location = $('<div>').addClass('visit-location')
	                         .append($('<label>')
	                         .addClass('visit-label')
	                         .text('Location: '))
	                         .append($('<p>').text(calEvent.location));

	var phone_num = $('<div>').addClass('visit-phone_num')
													.append($('<label>')
													.addClass('visit-label')
													.text('Phone Number: '))
													.append($('<p>')
													.text(calEvent.phone_num));


	var category = $('<div>').addClass('visit-category')
													 .append($('<label>')
													 .addClass('visit-label')
													 .text('Category: '))
													 .append($('<p>')
													 .text(calEvent.category));

	var start = $('<div>').addClass('visit-start')
												.append($('<label>')
												.addClass('visit-label')
												.text('Start: '))
												.append($('<p>')
												.text( adjustedStart ));

	var end = $('<div>').addClass('visit-end')
											.append($('<label>')
											.addClass('visit-label')
											.text('End: '))
											.append($('<p>')
											.text( adjustedEnd ));

	var time_zone = $('<div>').addClass('visit-time-zone')
														.append($('<label>')
														.addClass('visit-label')
														.text('Time Zone: '))
														.append($('<p>').text(calEvent.time_zone));

	showModalBody.append(title)
					   .append(location)
					   .append(phone_num)	
					   .append(category)	
					   .append(start)	
					   .append(end)
					   .append(time_zone);													

	// build modal footer	
	var showModalFooter = $('.modal#showVisitModal .modal-footer')
	showModalFooter.empty();
	if (calEvent.category === "High School Visit" ){
		renderConfirmationButton(calEvent);
	}
	var editButton = $('<button>').attr('id', 'visitEditButton')
															  .attr('data-toggle', 'modal')
															  .attr('data-target', '#editVisitModal')
															  .attr('data-dismiss', 'modal')
															  .attr('data-visitid', calEvent.id)
															  .text('Edit')
															  .click(function(event) {
															  	var userId = $('#calendar').attr('user');
															  	var currentVisitId = $(this).data('visitid');
															  	renderEditForm (userId, currentVisitId)
															  })
															  .appendTo(showModalFooter);	
};
function renderEditForm( userId, visitId ) {
	$.get('/users/'+userId+'/visits/'+visitId+'/edit').done(function(data){
		var userTimeZone = data.visit.user_time_zone;
		// var adjustedStart =	moment(data.visit.start).format();
		// var adjustedEnd =	moment(data.visit.end).format();
		var adjustedStart =	moment.tz(data.visit.start, data.visit.time_zone).format();
		var adjustedEnd =	moment.tz(data.visit.end, data.visit.time_zone).format();
		displayConfirmedToggleEditOnRender(data);

		$('.editVisitForm input#visit_title').val(data.visit.title);
		$('.editVisitForm input#visit_location').val(data.visit.location);
		$('.editVisitForm span#visit_phone_num').text(data.visit.phone_num);
		$('.editVisitForm select#visit_category').val(data.visit.category).change();
		
		$('input#visit_start_date_raw').val(formatDate(adjustedStart));
		$('input#visit_end_date_raw').val(formatDate(adjustedEnd));

		$('input#edit-vist-high-school-name-search').val(data.visit.high_school_name);
		
		$('#visit_start_time_raw_4i.editTimePicker').val(formatHour(adjustedStart)).prop("selected", "selected").change();
		$('#visit_start_time_raw_5i.editTimePicker').val(formatMinutes(adjustedStart)).prop("selected", "selected").change();

		$('#visit_end_time_raw_4i.editTimePicker').val(formatHour(adjustedEnd)).prop("selected", "selected").change();
		$('#visit_end_time_raw_5i.editTimePicker').val(formatMinutes(adjustedEnd)).prop("selected", "selected").change();

		$('.editVisitForm select#visit_time_zone').val(timeZoneConverter(data.visit.time_zone)).change();
		$('.modal-sub-footer').empty();

		var updateForm = $('form.updateForm')
		var formAction = "/users/" + userId + "/visits";


		updateForm.attr('action', formAction + '/' + visitId + '/formUpdate');
		updateForm.append("<input type='hidden' name='_method' value='PUT'>");
		var deleteVisitButton = $('<button>').text('Delete Event')
																					.attr({
																						id: 'deleteVisitButton',
																						userId: userId,
																						visitId: visitId
																					})
																					.attr('data-toggle', 'modal')
															  					.attr('data-dismiss', 'modal')
																					.appendTo('.modal-sub-footer');
		var deleteVisitButton = $('#deleteVisitButton');
		$(deleteVisitButton).on('click', setDeleteButtonUrl);

	});

};
function buildCalendar (data, userId){
	for (var i = 0; i < data.visits.length; i++) {
		if (data.visits[i].user_time_zone === "Hawaii"){
			data.visits[i].user_time_zone = "US/Hawaii";
		}; 
		var userTimeZone = data.visits[i].user_time_zone;
		data.visits[i].start = moment.tz(data.visits[i].start, reverseTimeZoneConverter(userTimeZone)).format();
		data.visits[i].end = moment.tz(data.visits[i].end, reverseTimeZoneConverter(userTimeZone)).format();
		data.visits[i].color = setVisitColor(data.visits[i].category, data.visits[i].confirmed );
		var visit = new Visit (data.visits[i].id,
													 data.visits[i].title,
													 data.visits[i].location,
													 // data.visits[i].contact,
													 data.visits[i].category,
													 data.visits[i].userId,
													 data.visits[i].time_zone);
	};
  $('#calendar').fullCalendar({
  	editable: true,
		eventLimit: true,
		events: data.visits,
		dragOpacity: "0.5",
    handleWindowResize: true,
    eventStartEditable: false,
    header: {
    	left: 'today',
    	right: 'month agendaWeek agendaDay',
    	center: 'prev title next'
    },
    eventRender: function( event, element, view ) { 
    	$(element).attr({ "visitId": event.id,
    										"title": event.title,
    										"location": event.location,
    										// "contact": event.contact,
    										"category": event.category,
    										"userId": event.user_id,
    										"start": event.start.format(),
    										"end": event.end.format(),
    										"time_zone": event.time_zone })
    },
    eventDrop: function(event,dayDelta) {
    	updateVisit(event)
    },
    eventClick: function(calEvent, jsEvent, view) {
    	$('.fc-event')
  			.addClass('modalAnchorTag')
				.attr({
					'data-toggle': 'modal', 
					'data-target': '#showVisitModal'
				});
	  	var userId = $('#calendar').attr('user');
	  	var visitId = $(this).attr('visitId');
	  	var visitTitle = $(this).attr('title');
			var visitLocation = $(this).attr('location');
			// var visitContact = $(this).attr('contact');
			// var visitDescription = $(this).attr('description');
			var visitCategory = $(this).attr('category');
			var visitConfirmed = $(this).attr('confirmed');
			var visitStart = $(this).attr('start');
			var visitEnd = $(this).attr('end');
			var visitTimeZone = $(this).attr('time_zone'); 
			renderShowModal( calEvent )
		}
	});
};
function getVisitsForCalendar(userId){
	$.get('/users/'+userId+'/visits').done(function(data){
		buildCalendar(data, userId)
	});
};	

function formatDate(date){

	var fullDateTime = new Date(date);

	var year = fullDateTime.getFullYear().toString();
	var month = (fullDateTime.getMonth()+1).toString();
	if (month.length === 1){
		month = "0" + month;
	};
	var day = fullDateTime.getDate().toString();
	if (day.length === 1){
		day = "0" + day;
	};
	var date = month + "-" + day + "-"  + year;
	return date
};
function formatHour(date){
	var fullDateTime = new Date(date);
	var hours = fullDateTime.getHours().toString();
	if (hours.length === 1){
		hours = "0" + hours;
	};
	return hours;
};
function formatMinutes(date){
	var fullDateTime = new Date(date);
	var minutes = fullDateTime.getMinutes().toString();
	if (minutes.length === 1){
		minutes = "0" + minutes;
	};
	return minutes;
};
function setDeleteButtonUrl(event){
	var confirmPrompt = confirm("Are you sure you want to delete this visit?")
	if (confirmPrompt){
		var userid = $(event.target).attr('userid');
		var visitid = $(event.target).attr('visitid');
		$.ajax({
			url: "/users/"+userid+"/visits/"+visitid,
			type: 'DELETE',
		}).done(function(data) {
			getVisitsForCalendar(data.user.id);
			console.log("!success!");
		})
	} else {
		return false;
	}
};
function updateVisit(event){
	var userId = event.user_id;
	var requestURL = "/users/"+userId+"/visits/"+event.id+"/jsDragUpdate";
	var userTimeZone = event.user_time_zone;
	var adjustedStart =	moment.tz(event.start, event.time_zone).format();
	var adjustedEnd =	moment.tz(event.end, event.time_zone).format();
	$.ajax({
		type:"PUT",
		url: requestURL, 
		data: {"visit": {"id": event.id,
		 				   			 "title": event.title,
		 				   			 "location": event.location,
		 				   			 // "contact": event.contact,
		 				   			 "category": event.category,
		 				   			 "user_id": event.user_id,
		 				   			 "start": adjustedStart,
		 				   			 "end": adjustedEnd,
		 				   			 "time_zone": event.time_zone}}
		 				   	})
	.done(function(data){
		console.log(data);
		buildCalendar(data);
	});	
};

function timeZoneConverter(timeZone){
	if (timeZone === "America/New_York"){
		return "Eastern Time (US & Canada)"
	} else if (timeZone === "America/Indianapolis" ){
		return "Indiana (US & Canada)"	
	} else if (timeZone==="America/Chicago" ){
		return "Central Time (US & Canada)"
	} else if (timeZone === "America/Denver"){
		return "Mountain Time (US & Canada)"
	} else if (timeZone === "America/Phoenix"){
		return "Arizona"
	} else if (timeZone==="America/Los_Angeles"){
		return "Pacific Time (US & Canada)"
	} else if(timeZone==="America/Juneau"){
		return "Alaska"
	} else {
		return "Hawaii"
	}
};

function reverseTimeZoneConverter(timeZone){
	if (timeZone === "Eastern Time (US & Canada)"){
		return "America/New_York"
	} else if (timeZone === "Indiana (US & Canada)" ){
		return 	"America/Indianapolis"
	} else if (timeZone === "Central Time (US & Canada)" ){
		return "America/Chicago"
	} else if (timeZone === "Mountain Time (US & Canada)"){
		return "America/Denver"
	} else if (timeZone === "Arizona" ){
		return "America/Phoenix"
	} else if (timeZone === "Pacific Time (US & Canada)" ){
		return "America/Los_Angeles"
	} else if(timeZone === "Alaska"){
		return "America/Juneau" 
	} else {
		return "US/Hawaii"
	}
};

function oneHourAdjuster(name, event){
	console.log("time selected")
	if (event.val !== undefined ){
		var startTime = event.val;
		var endTimeElement = $('select#visit_end_time_raw_4i');
		var endTime = timeSelectFormatter(startTime)
		endTimeElement.val(endTime).prop('selected', 'selected').change();
	};	
};

function timeSelectFormatter(time){
	if (time === "23"){
		return "00"
	} else if ( parseInt(time) > 9 ){
		return (parseInt(time) + 1).toString()
	} else {
		var timeString = (parseInt(time.slice(1)) + 1).toString()
		return "0" + timeString
	}
}

function minuteAdjuster(name, event){
	console.log("minutes selected")
	if (event.val !== undefined ){
		var startMinutes = event.val;
		var endMinutesElement = $('select#visit_end_time_raw_5i');
		endMinutesElement.val(startMinutes).prop('selected', 'selected').change();
	};	
};

function getToday(){
	var today = new Date();
	var dd = today.getDate();
	var mm = today.getMonth()+1;
	var yyyy = today.getFullYear();
	if(dd<10) {
	    dd='0'+dd
	} 
	if(mm<10) {
	    mm='0'+mm
	} 
	today = mm+'-'+dd+'-'+yyyy;
	return today
}

function formatUTCDate(date){

	var fullDateTime = new Date(date);

	var year = fullDateTime.getUTCFullYear().toString();
	var month = (fullDateTime.getUTCMonth()+1).toString();
	if (month.length === 1){
		month = "0" + month;
	};
	var day = fullDateTime.getUTCDate().toString();
	if (day.length === 1){
		day = "0" + day;
	};
	var date = month + "-" + day + "-"  + year;
	return date
};
function formatUTCHour(date){
	var fullDateTime = new Date(date);
	var hours = fullDateTime.getUTCHours().toString();
	if (hours.length === 1){
		hours = "0" + hours;
	};
	return hours;
};
function formatUTCMinutes(date){
	var fullDateTime = new Date(date);
	var minutes = fullDateTime.getUTCMinutes().toString();
	if (minutes.length === 1){
		minutes = "0" + minutes;
	};
	return minutes;
};
 
function displayConfirmedToggleNew(){
	$('#visit_category').change(function(event) {
		if ( $(this).val() !== "High School Visit") {
			$('.hs-visit-submit-button-wrapper').addClass('hidden').hide();
			$('.non-hs-visit-submit-button-wrapper').removeClass('hidden').show();
		} else {
			$('.hs-visit-submit-button-wrapper').removeClass('hidden').show();
			$('.non-hs-visit-submit-button-wrapper').addClass('hidden').hide();
		}
	});
}

function displayConfirmedToggleEditOnRender(data){
	var confirmed = data.visit.confirmed
	if (data.visit.category === "High School Visit") {
		$('input#visit-confirmation-edit').bootstrapSwitch('state', confirmed, confirmed);
		$('.checkbox-confirmed-edit').show();
	} else {
		$('.checkbox-confirmed-edit').hide();
	}
};

function confirmedToggleEditListener(){
	$('.visit-category-edit').change(function(event) {
		if ( $(this).val() !== "High School Visit") {
			$('.checkbox-confirmed-edit').hide();

		} else {
			$('.checkbox-confirmed-edit').show();
		}
	});
}

function renderConfirmationButton(calEvent) {
	var confirmed = calEvent.confirmed;
	if (confirmed === true ){
		var confirmationButtonText = "Change to Tentative";
		var classForConfirmationButton = "tentative-button";
	} else {
		var confirmationButtonText = "Confirm Visit";
		var classForConfirmationButton = "confirmed-button";		
	}
	var confirmationButton = 	$('<button>').addClass('confirmation-button')
																.attr({
																	'data-visitid': calEvent.id,
																	'name': 'commit'
																 })
															  .addClass(classForConfirmationButton)
															  .text(confirmationButtonText)
															  .click(function(event) {
															  	var userId = $('#calendar').attr('user');
															  	var currentVisitId = $(this).data('visitid');
															  	updateCofirmationStatus( userId, currentVisitId, confirmed );
															  })
	var confirmationButtonWrapper = $('<div>').addClass('left').append(confirmationButton);
	var showModalFooter = $('.modal#showVisitModal .modal-footer');
	confirmationButtonWrapper.appendTo(showModalFooter);
}


function updateCofirmationStatus(userId, visitId, confirmed){
	console.log(visitId + " " + userId)
	var toggledConfirmed = confirmed === true ? false : true;
	$.ajax({
		url: '/users/'+userId+'/visits/'+visitId+'/update_confirmed',
		type: 'PUT',
		data: { user_id: userId,
						visit_id: visitId,
						confirmed: toggledConfirmed
		},
	})
	.done(function(data) {
		console.log("success");
	})
	.fail(function(data) {
		console.log("error");
	})
	
}

// select: function (event, ui) {
//   console.log(ui)
//   console.log(event)
//   params = { high_school: ui.item.value }
//   $.get('/high_schools/high_school', 
//     params
//     ).success(function(data) {
//       console.log(data.name)
//       var name = "You selected " + data.name;
//       $("#high-school-name-label").show()
// 			$("#high-school-name").text(data.name)

// 			$("#high-school-address-label").show()
// 			$("#high-school-address").text(data.address)

// 			$("#high-school-city-label").show()
// 			$("#high-school-city").text(data.city)

// 			$("#high-school-state-label" ).show()
// 			$("#high-school-state").text(data.state_abbreviation)
// });

