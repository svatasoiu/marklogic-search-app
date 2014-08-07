xquery version "1.0-ml";

module namespace create-html = "http://www.marklogic.com/tutorial2/create-html";

import module namespace sidebar = "http://www.marklogic.com/tutorial2/sidebar"
    at "sidebar.xqy";
import module namespace extract-data = "http://www.marklogic.com/tutorial2/extract-data" 
    at "extract-data.xqy";
import module namespace search = "http://marklogic.com/appservices/search" 
    at "/MarkLogic/appservices/search/search.xqy";
    
declare namespace html = "http://www.w3.org/1999/xhtml";
declare variable $DELIM    := "__";

declare function create-html:full($search-response as element(search:response), $query as xs:string) {
    let $facets := $search-response/search:facet
    let $response-total := $search-response/@total
    let $result-metrics := create-html:metrics($search-response)
    return 
        <span>
            <div id="sidebar">
                <!-- { $search-response/search:metrics } -->
                { sidebar:create-chiclets($query) }
                { sidebar:create-facets($facets) }
            </div>
            <div id="results">
                { $result-metrics }
                { create-html:body($search-response, $query) }
                { if ($response-total > 0) then $result-metrics else () }
                      
                <div id="formats">
                    <span>Output Formats:</span>
                    <span class="export" type="xml">XML</span> 
                    <span class="export" type="json">JSON</span> 
                    <span class="export" type="rss">RSS</span> 
                    <span class="export" type="csv">CSV</span> 
                    <span class="export" type="html">HTML</span> 
                </div>
            </div>
        </span>
};

declare function create-html:export($search-response as element(search:response), $query as xs:string) {
    <html xmlns="http://www.w3.org/1999/xhtml">
        <head>
            <title>NEJM Search (HTML)</title>
            <script src="/application/lib/external/jquery-1.7.1.min.js" type="text/javascript"></script>
            <script src="search.js" type="text/javascript"></script>
            <link type="text/css" rel="stylesheet" href="/css/page-layout.css" media="screen, print" />
        </head>
        <body>
            {create-html:body($search-response, $query)}
        </body>
    </html>
};

declare function create-html:body($search-response as element(search:response), $query as xs:string) {
    let $highlight-query := fn:replace($query, fn:concat($DELIM,"[^\s]*:[^\s]*"), "")
    for $result in $search-response/search:result
    let $uri := $result/@uri
    let $uriSuffix := substring($uri, 20)
    let $article := fn:doc($uri)
    let $pub-date := extract-data:get-pub-date($article)/text()
    let $archive := ($pub-date < "1990-01-01")
    return 
        <div class="result-title">
            <div>
                <h4 style="font-family:arial, sans-serif;font-size:10px;font-weight:bold;color:#ff3300;margin-top:0px;margin-right:0;margin-bottom:5px;margin-left:0;padding-top:5px;text-transform:uppercase;border-top:0">
                    { extract-data:get-category($article)/text() }
                </h4>
                <h1 style="width:700px;font-family:times new roman,serif;font-size:18px;line-height:18px;font-weight:normal;color:#000000;margin-top:0px;margin-right:0;margin-bottom:2px;margin-left:0;padding:0">
                    <a href="http://www.nejm.org/doi/full/{extract-data:get-doi($article)}" target="_blank">
                        { let $title := extract-data:get-article-title($article)
                          return if ($title) 
                                 then if ($highlight-query)
                                      then cts:highlight(extract-data:get-article-title($article),$highlight-query,<mark>{$cts:text}</mark>) 
                                      else $title/string()
                                 else () }
                    </a>
                    { if ($archive)
                      then <img src="http://www.nejm.org/templates/jsp/_style2/_mms/_nejm/img/archive_indictr.png" />
                      else () }
                </h1>
                <span style="font-family: Arial, Helvetica, sans-serif;font-size: 12px;line-height: 14px;font-weight: normal;color:grey;margin-top: 0;margin-right: 0;margin-bottom: 0px;margin-left: 0;padding: 0;">
                    by: { for $author in extract-data:get-authors($article)
                          return <text> { $author/name/surname }, {$author/name/given-names }; </text> }
                </span>
                <br/>
                
                <span style="font-family: Arial, Helvetica, sans-serif;font-size: 10px;line-height: 12px;font-weight: normal;color: #000000;margin-top: 0;margin-right: 0;margin-bottom: 15px;margin-left: 0;padding: 0;">
                    { $pub-date } | { extract-data:get-journal-title($article) } | { extract-data:get-volume-page($article) } | {extract-data:get-doi($article) }
                </span>
                <br/>
                <span style="font-family: Arial, Helvetica, sans-serif;font-size: 13px;line-height: 15px;font-weight: normal;color: #000000;margin-top: 0;margin-right: 0;margin-bottom: 15px;margin-left: 0;padding: 0;">
                    { let $abstract := extract-data:get-abstract($article)
                      return if ($abstract instance of node())
                             then if ($highlight-query) 
                                  then cts:highlight($abstract, $highlight-query, <mark>{$cts:text}</mark>)
                                  else $abstract/string()
                             else () }
                </span>
                                
                <span>
                    { extract-data:get-images($article) }
                </span>
                                
                <br/>
                                
                { extract-data:get-renditions($article) }
            </div>
        </div> 
};

declare function create-html:metrics($search-response as element(search:response)) {
    let $response-total := $search-response/@total
    let $response-start := $search-response/@start
    let $response-page-length := $search-response/@page-length
    return 
        <div class="result-metrics">
            <div>
                <a class="previous">prev</a>
                Retrieved Articles {$response-start/data()} to {fn:min(($response-total/data(),$response-start/data() + $response-page-length/data() - 1))} 
                of {$response-total/data()} total results in 
                { try { xs:decimal(fn:substring-before(fn:substring($search-response/search:metrics/search:total-time/text(),3),"S"))*1000 } 
                  catch ($exception) { () } }ms
                { if ($response-start/data() + $response-page-length/data() - 1 < $response-total) then <a class="next">next</a> else ()}
            </div>
        </div>
};
