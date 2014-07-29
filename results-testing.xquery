xquery version "1.0-ml";

import module namespace search-lib = "http://www.marklogic.com/tutorial2/search-lib" 
    at "modules/search-lib.xqy";
import module namespace extract-data = "http://www.marklogic.com/tutorial2/extract-data" 
    at "modules/extract-data.xqy";
import module namespace sidebar = "http://www.marklogic.com/tutorial2/sidebar"
    at "modules/sidebar.xqy";
import module namespace formats = "http://www.marklogic.com/tutorial2/formats"
    at "modules/formats.xqy";
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

let $highlight-query     := let $temp := fn:tokenize($query,$DELIM)[1] (: get the pure text, without constraints :)
                            return if (fn:contains($temp, "[:]"))
                                   then ""
                                   else $temp

let $search-query := fn:concat(fn:replace($query, $DELIM, " "), ' sort:"', $sort, '"')
let $search-response := search-lib:my-search($search-query, $start, $page-length, $highlight-query, $target)

let $response-total := $search-response/@total
let $response-start := $search-response/@start
let $response-page-length := $search-response/@page-length
 
let $facets := $search-response/search:facet
let $result-metrics := 
                   <div class="result-metrics">
                        <a class="previous">prev</a>
                        Retrieved Articles {$response-start/data()} to {fn:min(($response-total/data(),$response-start/data() + $response-page-length/data() - 1))} 
                        of {$response-total/data()} total results in 
                        {
                        try { xs:decimal(fn:substring-before(fn:substring($search-response/search:metrics/search:total-time/text(),3),"S"))*1000 } 
                        catch ($exception) { () }
                        }ms
                        <a class="next">next</a>
                    </div>
return 
    if ($format and formats:has-format($format))
    then formats:get-format($search-response, $format)
    else 
                <span>
                <div id="sidebar">
                  {
                    sidebar:create-chiclets($query)
                  }
                  {
                    sidebar:create-facets($facets)
                  }
                </div>
                <div id="results">
                    <br/><br/><br/><br/><br/>
                    { $result-metrics }
                    {
                    (:let $mpeg21-docs-uri := $search-response/search:result/@uri:)
                      for $result in $search-response/search:result
                      let $uri := $result/@uri
                      let $uriSuffix := substring($uri, 20)
                      let $article := fn:doc($uri)
                      let $pub-date := extract-data:get-pub-date($article)/text()
                      let $archive := ($pub-date < "1990-01-01")
                      return 
                      <div class="result-title">
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
                                    return <text> { $author/name/surname }, {$author/name/given-names }; </text>
                                  }
                            </span><br/>
                            <span style="font-family: Arial, Helvetica, sans-serif;font-size: 10px;line-height: 12px;font-weight: normal;color: #000000;margin-top: 0;margin-right: 0;margin-bottom: 15px;margin-left: 0;padding: 0;">
                                  { $pub-date }
                            |     { extract-data:get-journal-title($article) } 
                            |     { extract-data:get-volume-page($article) }
                            </span><br/>
                            <span style="font-family: Arial, Helvetica, sans-serif;font-size: 13px;line-height: 15px;font-weight: normal;color: #000000;margin-top: 0;margin-right: 0;margin-bottom: 15px;margin-left: 0;padding: 0;">
                                  { 
                                     let $abstract := extract-data:get-abstract($article)
                                     return if ($abstract instance of node())
                                            then if ($highlight-query) 
                                                 then cts:highlight($abstract, $highlight-query, <mark>{$cts:text}</mark>)
                                                 else $abstract/string()
                                            else ()
                                  }
                            </span>
                            
                            <!-- image previews -->
                            <span style="font-family: Arial, Helvetica, sans-serif;font-size: 10px;line-height: 12px;font-weight: normal;  margin-top:0;margin-right:0;margin-bottom:0;margin-left:0;padding:0">
                              {
                               extract-data:get-images($article)
                              }
                            </span>
                            
                            <br/>
                            
                            <span style="font-family: Arial, Helvetica, sans-serif;font-size: 10px;line-height: 12px;font-weight: normal;  margin-top:0;margin-right:0;margin-bottom:0;margin-left:0;padding:0">
                              {
                              (: return all rendition formats 
                                 be careful, not all links work!! :)
                              for $rendition in $article/didl:DIDL/didl:Item/didl:Container[@id="Renditions"]/didl:Component/didl:Resource
                              let $link := fn:replace($rendition/@ref, "markl64stby[.]dom1", "mark-ed")
                              let $type := 
                                 let $split := fn:tokenize($link,"[.]")
                                 return $split[fn:count($split)]
                              return <b><a href="{$link}" target="_blank">{$type}</a> | </b>
                              }
                            </span>
                        </div> 
                      }
                      { if ($response-total > 0) then $result-metrics else () }
                      <div id="formats">
                        <span>Output Formats:</span>
                        <span class="export" type="xml">XML</span> 
                        <span class="export" type="json">JSON</span> 
                        <span class="export" type="rss">RSS</span> 
                        <span class="export" type="csv">CSV</span> 
                      </div>
                  </div>
                  </span>
