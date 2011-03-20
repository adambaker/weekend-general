var classes = {attend: 'attendees', host: 'hosts', maybe: 'maybes'};

$(function()
{
  $('form.button_to input.rsvp').each(function()
  {
    var button = $(this);
    if (button.hasClass('hidden'))
      button.removeClass('hidden').hide();
    
    var form = button.parents('form.button_to').first();
    
    button.click(function(event)
    {
      event.preventDefault();
      event.stopPropagation();
      button.attr('disabled', true);
      
      var data = { 'authenticity_token': 
          $("input[name='authenticity_token']", form).attr('value')};
      var method = $("input[name=_method]", form);
      if(method.length > 0)
        data['_method'] = method.attr('value');

      $.ajax(
      {
        data: data,
        type: form.attr('method'),
        url: form.attr('action'),
        dataType: 'json',
        success: function(rsvp)
        {
          button.attr('disabled', false);
          button.hide();
          var user;
          console.log(rsvp);
          if (rsvp.prev_rsvp != 'none')
          {
            var rsvp_class = classes[rsvp.prev_rsvp];
            revise_header(rsvp_class, -1);
            user = $('ul.rsvp.' + rsvp_class + ' li:contains(' 
              + rsvp.user_name + ')').detach(); 
          }
          else
          {
            user = $('<li></li>')
              .html('<a href="'+rsvp.user_path+'">'+rsvp.user_name+'</a>');
          }
          
          if (rsvp.new_rsvp != 'none')
          {
            var rsvp_class = classes[rsvp.new_rsvp];
            revise_header(rsvp_class, 1);
            $('ul.rsvp.' + rsvp_class).first()
              .append(user).removeClass('hidden');
          }
          
          //show button for previous rsvp
          $('input.rsvp.' + rsvp.prev_rsvp).show();
        }//success callback
      });//ajax
    });//click handler*/
  });//each rsvp button
});//document ready handler

function repluralize(counted_string, change)
{
  var parts = counted_string.split(' ');
  var number = parseInt(parts[0]);
  var new_number = number + change;
  var word = parts[1];
  
  if(new_number == 1 && change != 0)
    word = word.slice(0, -1);
  else if(number == 1 && change != 0)
    word += 's';
    
  return new_number + ' ' + word;
}

function revise_header(rsvp_class, change)
{
  var list = $('ul.rsvp.'+rsvp_class);
  var header = $('h3', list);
  var new_title = repluralize(header.text(), change);
  header.html(new_title);
  
  if(new_title.charAt(0) == '0')
    list.addClass('hidden');
}
