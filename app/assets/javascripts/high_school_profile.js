$(document).on("page:load ready", function(){

  var datepicker = $.fn.datepicker.noConflict();
  $.fn.bootstrapDP = datepicker;   
  
  $('.datepicker').bootstrapDP({
      format: 'mm-dd-yyyy',
      autoclose: true
  });

  if ($('.alert-error_thank_you-profile') !== undefined ){
    reportErrorMessage();    
  }
 
  // css display none

  if (  ($('#ACTs-score').text() === "N/A") && ($('#SATs-score').text() === "N/A")   ){
    $('#testing-container').hide()
  }


  $('#add-preferred-phone-button').click(function(event) {
    $('#add-preferred-phone-button').hide();
    $('#new_preferred_phone').show();
    $('#cancel-add-preferred-phone-button').show()
  });

  $('#cancel-add-preferred-phone-button').click(function(event) {
    $('#add-preferred-phone-button').show();
    $('#cancel-add-preferred-phone-button').hide();
    $('#new_preferred_phone').hide();
  });

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //

  $('#add-preferred-guidance_website-button').click(function(event) {
    $('#add-preferred-guidance_website-button').hide();
    $('#cancel-add-preferred-guidance_website-button').show();
    $('#new_preferred_guidance_website').show();
  });

  $('#cancel-add-preferred-guidance_website-button').click(function(event) {
    $('#add-preferred-guidance_website-button').show();
    $('#cancel-add-preferred-guidance_website-button').hide();
    $('#new_preferred_guidance_website').hide();
  });

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //

  $('#add-preferred-email-button').click(function(event) {
    $('#add-preferred-email-button').hide();
    $('#cancel-add-preferred-email-button').show();
    $('#new_preferred_email').show();
  });

  $('#cancel-add-preferred-email-button').click(function(event) {
    $('#add-preferred-email-button').show();
    $('#cancel-add-preferred-email-button').hide();
    $('#new_preferred_email').hide();
  });

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //

  $('#add-preferred-calendar-button').click(function(event) {
    $('#add-preferred-calendar-button').hide();
    $('#cancel-add-preferred-calendar-button').show();
    $('#new_preferred_calendar').show();
  });

  $('#cancel-add-preferred-calendar-button').click(function(event) {
    $('#add-preferred-calendar-button').show();
    $('#cancel-add-preferred-calendar-button').hide();
    $('#new_preferred_calendar').hide();
  });

// put in each:

});

function reportErrorMessage(){
  if ( $('.alert-error_thank_you-profile').length > 0 ){
    $.jGrowl("Thank you for your feedback",
          {animateOpen:{
            height: 'show'
          },
          life: 20000,
          header: "Your message has been sent.",
          theme: "message_sent",
    }); 
  };
};

