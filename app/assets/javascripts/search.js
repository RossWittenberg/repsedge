function initSearch(){

  alertSearchMessage();
  $('#scroll-to-top').hide();
  
  $('#scroll-to-top').click(function() {
    scrollToTop();
  }); 

  if ($('.alert-missing') !== undefined ){
    reportMissingMessage();    
  }

  $("#search-tabs").tabs({
    activate: function(event, ui) { 
        window.location.hash = ui.newTab.find('a').attr('href');
      }
  }); // UJS
  $('#results-tabs').tabs({
    activate: function(event, ui) { 
        window.location.hash = ui.newTab.find('a').attr('href');
      }
  }); // UJS

  $('#clear-filters-button').click(function() {
    clearFilters();
  });

  // city search
  $('#city-search-button').addClass('disabled').prop('disabled', true);
  $('#state-search-input').change(function(event) {
    if ( $('#state-search-input').length > 0 && $('#state-search-input').val().length !== 2 ){
      $('#city-search-button').addClass('disabled').prop('disabled', true);
    };  
  });

  $( "#city-search" ).autocomplete({ 
    source: get_schools_by_location, 
    minLength: 2
  }); 

  // UJS

  $('#state-search-input').change(function() {
    if ( $('#state-search-input').val().length === 2  ){
      console.log("state selected...")
      $('#city-search-button').removeClass('disabled').prop('disabled', false);
    } else {
      $('#city-search-button').addClass('disabled').prop('disabled', true);
    };
  });

  // name or ceeb search

  $('#name-or-ceeb-search-button').addClass('disabled').prop('disabled', true);

  $( "#admin-name-search" ).autocomplete({ 
    source: get_schools_by_name, 
    minLength: 3
  }).autocomplete( "instance" )._renderItem = function( ul, high_school ) {
      preventKeySubmit();
      return $( "<li>" )
        .data( "high_school.autocomplete", high_school )
        .append($('<a>').attr('href', '/admin/high_schools/'+high_school.id+'/edit')
                        .text(high_school.name 
                        + " - " 
                        + high_school.city 
                        + ", " 
                        + high_school.state.abbreviation 
                        + " - " 
                        + high_school.ceeb) ) 
        .appendTo( ul );
  };



  
  $( "#name-search" ).autocomplete({ 
    source: get_schools_by_name, 
    minLength: 3
  }).autocomplete( "instance" )._renderItem = function( ul, high_school ) {
      preventKeySubmit();
      return $( "<li>" )
        .data( "high_school.autocomplete", high_school )
        // .append($('<a>').attr('href', 'https://projects.invisionapp.com/share/Z72XOOVMX#/screens')
        //                 .text(high_school.name 
        //                 + " - " 
        //                 + high_school.city 
        //                 + ", " 
        //                 + high_school.state 
        //                 + " - " 
        //                 + high_school.ceeb) )


        .append($('<a>').attr('href', '/high_schools/'+high_school.id)
                        .text(high_school.name 
                        + " - " 
                        + high_school.city 
                        + ", " 
                        + high_school.state.abbreviation 
                        + " - " 
                        + high_school.ceeb) ) 
        .appendTo( ul );
  };// UJS

// consider caching DOM element --> set element to variable
  $('#name-search').on('input', function() {
    if ($('#name-search').val().length === 0 ){
      $('#name-or-ceeb-search-button').addClass('disabled').prop('disabled', true);
    } else {
      $('#name-or-ceeb-search-button').removeClass('disabled').prop('disabled', false);
    }
  });  

  // county search

  getCountiesFromParams();
  getCountiesStateChange();

};

function get_schools_by_name(request, response){
  var params = {name_or_ceeb_query: request.term};
  $.getJSON(
    "/high_schools/name_or_ceeb_query_auto_complete",
    params 
    ).done(function(data){
        response(data.high_schools)
      }); 
};

function get_schools_by_location(request, response){
  var params = {city_query: request.term, state: $('#state-search-input').val()};
  $.getJSON(
    "/high_schools/city_auto_complete",
    params 
    ).done(function(data){
        response(data.high_schools)
      }); 
};

function getCountiesStateChange(){
  $('#county-state-search-input').change(function(){
    if ( $('#county-state-search-input').length > 0){
      if ( $('#county-state-search-input').val().length === 2  ){
        getCounties();
      } else {
        if ($('.index-search-button').length > 0){
          $('.index-search-button').addClass('disabled').prop('disabled', true);
        } else {
          $('#county-search-button').addClass('disabled').prop('disabled', true);
        };  
      };
    };  
  }); 
};

