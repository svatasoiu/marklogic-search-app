xquery version "1.0-ml";

module namespace sidebar = "http://www.marklogic.com/tutorial2/sidebar";

import module namespace search = "http://marklogic.com/appservices/search" 
    at "/MarkLogic/appservices/search/search.xqy";
declare namespace html = "http://www.w3.org/1999/xhtml";

declare variable $CURR-URL := xdmp:get-request-url();
declare variable $LIMIT    := 10;
declare variable $DELIM    := "__";

declare function sidebar:create-facets($facets as element(search:facet)*)
as element(div)* {
    for $facet in $facets
    let $facet-name := $facet/@name/data()
    let $count := 0
    return 
        if (fn:count($facet/search:facet-value) < 2) 
        then () 
        else
            <div class="facet-box">
              <h3>{$facet-name}</h3>
              <ul facet-name="{$facet-name}">
              {
                for $bucket in $facet/search:facet-value
                let $_ := xdmp:set($count, $count + 1)
                let $bucket-name := $bucket/@name/data()
                let $added-facet := fn:concat($facet-name,':"',$bucket-name,'"')
                return  if ($count > $LIMIT) 
                        then (
                              <li class="hidden" bucket-name="{$bucket-name}"> 
                                <span class="constraint" constraint="{$added-facet}">{$bucket/text()} <span class="count"> ({$bucket/@count/data()})</span></span>
                              </li>
                             )
                        else (
                              <li bucket-name="{$bucket-name}"> 
                                <span class="constraint" constraint="{$added-facet}">{$bucket/text()} <span class="count"> ({$bucket/@count/data()})</span></span>
                              </li>
                             )
              }
              <!-- Need to add a More... button -->
              </ul>
              { if ($count > $LIMIT) then <span class="more-button">more...</span> else () }
            </div>
};

declare function sidebar:create-chiclet($query-string as xs:string, $facet as xs:string, $constraint as xs:string)
{
    <span class="chiclet" constraint="{$facet}:{$constraint}">{$facet}: {$constraint}</span>,<br/>
};

declare function sidebar:create-chiclets($query-string as xs:string)
as element(div) {
    let $matches := 
        let $temp := fn:tokenize($query-string,$DELIM)
        return 
            if (fn:contains($temp[1],":")) (: if actual query is empty :)
            then $temp
            else fn:subsequence($temp,2)
    return
        <div id="chiclet-box">
        {
            for $match in $matches
            let $split-match := fn:tokenize($match,":")
            return sidebar:create-chiclet($query-string, $split-match[1], $split-match[2])
        }
        </div>
};

(:
declare function sidebar:create-facets($facets as element(search:facet)*, $query as xs:string)
as element(html:div)* {
    for $facet in $facets
    let $facet-name := $facet/@name/data()
    let $count := 0
    return 
        <html:div>
          <html:h3>{$facet-name}</html:h3>
          <html:ul facet-name="{$facet-name}">
          {
            for $bucket in $facet/search:facet-value
            let $_ := xdmp:set($count, $count + 1)
            let $bucket-name := $bucket/@name/data()
            let $added-facet := fn:concat($facet-name,':"',$bucket-name,'"')
            let $new-url := fn:replace($CURR-URL,fn:concat("\?query=",$query),fn:concat("?query=",$query,$DELIM,$added-facet))
            return  if ($count > $LIMIT) 
                    then ()
                    else (
                          <html:li bucket-name="{$bucket-name}"> 
                            <html:a href="http://localhost:8003{$new-url}">{$bucket/text()} ({$bucket/@count/data()})</html:a>
                          </html:li>
                         )
          }
          <!-- Need to add a More... button -->
          </html:ul>
        </html:div>
};

declare function sidebar:create-chiclet($query-string as xs:string, $facet as xs:string, $constraint as xs:string)
 {
    let $new-url := fn:replace($CURR-URL, fn:concat($DELIM,$facet,":",fn:replace(fn:replace($constraint,'"',"%22")," ","%20")), "")
    return
      <html:a href="http://localhost:8003{$new-url}">
        {$constraint}
      </html:a>,<html:br/>
};

declare function sidebar:create-chiclets($query-string as xs:string)
as element(html:div) {
    let $matches := 
        let $temp := fn:tokenize($query-string,$DELIM)
        return 
            if (fn:contains($temp[1],":")) (: if actual query is empty :)
            then $temp
            else fn:subsequence($temp,2)
    return
        <html:div>
        {
            for $match in $matches
            let $split-match := fn:tokenize($match,":")
            return sidebar:create-chiclet($query-string, $split-match[1], $split-match[2])
        }
        </html:div>
};
:)