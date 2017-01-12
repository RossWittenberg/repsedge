$(document).on("page:load ready", function(){
	$('input#institution-search.new-user-institution-input').autocomplete({ 
	    source: get_institutions_by_location, 
	    minLength: 2,
	    select: function (event, ui) {
	      console.log(ui)
	      console.log(event)
	      params = { institution: ui.item.value }
	      $.get('/institutions/institution', 
	        params
	        ).success(function(data) {
	         console.log(data.name)
	         $('input#account_billing_street_address_line_1').empty().val(data.street_address);
	         $('input#account_billing_city').empty().val(data.city);
	         $('input#account_billing_zip_code').empty().val(data.zip_code);
	         $('select#county-state-search-input option[value='+data.state+']').prop("selected", "selected").change();
	      });
	    }
	  })

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
})	