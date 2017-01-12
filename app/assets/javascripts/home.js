$(document).ready(function(){ 
  $('form.add-note-from-dashboard').hide();
  $('a.add-note-from-dashboard').click(function(event){
    var form = $(this).next('form')
    var aTag = $(this)
    toggleDashboardAddNoteForm(event, form, aTag);
  });
  $('a.add-preferred-email-from-dashboard').click(function(event){
    var form = $(this).next('form')
    var aTag = $(this)
    toggleDashboardAddPreferredEmailForm(event, form, aTag);
  });
  if ($('#home-tabs').length > 0){
		$('#home-tabs').tabs({
      activate: function(event, ui) { 
        window.location.hash = ui.newTab.find('a').attr('href');
      }
    });
	};
  if ($('#admin-tabs').length > 0){
    $('#admin-tabs').tabs({
      activate: function(event, ui) { 
        window.location.hash = ui.newTab.find('a').attr('href');
      }
    });
  };
  
  deleteRepMessage();
  createRepMessage();
  updateRepMessage();
  errorRepMessage();

  $('.activate-edit-field').click(function(event) {
    $(this).parent().find('input.rep-email-input.current').removeProp('disabled');
    $(this).hide();
    $(this).parent().find($('button.update-rep')).show();
    $('input.rep-email-input.current').on('input propertychange paste', function() {
      $('button.update-rep').removeProp('disabled');
    });
  });  


  $("input[model-attribute='update-password']").prop('disabled', true).addClass('disabled');
  $("input[model-attribute='update-password_confirmation']").prop('disabled', true).addClass('disabled');
  $("label[model-attribute='update-password']").prop('disabled', true).addClass('disabled');
  $("label[model-attribute='update-password_confirmation']").prop('disabled', true).addClass('disabled');

  $('input#user_current_password').change(function(){ 
    if ($('input#user_current_password').val().length > 0){
      $("input[model-attribute='update-password']").prop('disabled', false).removeClass('disabled');
      $("input[model-attribute='update-password_confirmation']").prop('disabled', false).removeClass('disabled');
      $("label[model-attribute='update-password']").prop('disabled', false).removeClass('disabled');
      $("label[model-attribute='update-password_confirmation']").prop('disabled', false).removeClass('disabled');
    } else {
      $("input[model-attribute='update-password']").prop('disabled', true).addClass('disabled');
      $("input[model-attribute='update-password_confirmation']").prop('disabled', true).addClass('disabled');
      $("label[model-attribute='update-password']").prop('disabled', true).addClass('disabled');
      $("label[model-attribute='update-password_confirmation']").prop('disabled', true).addClass('disabled');
    }
  })


});

