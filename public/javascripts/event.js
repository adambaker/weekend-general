$(
  function()
  {
    var new_venue_form = $('<div/>').attr('id', 'new_venue_form')
      .prependTo('body').addClass('overlay').hide()
      .click(disappear_new_venue)
      .load(
        '/venues/new #content', 
        function()
        {
          $('#new_venue_form #content').attr('id', 'overlay_content')
            .click(function(e){e.stopPropagation();})
          ;
          $('#overlay_content a[href$="venues"]').click(disappear_new_venue);
          $('#new_venue').ajaxForm(
            {
              dataType: 'json',
              beforeSubmit: clear_errors,
              success: add_to_menu,
              error: show_errors
            }
          ).prepend($(error_div()).hide());
        }
      );
      
    var overlay_mask = $('<div/>').attr('id', 'overlay_mask')
      .height( $(document).height() ).hide().prependTo('body')
      .click(disappear_new_venue)
    ;
    $('#event_venue_id').closest('div')
      .append('<br/>').append(new_venue_button());
  }
);

function new_venue_button()
{
  var button = $('<input/>')
    .attr({type: 'submit', value: 'Add a Venue'})
    .addClass('new_venue_button')
    .click(drop_new_venue_div);
  return button;
}

function drop_new_venue_div(event)
{
  event.preventDefault();
  event.stopPropagation();
  
  $('#overlay_mask').show();

  $('#new_venue_form').effect('slide', {direction: 'up', mode: 'show'}, 'slow');
}

function disappear_new_venue(event)
{
  event.preventDefault();
  event.stopPropagation();

  var overlay_mask = $('#overlay_mask');
  if(!overlay_mask.data('disappearing'))
  {
    overlay_mask.data('disappearing', true);
    $('#new_venue_form')
      .effect(
        'slide', 
        {direction: 'up', mode: 'hide'}, 
        'slow',
        function ()
        {
          clear_errors();
          overlay_mask.hide();
          overlay_mask.removeData('disappearing');
        }
      )
    ;
  }
}

function show_errors(jqxhr, status, http_error)
{
  var errors = $.parseJSON(jqxhr.responseText);
  var num_errors = 0;
  for(var field in errors)
  {
    add_error('#venue_' + field);
    add_error('label[for="venue_' + field + '"]');
    num_errors += 1;
    $('#error_explanation ul').append(
      $('<li/>').text(field.capitalize() + ' ' + errors[field])
    );
  }
  $('#error_explanation h2').text(error_message(num_errors));
  $('#error_explanation').show();
}

function add_error(selector) 
{
  $(selector).wrap( $('<div/>').addClass('field_with_errors') );
}

function clear_errors()
{
  $('#error_explanation li').remove();
  $('#error_explanation h2').text('');
  $('#overlay_content .field_with_errors').replaceWith(
    function(){return $(this).contents()}
  );
  $('#error_explanation').hide();
}

function add_to_menu(data)
{
  venue = data.venue;
  $('#event_venue_id').append(
    $('<option/>').attr('value', venue.id)
      .text(venue.name + ' @ ' + venue.address)
  ).val(venue.id);
  $('#overlay_mask').click();
  $('#new_venue').resetForm();
}

function error_message(num_errors)
{
  return num_errors + (num_errors > 1 ? ' errors' : ' error') +
    ' prevented this venue from being saved:'
  ;
}

function error_div()
{
  return '<div id="error_explanation">' +
      '<h2 rip-style-bordercolor-backup="" style="" rip-style-borderstyle-backup="" rip-style-borderwidth-backup=""></h2>' + 
      '<p>There were problems with the following fields:</p>' +
      '<ul></ul>' +
    '</div>'
  ;
}
