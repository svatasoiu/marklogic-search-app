xquery version "1.0-ml";

import module namespace create-html = "http://www.marklogic.com/tutorial2/create-html"
    at "create-html.xqy";
import module namespace search-lib = "http://www.marklogic.com/tutorial2/search-lib" 
    at "search-lib.xqy";
import module namespace formats = "http://www.marklogic.com/tutorial2/formats"
    at "formats.xqy";
import module namespace search = "http://marklogic.com/appservices/search" 
    at "/MarkLogic/appservices/search/search.xqy";

declare namespace html = "http://www.w3.org/1999/xhtml";
declare variable $DELIM    := "__";

let $query               := xdmp:get-request-field("query")
let $sort                := xdmp:get-request-field("sort", "relevance")
let $start               := search-lib:get-with-default-int(xdmp:get-request-field("start"), 1)
let $page-length         := search-lib:get-with-default-int(xdmp:get-request-field("pageLength"), 10)
let $target              := xdmp:get-request-field("target")
let $format              := xdmp:get-request-field("format")
let $fields              := xdmp:get-request-field("fields", "doi,pub-date,title,category")

let $query := fn:replace($query, "([^\s]*:\s|:$)", "")
let $query := fn:replace($query, '[\s]+([^(__)\s]*:"[^\s]+")', fn:concat($DELIM,"$1"))
let $highlight-query := fn:replace($query, fn:concat($DELIM,"[^\s]*:[^\s]*"), "")

let $search-query := fn:concat(fn:replace($query, $DELIM, " "), ' sort:"', $sort, '"')
let $search-response := search-lib:my-search($search-query, $start, $page-length, $highlight-query, $target)

return 
    if ($format and formats:has-format($format))
    then formats:get-format($search-response, $query, $format, $fields)
    else create-html:full($search-response, $query)
