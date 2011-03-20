// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready( function()
  {
    var $search_bar = $("#small_search_text");
    $search_bar.focus(function()
      { 
        if($search_bar.attr('value') == "search")
          $search_bar.attr("value", "");
      }
    );
    $search_bar.blur( function()
      {
        if($search_bar.attr('value') == "") 
          $search_bar.attr("value","search");
      }
    );
  }
);