function createRep(event){
  var firstNameElement = $("input[model-attribute='first_name']");
  var firstName = firstNameElement.val();

  var lastNameElement = $("input[model-attribute='last_name']");
	var lastName = lastNameElement.val();

	var emailElement = $("input[model-attribute='email']");
  var email = emailElement.val();	

  $.ajax({
    url: "/reps/users/",
    type: "POST",
    data: {user: 
              { first_name: firstName,
                last_name: lastName,
              	email: email }
          } 
  }).error(function(data){
    if ( data.responseJSON.errors.first_name !== undefined ){
      console.log(data.responseJSON.errors.first_name[0]);
      firstNameElement.addClass('erroneous-input');
      firstNameElement.parent().find('.error-message').html(data.responseJSON.errors.first_name[0]);
      $("button").delay(5000).removeAttr("disabled").text('Add User');
    } else {
      firstNameElement.removeClass('erroneous-input');
      firstNameElement.parent().find('.error-message').empty();
      $("button").delay(5000).removeAttr("disabled").text('Add User');
    };

    if ( data.responseJSON.errors.last_name !== undefined ){
      console.log(data.responseJSON.errors.last_name[0]);
      lastNameElement.addClass('erroneous-input');
      lastNameElement.parent().find('.error-message').html(data.responseJSON.errors.last_name[0]);
      $("button").delay(5000).removeAttr("disabled").text('Add User');
    } else {
      lastNameElement.removeClass('erroneous-input');
      lastNameElement.parent().find('.error-message').empty();
      $("button").delay(5000).removeAttr("disabled").text('Add User');
    };
    
    if ( data.responseJSON.errors.email !== undefined ){
      console.log(data.responseJSON.errors.email[0]);
      emailElement.addClass('erroneous-input');
      emailElement.parent().find('.error-message').html(data.responseJSON.errors.email[0]);
      $("button").delay(5000).removeAttr("disabled").text('Add User');
    } else {
      emailElement.removeClass('erroneous-input');
      emailElement.parent().find('.error-message').empty();
      $("button").delay(5000).removeAttr("disabled").text('Add User');
    };
    $('form.new_user').find('input[type=submit]').prop('disabled', false);
    $("button").delay(5000).removeAttr("disabled").text('Add User');
  }).success(function(data){
    window.location.reload(true)
  });
};
function updateRep(event){
  console.log("updating rep");
  var firstNameElement = $("input[model-attribute='update-first_name']");
  var firstName = firstNameElement.val();

  var lastNameElement = $("input[model-attribute='update-last_name']");
  var lastName = lastNameElement.val();

  var phoneNumElement = $("input[model-attribute='update-phone_num']");
  var phoneNum = phoneNumElement.val();

  var emailElement = $("input[model-attribute='update-email']");
  var email = emailElement.val(); 

  var currentPasswordElement = $("input[model-attribute='update-current_password']");
  var currentPassword = currentPasswordElement.val();

  var passwordElement = $("input[model-attribute='update-password']");
  var password = passwordElement.val();

  var passwordConfirmationElement = $("input#user_password_confirmation");
  var passwordConfirmation = passwordConfirmationElement.val();

  var weeklyAgendaElement = $('input[name="user[weekly_agenda]"]:checked');
  var weeklyAgenda = weeklyAgendaElement.val();

  var timeZoneElement = $('select#user_time_zone');
  var timeZone = timeZoneElement.val();

  var userId = $('form.edit_user').attr('user-id');
  if (currentPassword.length > 0 && password.length > 0){
    var data = {user: 
              { first_name: firstName,
                last_name: lastName,
                phone_num: phoneNum,
                email: email,
                current_password: currentPassword,
                password: password,
                password_confirmation: passwordConfirmation,
                weekly_agenda: weeklyAgenda,
                time_zone: timeZone }
          }
  } else{
    var data = {user: 
              { first_name: firstName,
                last_name: lastName,
                phone_num: phoneNum,
                email: email,
                weekly_agenda: weeklyAgenda,
                time_zone: timeZone }
          }
  }
  $.ajax({
    url: "/users/",
    type: "PUT",
    data: data, 
  }).error(function(data){
    // debugger;
    console.log(data.responseJSON);
    var errorsBanner = $('.settings-errors-banner');
    if (data.responseJSON.errors !== undefined){
      errorsBanner.show();
      // First Name Errors
      if ( data.responseJSON.errors.first_name !== undefined ){
        console.log(data.responseJSON.errors.first_name[0]);
        firstNameElement.addClass('erroneous-input');
        firstNameElement.parent().find('.error-message').html(data.responseJSON.errors.first_name[0]);
      } else {
        firstNameElement.removeClass('erroneous-input');
        firstNameElement.parent().find('.error-message').empty();
      };
      // Last Name Errors
      if ( data.responseJSON.errors.last_name !== undefined ){
        console.log(data.responseJSON.errors.last_name[0]);
        lastNameElement.addClass('erroneous-input');
        lastNameElement.parent().find('.error-message').html(data.responseJSON.errors.last_name[0]);
      } else {
        lastNameElement.removeClass('erroneous-input');
        lastNameElement.parent().find('.error-message').empty();
      };
      // Phone Number Errors
      if ( data.responseJSON.errors.phone_num !== undefined ){
        console.log(data.responseJSON.errors.phone_num[0]);
        phoneNumElement.addClass('erroneous-input');
        phoneNumElement.parent().find('.error-message').html(data.responseJSON.errors.phone_num[0]);
      } else {
        phoneNumElement.removeClass('erroneous-input');
        phoneNumElement.parent().find('.error-message').empty();
      };
      // Email Errors
      if ( data.responseJSON.errors.email !== undefined ){
        console.log(data.responseJSON.errors.email[0]);
        emailElement.addClass('erroneous-input');
        emailElement.parent().find('.error-message').html(data.responseJSON.errors.email[0]);
      } else {
        emailElement.removeClass('erroneous-input');
        emailElement.parent().find('.error-message').empty();
      };
      // Current Password Errors
      if ( data.responseJSON.current_password_error && data.responseJSON.current_password_error.current_password_error !== undefined ){
        console.log(data.responseJSON.current_password_error.current_password_error);
        currentPasswordElement.addClass('erroneous-input');
        currentPasswordElement.parent().find('.error-message').html(data.responseJSON.current_password_error.current_password_error);
      } else if(data.responseJSON.errors.current_password !== undefined){
        currentPasswordElement.addClass('erroneous-input');
        currentPasswordElement.parent().find('.error-message').html(data.responseJSON.errors.current_password[0]);
      } else {
        currentPasswordElement.removeClass('erroneous-input');
        currentPasswordElement.parent().find('.error-message').empty();
      };
      // New Password Errors
      if ( data.responseJSON.errors.password !== undefined ){
        console.log(data.responseJSON.errors.password[0]);
        passwordElement.addClass('erroneous-input');
        passwordElement.parent().find('.error-message').html(data.responseJSON.errors.password[0]);
      } else if(data.responseJSON.errors.password !== undefined ){
        passwordElement.addClass('erroneous-input');
        passwordElement.parent().find('.error-message').html(data.responseJSON.errors.password[0]);
      } else {
        passwordElement.removeClass('erroneous-input');
        passwordElement.parent().find('.error-message').empty();
      };
      // New Password Confirmation Errors
      if ( data.responseJSON.errors.password_confirmation !== undefined ){
        console.log(data.responseJSON.errors.password_confirmation[0]);
        passwordConfirmationElement.addClass('erroneous-input');
        passwordConfirmationElement.parent().find('.error-message').html(data.responseJSON.errors.password_confirmation[0]);
      } else if(data.responseJSON.errors.password !== undefined ){
        passwordConfirmationElement.addClass('erroneous-input');
        passwordConfirmationElement.parent().find('.error-message').html(data.responseJSON.errors.password_confirmation[0]);
      } else {
        passwordConfirmationElement.removeClass('erroneous-input');
        passwordConfirmationElement.parent().find('.error-message').empty();
      };
    } else{
      errorsBanner.hide();
      $('form.new_user').find('input[type=submit]').prop('disabled', false);    console.log(data.responseJSON);
    };

  }).success(function(data){
    window.location.reload(true)
  });
};