function getCountiesFromParams(){
  // change to 'not equal'
  if ($('#county-state-search-input').length > 0 && $('#county-state-search-input').val().length === 2  ) {
    getCounties();
  } else {
    $('#county-search-button').addClass('disabled').prop('disabled', true);
  };
};

function getCounties(){
  if ($('#county-state-search-input').val() === ""){
    if ($('.index-search-button').length > 0){
      $('.index-search-button').addClass('disabled').prop('disabled', true);
    } else {
      $('#county-search-button').addClass('disabled').prop('disabled', true);
    }
  } else {
    // change url to 'counties'
    $.get( "/high_schools/get_counties", 
      { state: $('#county-state-search-input').val() } ) 
    .done(function(data){
      $('#state-county-filter-county select').empty();
      $('select#county-search-input').prepend($('<option>', {
        value: "",
        text: "ALL" } ) );


      for (var i = 0; i < data.counties.length; i++) {
        $('select#county-search-input').append($('<option>', {
        value: data.counties[i],
        text: data.counties[i] } ) );
      }; 
      setCounty(); 
    });
  $('#county-filter').show();
  $('#county-search-button').removeClass('disabled').prop('disabled', false);
  }; 
};  

// use library to serialize params - lightweight packages available
function setCounty(){
  if (getUrlParameter('county') && getUrlParameter('county').length > 0) {
    var county = getUrlParameter('county').replace('+', ' ')
    $('select#county-search-input').select2("val", county); 
    $("#county-search-input option[value="+"'"+county+"'"+"]").prop('selected', 'selected')
  } else if ($('select#county-search-input').attr('county') && $('select#county-search-input').attr('county').length >0 ){
    var county = $('select#county-search-input').attr('county');
    $('select#county-search-input').select2("val", county); 
    $("#county-search-input option[value="+"'"+county+"'"+"]").prop('selected', 'selected')
  }; 
};   

function clearFilters(){

  $('select').select2();
  $('select.filter_drop_down').select2("val", "ALL");

  $('#high_school_students_count').select2('val', '0..50000');

  $('#high_school_percent_white').select2('val', '0..100');

  $('#high_school_graduation_rate').select2('val', '0..100');

  $('#high_school_median_income').select2('val', '0..9999999');

  $('#high_school_reduced_lunch').select2('val', '0..100');

  $('#high_school_act').select2('val', '0..36');

  $('#high_school_sat_total').select2('val', '0..2400');

  $('.filter_drop_down').each(function(i, obj) {
    $(obj[0]).prop('selected', 'selected')
  });

  $('.checkbox').prop('checked', false);
}

function getUrlParameter(sParam)
{
    var sPageURL = window.location.search.substring(1);
    var sURLVariables = sPageURL.split('&');
    for (var i = 0; i < sURLVariables.length; i++) 
    {
        var sParameterName = sURLVariables[i].split('=');
        if (sParameterName[0] == sParam) 
        {
            return sParameterName[1];
        }
    }
} 


$(window).on('scroll', function() {
  $topOffset = $(this).scrollTop();
  var scrollToTopDiv = $('#scroll-to-top');
  var savedSearchesTab = $('.ui-tabs-nav');
  if ( $topOffset > 1325 ){
    scrollToTopDiv.show();
    $(savedSearchesTab).click(function(event) {
      scrollToTop()
    });
  } else if ( $topOffset < 1325 ){
    scrollToTopDiv.hide();
    $(savedSearchesTab).off('click');
  }  
});


function scrollToTop(){
  $('html,body').animate({scrollTop: 0}, 500);
};


  // $('select').change(function () {
  //   console.log('select changed')
  //   var selectedOption = $(this).children('option:selected').text();
  //   if ( selectedOption.length > 18) {
  //    $(this).children('option:selected').text(selectedOption.substring(0, 15) + '...')   
  //   }
  // });

function reportMissingMessage(){
  if ( $('.alert-missing').length > 0 ){
    $.jGrowl( $('.alert-missing p').text() , 
        {animateOpen:{
          height: 'show'
        },
        life: 20000,
        header: "Your message has been sent.",
        theme: "message_sent",
    }); 
  };
};

function alertSearchMessage(){
  if ( $('.alert-search').length > 0 ){
    $.jGrowl( $('.alert-search p').text() , 
        {animateOpen:{
          height: 'show'
        },
        life: 20000,
        header: "Please Try Again.",
        theme: "message_sent",
    }); 
  };
};

function preventKeySubmit(){
  $(document).on("keypress", 'form', function (e) {
    var code = e.keyCode || e.which;
    if (code == 13) {
        e.preventDefault();
        return false;
    }
  });
}



  
