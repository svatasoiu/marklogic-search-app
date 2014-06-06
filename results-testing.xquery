xquery version "1.0-ml";

import module namespace search-lib = "http://www.marklogic.com/tutorial2/search-lib" 
    at "modules/search-lib.xqy";
import module namespace extract-data = "http://www.marklogic.com/tutorial2/extract-data" 
    at "modules/extract-data.xqy";
import module namespace sidebar = "http://www.marklogic.com/tutorial2/sidebar"
    at "modules/sidebar.xqy";
import module namespace search = "http://marklogic.com/appservices/search" 
    at "/MarkLogic/appservices/search/search.xqy";
import module namespace json="http://marklogic.com/xdmp/json"
    at "/MarkLogic/json/json.xqy";
declare namespace html = "http://www.w3.org/1999/xhtml";
declare variable $delim    := "__";

let $query               := xdmp:get-request-field("query")
let $start               := search-lib:get-with-default-int(xdmp:get-request-field("start"), 1)
let $page-length         := search-lib:get-with-default-int(xdmp:get-request-field("pageLength"), 10)
(:let $pg                  := xdmp:get-request-field("pg","Start!"):)
let $category            := xdmp:get-request-field("category")

let $highlight-query     := fn:tokenize($query,"[_]+[^_]+[:]")[1] (: get the pure text, without constraints :)
let $search-query        := fn:replace(if ($category)
                                       then fn:concat($query,' category:"',$category,'"')
                                       else $query,$delim," ")
let $search-response := search-lib:my-search($search-query, $start, $page-length)

let $response-total := $search-response/@total
let $response-start := $search-response/@start
let $response-page-length := $search-response/@page-length
let $mpeg21-docs-uri := $search-response/search:result/@uri

let $prev := max(($start - $page-length, 1))
let $next := min(($start + $page-length, $response-total))
let $curr-url := xdmp:get-request-url()
let $prev-url := 
    if (fn:matches($curr-url, "start=[\d]+"))
    then fn:replace($curr-url, "start=[\d]+", fn:concat("start=",fn:string($prev)))
    else fn:concat($curr-url,"&amp;start=",fn:string($prev))
let $next-url := 
    if (fn:matches($curr-url, "start=[\d]+"))
    then fn:replace($curr-url, "start=[\d]+", fn:concat("start=",fn:string($next)))
    else fn:concat($curr-url,"&amp;start=",fn:string($next))
    
let $facets := $search-response/search:facet
return
                <span>
                <div id="sidebar">
                  {
                    sidebar:create-chiclets($query)
                  }
                  {
                    sidebar:create-facets($facets, $highlight-query)
                  }
                </div>
                <div id="results">
                    <div>
                        <a href="http://localhost:8003{$prev-url}" >prev</a>
                        Retrieved Articles {$response-start/data()} to {fn:min(($response-total/data(),$response-start/data() + $response-page-length/data() - 1))} 
                        of {$response-total/data()} total results in 
                        {xs:decimal(fn:substring-before(fn:substring($search-response/search:metrics/search:query-resolution-time/text(),3),"S"))*1000}ms
                        <a href="http://localhost:8003{$next-url}" >next</a>
                    </div>
                    {
                      for $uri in $mpeg21-docs-uri
                      let $uriSuffix := substring($uri, 20)
                      let $article := fn:doc($uri)
                      return 
                      <div class="result-title">
                            <h4 style="font-family:arial, sans-serif;font-size:10px;font-weight:bold;color:#ff3300;margin-top:0px;margin-right:0;margin-bottom:5px;margin-left:0;padding-top:5px;text-transform:uppercase;border-top:0">
                             { extract-data:get-category($article)/text() }
                            </h4>
                            <h1 style="width:700px;font-family:times new roman,serif;font-size:18px;line-height:18px;font-weight:normal;color:#000000;margin-top:0px;margin-right:0;margin-bottom:2px;margin-left:0;padding:0">
                              <a href="http://www.nejm.org/doi/full/{extract-data:get-doi($article)}">
                                { let $title := extract-data:get-article-title($article)
                                return if ($title) 
                                       then if ($highlight-query)
                                            then cts:highlight(extract-data:get-article-title($article),$highlight-query,<mark>{$cts:text}</mark>) 
                                            else $title/string()
                                       else () }
                              </a>
                            </h1>
                            <span style="font-family: Arial, Helvetica, sans-serif;font-size: 12px;line-height: 14px;font-weight: normal;color:grey;margin-top: 0;margin-right: 0;margin-bottom: 0px;margin-left: 0;padding: 0;">
                              by: { for $author in extract-data:get-authors($article)
                                    return <text> { $author/name/surname }, {$author/name/given-names }, </text>
                                  }
                            </span>
                            <span style="font-family: Arial, Helvetica, sans-serif;font-size: 10px;line-height: 12px;font-weight: normal;color: #000000;margin-top: 0;margin-right: 0;margin-bottom: 15px;margin-left: 0;padding: 0;">
                                  { extract-data:get-pub-date($article) }
                            |     { extract-data:get-journal-title($article) } 
                            |     { extract-data:get-volume-page($article) }
                            </span>
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
                            
                            <span style="font-family: Arial, Helvetica, sans-serif;font-size: 10px;line-height: 12px;font-weight: normal;  margin-top:0;margin-right:0;margin-bottom:0;margin-left:0;padding:0">
                              {
                              (: return all rendition formats 
                                 be careful, not all links work!! :)
                              for $rendition in $article/didl:DIDL/didl:Item/didl:Container[@id="Renditions"]/didl:Component/didl:Resource
                              let $link := $rendition/@ref
                              let $type := 
                                 let $split := fn:tokenize($link,"[.]")
                                 return $split[fn:count($split)]
                              return <b><a href="{$link}">{$type}</a> | </b>
                              }
                            </span>
                        </div> 
                      }
                  </div>
                  </span>
