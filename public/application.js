(function() {
  var drawReadingsChart = function(readingsChart) {
    Highcharts.chart(readingsChart, {
      chart: {
        type: 'line'
      },
      data: {
        csvURL: window.location.origin + readingsChart.getAttribute('data-chart-data-uri')
      },
      yAxis: {
        title: null
      },
      title: {
        text: null
      }
    })
  }

  var readingsCharts = Array.prototype.slice.call(document.getElementsByClassName('readings-chart'));

  if (readingsCharts) {
    readingsCharts.forEach(function(readingsChart) {
      drawReadingsChart(readingsChart);
    });
  }

  var drawAlarms = function(alarms) {
    var outlet = document.getElementById('unresolved-alarms');
    var placeholder = document.createElement('div')
    if (alarms.length == 0) {
      var div = document.createElement('div');
      div.setAttribute('class', 'card-body');
      div.appendChild(document.createTextNode('No alarms'));
      placeholder.appendChild(div);
    } else {
      alarms.forEach(function(alarm) {
        var alarmDiv = document.createElement('div');
        alarmDiv.setAttribute('class', 'card-body table-danger text-danger');
        var alarmLink = document.createElement('a');
        alarmLink.setAttribute('href', alarm.href);
        alarmLink.appendChild(document.createTextNode(alarm.serial_number));
        alarmLink.appendChild(document.createTextNode(': '));
        alarmLink.appendChild(document.createTextNode(alarm.name));
        alarmDiv.appendChild(alarmLink);
        placeholder.appendChild(alarmDiv);
      });
    }

    while(outlet.firstChild) { outlet.firstChild.remove() }
    outlet.appendChild(placeholder);
  }

  var pollAlarmUpdate = function() {
    unresolvedAlarms = JSON.parse(this.response);
    drawAlarms(unresolvedAlarms);
  }

  var pollAlarms = function() {
    var request = new XMLHttpRequest();
    request.addEventListener('load', pollAlarmUpdate);
    request.open("GET", window.location.origin + "/alarms/unresolved");
    request.send();
  }

  window.setInterval(pollAlarms, 5000);

  pollAlarms();
}).call(this);
