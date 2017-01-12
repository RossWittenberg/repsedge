$(function() {
	initNotes();
  $("button.edit-note-button").click(function(e) {
    console.log("edit note button pressed");
    var updateButton = $(this).parent().find(".update-note-button");
    var editInput = $(this).parent().find(".update-note");
    var noteContent = $(this).parent().find("p.note-content");
    noteContent.hide();
    updateButton.removeProp('disabled').show();
    editInput.removeProp('disabled').show();
    $(this).hide();
  });
});
function initNotes(){	
	$( "input#notes-hs-name-search" ).autocomplete({ 
    source: get_schools_by_name, 
    minLength: 2
  }).autocomplete( "instance" )._renderItem = function( ul, high_school ) {
      return $( "<li>" )
        .data( "high_school.autocomplete", high_school )
        .append($('<a>').attr('href', '/users/'
						+high_school.user_id+
						'/high_schools/'+
						high_school.id+
						'/notes')
                        .text(high_school.name 
                        + " - " 
                        + high_school.city 
                        + ", " 
                        + high_school.state.abbreviation 
                        + " - " 
                        + high_school.ceeb) ) 
        .appendTo( ul );
  };

  $('.update-note-button, .update-note').hide();

	$('button#notes-keyword-search-button').click(function(){
		console.log("notes keyword search clicked");
		keyWordSearch( $(this).attr('user-id') );
	});
}
function keyWordSearch(userId){
	var keywordQuery = $('input#notes-hs-keyword-search').val()
	var url = "/users/"+userId+"/high_schools/keyword_search"
	$.ajax({
    url: url,
    data: {keyword_query:  keywordQuery,
    			 user_id: userId }
  }).success(function(data){
    document.body.innerHTML = data
    initNotes();
  }).error(function(data){
  });
}
