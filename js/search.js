$(document).ready(function () {
    $("#sbox").keyup(function (event) {
        if (event.keyCode == 13) {
            getList();
        }
    });
});

//function getList() {
//    $.ajax({
//        type: "GET",
//        url: "results.xqy",
//        contentType: 'text/xml',
//        data: {
//            query: "asthma"
//        },
//        dataType: "xml",
//        success: function (xml) {
//            var xx = $(xml).find("response");
//            $("#results").html($(xml).find("response").documentElement.innerHTML);
//        },
//        error: function (jqXHR, textStatus, errorThrown) {
//            alert(textStatus);
//        }
//    });
//};

function updateList() {
  if (http.readyState == 4) {
      $("#wo").html(http.responseText);
      isWorking = false;
  }
}
 
function getList() {
  if (!isWorking && http) {
    var q = $("#sbox").attr("value");
    http.open("GET", "results-testing.xquery?query=" + q, true);
    http.onreadystatechange = updateList;  
          // this sets the call-back function to be invoked when a response from the HTTP request is returned
    isWorking = true;
    http.send(null);
  }
}
 
function getHTTPObject() {
  var xmlhttp;
  if (!xmlhttp && typeof XMLHttpRequest != 'undefined') {
    try {
      xmlhttp = new XMLHttpRequest();
      xmlhttp.overrideMimeType("text/xml"); 
    } catch (e) {
      xmlhttp = false;
    }
  }
  return xmlhttp;
}
 
var http = getHTTPObject(); //  create the HTTP Object
var isWorking = false;