var classes = {attend: 'attendees', host: 'hosts', maybe: 'maybes'};

$(
  function()
  {
    ajax_submit_button($('form.button_to input.rsvp'), 
      function(rsvp)
      {
        var button = $('input.rsvp.'+rsvp.new_rsvp);
        button.attr('disabled', false);
        button.hide();
        var user;
        if (rsvp.prev_rsvp != 'none')
        {
          var rsvp_class = classes[rsvp.prev_rsvp];
          revise_header($('ul.rsvp.' + rsvp_class), -1);
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
          revise_header($('ul.rsvp.' + rsvp_class), 1);
          $('ul.rsvp.' + rsvp_class).first()
            .append(user).removeClass('hidden');
        }
        
        //show button for previous rsvp
        $('input.rsvp.' + rsvp.prev_rsvp).show();
      }
    );//ajax_submit_button
  }
);//document ready handler
