$(function(){
  $.getJSON('http://github.com/api/v2/json/commits/list/adambaker/weekend-general/master?callback=?',
    function(data)
    {
      console.log(data.commits.length);
      commits = data.commits.slice(0, 5);
      var github_info = $('#github_info')
        .append('<h2>Follow the Weekend General\'s evolution</h2>');
      var github_info_list = $('<ul></ul>').appendTo(github_info);
      
      $.each(commits, function(index, commit){
        var commit_list = $('<li><a href="https://github.com' + 
            commit.url + '">'+commit.committed_date+'</a></li>')
          .appendTo(github_info_list);
        commit_list = $('<ul></ul>').appendTo(commit_list);
        
        commit_list
          .append('<li><strong>Author:</strong> '+commit.author['name']+'</li>')
          .append('<li><strong>Message:</strong><br/>' +
            commit['message'] + '</li>');
      });
    }
  );
});
