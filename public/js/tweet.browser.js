// tweet.browser.js
$(function(){
  var month_names = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  var tweets_ele = $('#tweets');
  var years_ele = $('#years');
  var months_ele = $('#months');
  var days_ele = $('#days');

  $('.year').click(function(){
    var el = $(this);
    var year = $(this).text();

    // Indicate selected year
    el.addClass('selected').siblings().removeClass('selected');

    // Record selected year in #years' data
    years_ele.data('year', year);

    $.get(document.URL + '/year/' + year + '/months', function(months){
      var html = "";

      // Build injected HTML with availible months
      months.forEach(function(month){
        html += "<h3 class='month' data-month_number='" + month + "'>" + month_names[month] + "</h3>"
      });

      // Display months
      months_ele.removeClass('hidden').html(html);

      // Clear days
      days_ele.addClass('hidden').html('');

      // Bind month behaivour to newly created months
      $('.month').click(month_click);
    })
    return false; // disable default behaviour
  });

  function month_click(eventObject){
    var el = $(eventObject.currentTarget);
    var year = years_ele.data('year');
    var month = el.data('month_number');

    // Indicate selected year
    el.addClass('selected').siblings().removeClass('selected');

    // Record selected month in #months' data
    months_ele.data('month', month);

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
      days_ele.removeClass('hidden').html(html);

      // Bind day behaivour to newly created days
      $('.day').click(day_click);
    })
    return false; // disable default behaviour
  }

  function day_click(eventObject){
    var el = $(eventObject.currentTarget);
    var day = el.data('day_number');
    var month = months_ele.data('month');
    var year = years_ele.data('year');

    // Indicate selected day
    el.addClass('selected').siblings().removeClass('selected');

    // Record selected day in #days' data
    days_ele.data('day', day);

    $.post(
      document.URL + '/tweets_for_date',
      { day: day, month: month, year: year },
      function(tweets){
        process_tweets(tweets, false);
      }
    );
  }

  // Converts JSON Tweets to HTML and inserts them into #tweets
  // If append is true, keep inserting tweets
  function process_tweets(tweets, append){
    var html = "";

    if (append) {
      html = tweets_ele.html();
    }

    tweets.forEach(function(tweet){
      html += '<div class="tweet">';
        html += tweet.text;
        html += '<br>';
        html += '<em>' + tweet.created_at + '</em>';
      html += '</div>';
      html += '<hr>';
    });
    tweets_ele.html(html);
  }

  // Determine pixel height constraint of how many tweets to load at a time
  function calculate_fill_size(){
    var viewport_height = $(window).height();
    var navbar_height = $('.navbar').height();
    var fill_factor = 2;
    fill_size = (viewport_height - navbar_height) * fill_factor;
  }
  var fill_size;
  calculate_fill_size();

  // Account for viewport size changes
  $(window).resize(function() {
    calculate_fill_size();
  });


  // Loads enought Tweets to fill (1.5 * viewport height)
  function load_tweet_page(){
    var start_year = years_ele.data('year');
    var start_month = months_ele.data('month');
    var start_day = days_ele.data('day');

    $.get(document.URL + '/year/' + start_year + '/month/' + start_month + '/days', function(dateMaps){
      load_dateMap_recursive(dateMaps, 0);
    });
  }

  // Insert Tweets for each dateMap until fill size reached
  function load_dateMap_recursive(dateMaps, index){
    var dateMap = dateMaps[index];
    var current_day = dateMap.id.day;
    var current_month = dateMap.id.month;
    var current_year = dateMap.id.year;

    $.post(
      document.URL + '/tweets_for_date',
      { day: current_day, month: current_month, year: current_year },
      function(tweets) {
        process_tweets(tweets, true);
        
        // Keep rendering if under fill size and dateMaps left
        console.log(tweets_ele.height());
        var tweets_height = tweets_ele.height();
        if (tweets_height < fill_size && ++index < dateMaps.length) {
          load_dateMap_recursive(dateMaps, index);
        } else {
          tweets_ele.data('last_dateMap');
        }
      }
    );
  }

  // Scroll event handler
  // Upon nearing end of scrollable area, load more tweets
  var doc = $(document);
  $(window).scroll(function(){
    var win = $(this);
    console.log(win.scrollTop()/tweets_ele.height());
    if ($(document).height() <= ($(window).height() + $(window).scrollTop())) console .log('yay!');
    if ( win.scrollTop() / tweets_ele.height() > 0.8 ) {
      console.log('load page!');
    }
  });

  // Development Buttons

  $('#loadpage').click(function(){
    load_tweet_page();
  });

  $('#clear').click(function(){
    tweets_ele.html('');
  });

  $('#count').click(function(){
    alert($('#tweets .tweet').length);
  });
});