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

let $query := fn:replace($query, "([^\s]*:\s|:$)", "")
let $query := fn:replace($query, '[\s]+([^(__)\s]*:"[^\s]+")', fn:concat($DELIM,"$1"))
let $highlight-query := fn:replace($query, fn:concat($DELIM,"[^\s]*:[^\s]*"), "")

let $search-query := fn:concat(fn:replace($query, $DELIM, " "), ' sort:"', $sort, '"')
let $search-response := search-lib:my-search($search-query, $start, $page-length, $highlight-query, $target)

(:let $response-total := $search-response/@total
let $response-start := $search-response/@start
let $response-page-length := $search-response/@page-length
 
let $facets := $search-response/search:facet
let $result-metrics := 
                   <div class="result-metrics">
                         <div>
                              <a class="previous">prev</a>
                              Retrieved Articles {$response-start/data()} to {fn:min(($response-total/data(),$response-start/data() + $response-page-length/data() - 1))} 
                              of {$response-total/data()} total results in 
                              {
                              try { xs:decimal(fn:substring-before(fn:substring($search-response/search:metrics/search:total-time/text(),3),"S"))*1000 } 
                              catch ($exception) { () }
                              }ms
                              { if ($response-start/data() + $response-page-length/data() - 1 < $response-total) then <a class="next">next</a> else ()}
                        </div>
                    </div>:)
return 
    if ($format and formats:has-format($format))
    then formats:get-format($search-response, $query, $format)
    else create-html:full($search-response, $query)
                (:<span>
                <div id="sidebar">
                  {$search-response/search:metrics}
                  {
                    sidebar:create-chiclets($query)
                  }
                  {
                    sidebar:create-facets($facets)
                  }
                </div>
                <div id="results">
                      { $result-metrics }
                      
                      { if ($response-total > 0) then $result-metrics else () }
                      
                      <div id="formats">
                        <span>Output Formats:</span>
                        <span class="export" type="xml">XML</span> 
                        <span class="export" type="json">JSON</span> 
                        <span class="export" type="rss">RSS</span> 
                        <span class="export" type="csv">CSV</span> 
                      </div>
                  </div>
                  </span>:)
