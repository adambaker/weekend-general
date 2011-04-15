$(function()
  {
    ajax_submit_button($('form.button_to input.track'), 
      function(trail)
      {
        var button;
        var prev_button;
        var change;
        var tracker_list = $('ul.track.trackers');
        
        if (trail.track == 'false')
        {
          button = $('form.button_to input.track[value=Untrack]');
          prev_button = $('form.button_to input.track[value=Track]');
          $('li:contains('+trail.user_name+')', tracker_list).detach();
          change = -1;
        }
        else
        {
          button = $('form.button_to input.track[value=Track]');
          prev_button = $('form.button_to input.track[value=Untrack]');
          user = $('<li></li>')
            .html('<a href="'+trail.user_path+'">'+trail.user_name+'</a>');
          change = 1;
          tracker_list.append(user).removeClass('hidden');
        }
        revise_header(tracker_list, change, 'Tracked by ');
        button.attr('disabled', false);
        button.hide(); 
        prev_button.show();
      }
    );
  }
);

