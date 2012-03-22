// tweet.browser.js
$(function(){
  month_names = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

  $('.year').click(function(){
    var el = $(this);
    var year = $(this).text();

    // Indicate selected year
    el.addClass('selected').siblings().removeClass('selected');

    // Record selected year in #years' data
    $('#years').data('year', year);

    $.get(document.URL + '/year/' + year + '/months', function(months){
      var html = "";

      // Build injected HTML with availible months
      months.forEach(function(month){
        html += "<h3 class='month' data-month_number='" + month + "'>" + month_names[month] + "</h3>"
      });

      // Display months
      $("#months").removeClass('hidden').html(html);

      // Clear days
      $("#days").addClass('hidden').html('');

      // Bind month behaivour to newly created months
      $('.month').click(month_click);
    })
    return false; // disable default behaviour
  });

  month_click = function(eventObject){
    var el = $(eventObject.currentTarget);
    var year = $('#years').data('year');
    var month = el.data('month_number');

    // Indicate selected year
    el.addClass('selected').siblings().removeClass('selected');

    // Record selected month in #months' data
    $('#months').data('month', month);

    $.get(document.URL + '/year/' + year + '/month/' + month + '/days', function(dateMaps){
      var html = "";

      // Build injected HTML with availible days
      dateMaps.forEach(function(dateMap){
        var day = dateMap.id.day;
        var tweets = dateMap.value.tweet_count;
        // Days are incremeted by 1 to convert from machine -> human
        html += "<h4 class='day' data-day_number='" + day + "'>" + (day + 1) + "</h4>";
        html += "<div class='tweet_count'>(" + tweets + ")</div>"
      });

      // Display days
      $("#days").removeClass('hidden').html(html);

      // Bind day behaivour to newly created days
      $('.day').click(day_click);
    })
    return false; // disable default behaviour
  }

  day_click = function(eventObject){
    var el = $(eventObject.currentTarget);
    var day = el.data('day_number');
    var month = $('#months').data('month');
    var year = $('#years').data('year');

    // Indicate selected day
    el.addClass('selected').siblings().removeClass('selected');

    // Record selected day in #days' data
    $('#days').data('day', day);

    $.post(
      document.URL + '/tweets_for_date',
      { day: day, month: month, year: year },
      process_tweets
    );
  }

  process_tweets = function(tweets){
    var html = "";
    tweets.forEach(function(tweet){
      html += tweet.text;
      html += '<br>';
      html += '<em>' + tweet.created_at + '</em>';
      html += '<hr>';
    });
    $('#tweets').html(html);
  }
});