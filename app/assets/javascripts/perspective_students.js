$(function() {	
	
	$(".institution-confirmation-container").hide();
	$("#prospective-students-tabs").tabs(//{
	//activate: function(event, ui) { 
	  //window.location.hash = ui.newTab.find('a').attr('href');
	  //}
	//});
	);

	$("#check-all-email").click(function(event) {
		console.log("toggle select all emails")
		if ($("input#email").prop('checked') === false ){
			$("input#email").prop('checked', true ).change();
		}	else {
			$("input#email").prop('checked', false ).change()
		}
		if ($("input#email").prop('checked') === false ){
			$("#showProspectiveEmailForm").prop('disabled', true).addClass('disabled');
		} else {
			$("#showProspectiveEmailForm").removeProp('disabled').removeClass('disabled');
		}
	});

	$("input[type='checkbox']").click(function(event) {
		if ($(this).prop('checked') === true ){
			$("#showProspectiveEmailForm").removeProp('disabled').removeClass('disabled');
		} else {
			$("#showProspectiveEmailForm").prop('disabled', true).addClass('disabled');
		}
	});

	$('textarea.wysihtml5').wysihtml5({'toolbar': {'link': false, 'html': true}})





$("button#sendProspectiveStudentEmailTest").click(function(event) {
	var subject = $("input#subject_").val();
	var content = $("textarea").val();
	$.ajax({
		url: '/prospective_students/send_test_mail',
		type: 'GET',
		dataType: 'JSON',
		data: { subject: subject, content: content},
	})
	.success(function(data) {
		var successMsg = data.prospective_student_message;
		var modalBody = $(".modal-body")
		$("span.message").remove();
		$("<span>").text(successMsg)
						   .prependTo(modalBody)
						   .addClass('message success')
 							 .css("padding", "12px")
						   .css("background-color", "papayawhip")
						   .css("color", "coral")
						   .css("display", "block");
	}).fail(function(data) {
		var successMsg = data.prospective_student_message;
		var modalBody = $(".modal-body")	
		$("span.message").remove();
		$("<span>").text(successMsg)
							 .prependTo(modalBody)
							 .addClass('message error')
							 .css("padding", "12px")
						   .css("background-color", "papayawhip")
						   .css("color", "coral")
						   .css("display", "block");
	});
	
});








	

	$("#showProspectiveEmailForm").click(function(event) {
		console.log("showing prospective students form")
		$("#recipients").empty();
		getProspectiveStudentsById();
	});

	$("button#sendProspectiveStudentEmail").click(function(event) {
		var recipients = [];
		for (var i = 0; i < $("tr.studentRow").length; i++) {
			var recipientRow = $("tr.studentRow")[i];
			recipients.push($(recipientRow).attr('id'))
		};
		var subject = $("input#subject_").val();
		var content = $("textarea").val();
		$.ajax({
			url: '/prospective_students/send_mail',
			type: 'GET',
			dataType: 'JSON',
			data: { subject: subject, content: content, recipients: recipients },
		})
		.success(function(data) {
			var successMsg = data.prospective_student_message;
			var modalBody = $(".modal-body")
			$("span.message").remove();
			$("<span>").text(successMsg).prependTo(modalBody)
					 .addClass('message success')
		 			 .css("padding", "12px")
			  	 .css("background-color", "papayawhip")
			  	 .css("color", "coral")
				   .css("display", "block")
		}).fail(function(data) {
			var successMsg = data.prospective_student_message;
			var modalBody = $(".modal-body")
			$("span.message").remove();
			$("<span>").text(successMsg).prependTo(modalBody)
				   .addClass('message error')
				   .css("padding", "12px")
			  	 .css("background-color", "papayawhip")
			  	 .css("color", "coral")
				   .css("display", "block");
		});
		
	});
	

	$("input#institution-search").hide();

	if ( $('#prospective_student_intended_major option').filter(':selected').text() === "Other") {
		$("input[type=text]#prospective_student_intended_major").show();
	} else {
		$("input[type=text]#prospective_student_intended_major").hide();
	};

	$("select#state-institution-select").change(function(){
		$("input#institution-search").show();
	});

	$("#prospective_student_intended_major").change(function() {
		var selected_major_option = $('#prospective_student_intended_major option').filter(':selected').text();
		if (selected_major_option === "Other"){
			$("input[type=text]#prospective_student_intended_major").show();
			$("input[type=text]#prospective_student_intended_major").prop('disabled', false);
		} else {
			$("input[type=text]#prospective_student_intended_major").prop('disabled', true);
			$("input[type=text]#prospective_student_intended_major").hide();
		}
	});

	function get_institutions_by_location(request, response){
	  var params = {institution_query: request.term, state: $('#state-institution-select').val()};
	  $.getJSON(
	    "/institutions/institution_auto_complete",
	    params 
	    ).done(function(data){
	      console.log(data)

	      response(data.institutions)
	    }); 
	}

	$("select#prospective-students-year-select").change(function(event) {
		var params = $("select#prospective-students-year-select").find(":selected").val()
		var user_id = $("#user-id-field").val()
		console.log("year changed")
		$("#prospective-students-year-submit").click();
		// $.ajax({
		// 		url: '/users/'+user_id+'/prospective_students/get_prospective_students_by_year', 
  //       type: 'PUT',
  //       data: { year: params }
  //       }).success(function(data) {
  //        console.log(data)

  //     });
	});

	$( "#institution-search.prospective-student-institution-input" ).autocomplete({ 
    source: get_institutions_by_location, 
    minLength: 2,
    select: function (event, ui) {
      console.log(ui)
      console.log(event)
      params = { institution: ui.item.value }
      $(".institution-confirmation-container").show();
      $("#institution-name").empty();
      $.get('/institutions/institution', 
        params
        ).success(function(data) {
         console.log(data.name)
         var name = "You selected " + data.name;
         
         $("#institution-id-field").val(data.id);

         $('.institution-error-message').empty();
         $('#institution-name').append(name)
         $("#institution-id-field").val(data.id)
         $("#institution-name-label").show()
				 $("#institution-name").text(data.name)
				 $("#institution-address-label").show()
				 $("#institution-address").text(data.street_address)
				 $("#institution-city-label").show()
				 $("#institution-city").text(data.city)
				 $("#institution-state-label").show()
				 $("#institution-state").text(data.state)
      });
    }
  });

	function get_high_schools_by_name(request, response){
	  var params = {name_or_ceeb_query: request.term};
	  $.getJSON(
	    "/high_schools/name_or_ceeb_query_auto_complete",
	    params 
	    ).done(function(data){
    		var highSchoolsArray = [];
    		for (var i = 0; i < data.high_schools.length; i++) {
      // debugger;
    			var highSchoolInfoString = data.high_schools[i].name 
    			+ " - " + data.high_schools[i].city + ", " + data.high_schools[i].state.abbreviation + " - " + data.high_schools[i].ceeb + " - " + data.high_schools[i].id;
    			highSchoolsArray.push(highSchoolInfoString)
    		};
        response(highSchoolsArray);
      }); 
	};



	$( "input#high-school-name-search").autocomplete({ 
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
	        $("#prospective_students_by_hs_button").prop('disabled', false)

	        $("#prospective_student_state option:contains(" + data.state_abbreviation + ")").prop("selected","selected").change();
	        $("#high-school-name-label").show();
					$("#high-school-name").text(data.name);
					$('#prospective_student_high_school_id').val(data.id);

					$("#high-school-address-label").show();
					$("#high-school-address").text(data.address);

					$("#high-school-city-label").show();
					$("#high-school-city").text(data.city);

					$("#high-school-state-label" ).show();
					$("#high-school-state").text(data.state_abbreviation);
      });
    }
  }).autocomplete( "instance" )._renderItem = function( ul, high_school ) {
  		var idTag = " <span class='id-tag'>" + high_school.value.split('').reverse().join('').slice(0, 6) + "</span>";
  		var highSchoolName = high_school.value.slice(0, -8)
      return $( "<li>" ).data( "high_school.autocomplete", high_school )
      									.text(highSchoolName )
								      	.append(idTag)
								        .appendTo( ul );
  };;

});

function getProspectiveStudentsById(){
	var recipients = [];
	for (var i = 0; i < $("input.emailCheckBox[type=checkbox]:checked").length; i++) {
		var checkedBox = $("input.emailCheckBox[type=checkbox]:checked")[i];
		recipients.push($(checkedBox).val())
	};
	$.ajax({
		type: "PUT",
		url: '/prospective_students/get_prospective_students_by_id', 
		dataType: 'json',
		data: { recipients: recipients},
		success: function(data){
			for (var i = 0; i < data.prospective_students.length; i++) {
				var tableBody = $("tbody#recipients");
				var row = $("<tr>").addClass('studentRow').attr('id', data.prospective_students[i].id );
				var name = $("<td>")
									 .addClass('hidden-xs')
									 .text(data.prospective_students[i].first_name + " " + data.prospective_students[i].last_name)
									 .appendTo(row);
				var email = $("<td>")
									 .text(data.prospective_students[i].email)
									 .appendTo(row);
				row.appendTo(tableBody);					 			 	
			};
		}
	});
}



