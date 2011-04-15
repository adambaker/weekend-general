$(
  function()
  {
    $('ul.links li').not(':has(input[name*=links_attributes][value])').remove();
    attach_link();
  }
);

var empty_link = $('<li></li>');
$('<div></div>').addClass('field')
  .append($('<label></label>'))
  .append($('<br />'))
  .append($('<input type="text" />'))
  .appendTo(empty_link)
  .after(' ')
  .clone()
    .appendTo(empty_link);
$('<a href="#">Remove Link</a>').click(
  function(event)
  {
    $(this).closest('li').remove();
    event.preventDefault();
    event.stopPropagation();
  }
).appendTo(empty_link);

var add_link = $('<a href="#">Add another link</a>').click(
  function(event)
  {
    attach_link();
    event.preventDefault();
    event.stopPropagation();
  }
);

function attach_link()
{
  add_link.detach();
  var links = $('ul.links');
  var id_prefix = 'event_links_attributes_' + $('li', links).length + '_';
  var name_prefix = 'event[links_attributes][' + $('li', links).length + ']';
  
  var new_link = empty_link.clone(true);
  $('label', new_link)
    .first()
      .attr('for', id_prefix+'url')
      .text('Url')
    .end()
    .slice(1)
      .attr('for', id_prefix+'text')
      .text('Text')
  ;
  $('input', new_link)
    .first()
      .attr('id', id_prefix+'url').attr('size', 30)
      .attr('name', name_prefix+'[url]')
    .end()
    .slice(1)
      .attr('id', id_prefix+'text').attr('size', 30)
      .attr('name', name_prefix+'[text]').addClass('link_text')
  ;
  
  links.append(new_link);
  links.append(add_link);
}
