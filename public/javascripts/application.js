// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(
  function()
  {
    var $search_bar = $("#small_search_text");
    $search_bar.focus(
      function()
      { 
        if($search_bar.attr('value') == "search")
          $search_bar.attr("value", "");
      }
    );
    $search_bar.blur( 
      function()
      {
        if($search_bar.attr('value') == "") 
          $search_bar.attr("value","search");
      }
    );
    
    $('.extra_options').hide().each(
      function()
      {
        var extra = $(this);
        $('<a></a>').attr('href', '#').text('show extra options').click(
          function(event)
          {
            var toggle_link = $(this)
            extra.slideToggle(400, 
              function()
              {
                if(/^show/.test(toggle_link.text()))
                  toggle_link.text('hide extra options');
                else
                  toggle_link.text('show extra options');
              }
            );
          }
        ).insertAfter(extra);
      }
    );
  }
);

function ajax_submit_button(button_set, ajax_success)
{
  button_set.each(
    function()
    {
      var button = $(this);
      if (button.hasClass('hidden'))
        button.removeClass('hidden').hide();
      
      var form = button.closest('form.button_to');
      
      button.click(
        function(event)
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
            success: ajax_success
          });
        }
      );
    }
  );//each matching button
}

function revise_header(list, change, prefix)
{
  if(typeof prefix == 'undefined')
    prefix = '';
  var header = $('h3', list);
  var new_title = repluralize(header.text().slice(prefix.length), change);
  header.html(prefix + new_title);
  
  if(new_title.charAt(0) == '0')
    list.addClass('hidden');
}

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