function deleteRepMessage(){
  if ( $('.alert-destroy_user_message').length > 0 ){
    $.jGrowl( $('.alert-destroy_user_message p').text() , 
          {animateOpen:{
            height: 'show'
          },
          life: 20000,
          header: "User Deleted!",
          theme: "deleted",
    }); 
  };
};

function createRepMessage(){
  if ( $('.alert-create_user_message').length > 0 ){
    $.jGrowl( $('.alert-create_user_message p').text() , 
          {animateOpen:{
            height: 'show'
          },
          life: 20000,
          header: "New Rep Created",
          theme: "created",
    }); 
  };
};

function updateRepMessage(){
  if ( $('.alert-update_user_message').length > 0 ){
    $.jGrowl( $('.alert-update_user_message p').text() , 
          {animateOpen:{
            height: 'show'
          },
          life: 20000,
          header: "Updated",
          theme: "updated",
    }); 
  };
};

function errorRepMessage(){
  if ( $('.alert-error_user_message').length > 0 ){
    $.jGrowl( $('.alert-error_user_message p').text() , 
          {animateOpen:{
            height: 'show'
          },
          life: 20000,
          header: "Error",
          theme: "error",
    }); 
  };
};

function  toggleDashboardAddNoteForm(event, form, aTag){
  if ( form.hasClass('hidden') ){
    form.addClass('shown').removeClass('hidden').show();
    aTag.text(" Cancel")
  } else if (form.hasClass('shown')){
    form.addClass('hidden').removeClass('shown').hide();
    aTag.text(" Add a Note")
  }
}

function  toggleDashboardAddPreferredEmailForm(event, form, aTag){
  if ( form.hasClass('hidden') ){
    form.addClass('shown').removeClass('hidden').show();
    aTag.text(" Cancel")
  } else if (form.hasClass('shown')){
    form.addClass('hidden').removeClass('shown').hide();
    aTag.text(" Add an Email Contact")
  }
}


