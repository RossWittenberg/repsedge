function initSavedSearch(){
  $("#save-current-search-button").click(function(){
    saveSearch(  $(this).attr('user') );
  });

  $('button#save-current-search').click(function() {
    showSaveSearchModal($(this).attr('user'));
  });
};  
// rename function -  doesn't show modal
function showSaveSearchModal(userID){
  var state = $('#county-state-search-input :selected').text() || $('#state-search-input :selected').text() || "N/A"
  var county = $('#county-search-input :selected').text() || "N/A";
  var city_query = $('input#city-search').val() || "N/A"
  var hs_type = $('#hs_type-filter :selected').text();
  var classification = $('#classification-filter :selected').text();
  var capstone = $('#capstone-filter :checked').val() || "false";
  var intl_bacc = $('#intl_bacc-filter :checked').val() || "false";
  var boarding = $('#boarding-filter :checked').val() || "false";
  var magnet = $('#magnet-filter :checked').val() || "false";
  var charter = $('#charter-filter :checked').val() || "false";
  var religion = $('#religion-filter :selected').text();
  var students_total = $('#students_count-filter :selected').text();
  var gender = $('#gender-filter :selected').text();
  var diversity = $('#diversity-filter :selected').text();
  var four_year_school = $('#four_year_school-filter :selected').text();
  var graduation_rate = $('#graduation_rate-filter :selected').text();
  var median_income = $('#median_income-filter :selected').text();
  var reduced_lunch = $('#reduced_lunch-filter :selected').text();
  var act = $('#act-filter :selected').text();
  var sat_total = $('#sat_total-filter :selected').text();  
  var user_id = userID;


  // seperate this out...
  // make sure to allow for custom description...
  // var description = "state: " + state
  //                 + ", county: " + county
  //                 + ", city: " + city_query
  //                 + ", type: " + hs_type
  //                 + ", classification: " + classification
  //                 + ", capstone: " + capstone
  //                 + ", intl_bacc: " + intl_bacc
  //                 + ", boarding: " + boarding
  //                 + ", magnet: " + magnet
  //                 + ", religion: " + religion
  //                 + ", number of students: " + students_total
  //                 + ", gender: " + gender
  //                 + ", diversity: " + diversity
  //                 + ", % attend 4-year school: " + four_year_school
  //                 + ", graduation rate: " + graduation_rate
  //                 + ", median income: " + median_income
  //                 + ", % free or reduced lunch: " + reduced_lunch
  //                 + ", SAT avg: " + sat_total
  //                 + ", ACT avg: " + act

  $('#saved-search-description-content').attr('placeholder', 'name your search')
  $('#saved-search-state-content').text(state);
  $('#saved-search-county-content').text(county);
  $('#saved-search-city-content').text(city_query);
  $('#saved-search-hs_type-content').text(hs_type);
  $('#saved-search-classification-content').text(classification);
  $('#saved-search-capstone-content').text(capstone);
  $('#saved-search-intl_bacc-content').text(intl_bacc);
  $('#saved-search-boarding-content').text(boarding);
  $('#saved-search-magnet-content').text(magnet);
  $('#saved-search-charter-content').text(charter);
  $('#saved-search-religion-content').text(religion);
  $('#saved-search-students_total-content').text(students_total);
  $('#saved-search-gender-content').text(gender);
  $('#saved-search-diversity-content').text(diversity);
  $('#saved-search-students_total-content').text(students_total);
  $('#saved-search-four_year_school-content').text(four_year_school);
  $('#saved-search-graduation_rate-content').text(graduation_rate);
  $('#saved-search-median_income-content').text(median_income);
  $('#saved-search-reduced_lunch-content').text(reduced_lunch);
  $('#saved-search-act-content').text(act);
  $('#saved-search-sat_total-content').text(sat_total);
};

function saveSearch(userID){
  var name = $('#saved-search-name-content').val();
  $.ajax({
    url: "/users/"+userID+"/saved_searches",
    type: "POST",
    data: {saved_search: 
              { name: name,
                query_string: window.location.href,
                user_id: userID
            }
          } 
  }).success(function(data){
    console.log("search saved successfully");
    $('#save-search-modal').modal('hide');
  }).error(function(data) {
    console.log(data)
    var nameElement = $('#saved-search-name-content')
    if ( data.responseText !== undefined ){
      console.log(data.responseText);
      nameElement.addClass('erroneous-input');
      $('.saved-search-param-container.name').find('.error-message').html(data.responseText);
    } else {
      nameElement.removeClass('erroneous-input');
      nameElement.parent().find('.error-message').empty();
    };
    return false
  });
};
