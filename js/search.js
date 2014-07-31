// setup key listener on search box
$(document).ready(function () {
    targets = $("#tbox").kendoMultiSelect().data("kendoMultiSelect");
    
    var multiselect = $("#tbox").data("kendoMultiSelect");
    multiselect.bind("change", getData);
    
    $("#sbox").keyup(function () {
        //                if (event.keyCode == 13) {
        //                getData();
        var currQuery = $(this).attr("value");
        // only send request if the query actually changed (i.e. don't react to ALT or CTRL presses)
        if (lastQuery !== currQuery) {
            lastQuery = currQuery;
            getData();
        } else if (event.keyCode == 13) {
            getData();
        }
        //                }
    });
});

$(document).on("change", "input[@name='sort']:radio", function () {
    getData();
});

$(document).on("click", "a.previous", function () {
    start = Math.max(1, start - pageLength);
    getData(false);
});

$(document).on("click", "a.next", function () {
    start += pageLength;
    getData(false);
});

$(document).on("click", "span.constraint", function () {
    addConstraint($(this).attr("constraint"));
    getData();
});

$(document).on("click", "span.chiclet", function () {
    removeConstraint($(this).attr("constraint"));
    getData();
});

// more... button click
$(document).on("click", "span.more-button", function () {
    var constraints = $(this).siblings("ul").children("li.hidden");
    constraints.removeClass("hidden");
    constraints.addClass("no-hidden");
    
    $(this).text("less...");
    $(this).addClass("less-button");
    $(this).removeClass("more-button");
});

// less... button click
$(document).on("click", "span.less-button", function () {
    var constraints = $(this).siblings("ul").children("li.no-hidden");
    constraints.removeClass("no-hidden");
    constraints.addClass("hidden");
    
    $(this).text("more...");
    $(this).addClass("more-button");
    $(this).removeClass("less-button");
});

$(document).on("click", ".export", function () {
    var format = $(this).attr("type");
    
    window.open(createQString("&format=" + format + "&pageLength="));
});

function addConstraint(constraint) {
    constraints.push(constraint);
}

function removeConstraint(constraint) {
    var ind = constraints.indexOf(constraint);
    if (ind > -1) {
        constraints.splice(ind, 1);
    }
}

function msie() {
   var ua = window.navigator.userAgent;
   var msie = ua.indexOf("MSIE ");

   if (msie > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./))      // If Internet Explorer, return version number
      return true;
   else                 // If another browser, return 0
      return false;
}

function update() {
    if (http.readyState == 4) {
        // check if you need to get another update (i.e. if the user was typing while the search was going on)
        if (nextQuery) {
            isWorking = false;
            getData(false);
        } else {
            isWorking = false;
        }
        
        $("#wo").html(http.responseText);
        if (msie()) $("audio").remove();
        window.scrollTo(0,0);
        isWorking = false;
    }
}

function getData(newStart) {
    if (isWorking) {
        // if isWorking, store query
        nextQuery = true;
    } else
    if (! isWorking && http) {
        nextQuery = false;
        
        // default newStart boolean to true
        if (typeof (newStart) === 'undefined') newStart = true;
        if (newStart) start = 1;

        qString = createQString();
        
        http.open("GET", qString, true);
        http.onreadystatechange = update;
        
        isWorking = true;
        http.send(null);
    }
}

function createQString(additional) {
    var q = $("#sbox").attr("value");
    var qString = q;
    
    // add in constraints
    for (var i = 0; i < constraints.length;++ i) {
        qString += delim + constraints[i];
    }
    
    // add sorting option
    var sort = $('input[@name="sort"]:checked').val();
    qString = "results-testing.xquery?query=" + qString + "&start=" + start + "&sort=" + sort + "&target=" + targets.value();
    if (additional) qString += additional;
    
    return qString;
}

function getHTTPObject() {
    var xmlhttp;
    if (! xmlhttp && typeof XMLHttpRequest != 'undefined') {
        try {
            xmlhttp = new XMLHttpRequest();
            xmlhttp.overrideMimeType("text/xml");
        }
        catch (e) {
            xmlhttp = false;
        }
    }
    return xmlhttp;
}

var http = getHTTPObject();
//  create the HTTP Object
var isWorking = false;
var constraints =[];
var lastQuery = "";
var delim = "__";
var start = 1;
var pageLength = 10;
var nextQuery = false;
var targets = null;