// ajax.forms.js - Automatically hooks forms to be submitted async a la ajax
// These forms are denoted with a data-remote html attr
// If data-output is given, the result will be inserted into the given id of the element
$(function(){
  $('form[data-remote=true] input[type=submit]').click(function(data){
    console.log(data);
    var btn = $(this);
    var form = btn.parents('form');
    var data = form.serializeArray();

    // Indicate on button something is happening
    var old_text = btn.text();
    btn.attr('disabled', true).text('...');
    $.post(form.attr('action'), data)
      .success(function(response){
        btn.attr('disabled', false).text(old_text);
        if(output_id = form.data('output')) {
          // Insert response into DOM
          console.log(response);
          $('#' + output_id).html(response).addClass('alert').addClass('alert-success');
        }
      })
      .error(function(response){
        if(output_id = form.data('output')) {
          btn.attr('disabled', false).text(old_text).addClass('error');
          // Insert response into DOM
          console.log(response.responseText);
          $('#' + output_id).html(response.responseText).addClass('alert').addClass('alert-error');
        }
      });
    return false; // prevent default behaviour
  });
});