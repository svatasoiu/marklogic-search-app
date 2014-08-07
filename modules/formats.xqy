xquery version "1.0-ml";
module namespace formats = "http://www.marklogic.com/tutorial2/formats";

import module namespace create-html = "http://www.marklogic.com/tutorial2/create-html"
    at "create-html.xqy";
import module namespace extract-data = "http://www.marklogic.com/tutorial2/extract-data" 
    at "extract-data.xqy";
import module namespace search = "http://marklogic.com/appservices/search" 
    at "/MarkLogic/appservices/search/search.xqy";
import module namespace json = "http://marklogic.com/xdmp/json"
    at "/MarkLogic/json/json.xqy";
 
import module namespace topics = "http://www.nejm.org/topics"
  at "topics.xqy";
import module namespace specialties  = "http://www.nejm.org/specialties"
  at "specialties.xqy";
declare namespace didl="urn:mpeg:mpeg21:2002:02-DIDL-NS";
declare namespace dii="urn:mpeg:mpeg21:2002:01-DII-NS";
declare namespace mms="http://www.massmed.org/elements/";
declare namespace cpf="http://marklogic.com/cpf";

declare variable $TOPIC-TABLE := topics:get-topics();
declare variable $SPEC-TABLE  := specialties:get-specialties();

declare function formats:has-format($format as xs:string) {
    $format = ("xml","json","rss","csv","html")
};

declare private function create-xml($search-response as element(search:response)) {
    <response type="object" xmlns="http://marklogic.com/xdmp/json/basic">
        <responseHeader type="object">
            <status type="number">0</status>
            <QTime type="number">9</QTime>
            <params type="object">
                <q type="string">{$search-response/search:qtext/text()}</q>
                <bf type="string"/>
                <wt type="string">xml</wt>
                <fq type="string"></fq>
            </params>
        </responseHeader>
        <result numFound="{$search-response/@total}" start="{$search-response/@start}" pageLength="{$search-response/@page-length}" type="array">
        {
        for $result in $search-response/search:result
        let $uri := $result/@uri
        let $article := fn:doc($uri)
        let $pub-date := extract-data:get-pub-date($article)/text()
        let $split-pdate := fn:tokenize($pub-date, "-")
        let $title := extract-data:get-article-title($article)/text()
        let $vips := extract-data:get-vips($article)
        let $journal-meta := extract-data:get-journal-meta($article)
        let $article-meta := extract-data:get-article-meta($article)
        let $authors := extract-data:get-authors-from-meta($article-meta)
        let $author-names := extract-data:get-author-names($authors) 
        let $supplements := extract-data:get-article-supplements($article)
        let $display-objects := extract-data:get-display-objects($article)
        let $inline-graphics := extract-data:get-inline-graphics($article)
        let $spec-ids := extract-data:get-specialty-ids($article)
        let $topic-ids := extract-data:get-topic-ids($article)
        let $ppt := extract-data:get-ppt($article)
        let $cpf-prop := extract-data:get-cpf-properties($article)
        let $doi := extract-data:get-doi($article)
        let $publisher := extract-data:get-publisher-from-jmeta($journal-meta)
        return 
         <doc type="object">
            <id type="string">{$doi}-nejm</id>
            <pub-id type="string">{extract-data:get-pub-id($article-meta)}</pub-id>
            <nlm-ta type="string">{extract-data:get-id-from-jmeta($journal-meta,"nlm-ta")}</nlm-ta>
            <jn-pub-id type="string">{extract-data:get-id-from-jmeta($journal-meta,"publisher-id")}</jn-pub-id>
            <collection type="string">nejm</collection>
            <doi type="string">{$doi}</doi>
            <ti type="string">{$title}</ti>
            <ti-prime type="string">{$title}</ti-prime>
            <ti-serial type="string">{extract-data:get-series-title($article-meta)}</ti-serial>
            <record-mpeg21 type="string">{$article//text()}</record-mpeg21>
            <category type="string">{extract-data:get-category($article)/text()}</category>
            <article-type type="string"></article-type>
            <sub-article-type type="string">{extract-data:get-sub-article-type($article-meta)}</sub-article-type>
            <specialty-str type="array">{for $id in $spec-ids return <str type="string">{specialties:id-to-str($id)}</str>}</specialty-str>
            <sub-topic-str type="array">{for $id in $topic-ids return <str type="string">{topics:id-to-str($id)}</str>}</sub-topic-str>
            <sub-topic type="array">{for $id in $topic-ids return <str type="string">{$id}</str>}</sub-topic>
            <specialty type="array">{for $id in $spec-ids return<str type="string">{$id}</str>}</specialty>
            <vips-v type="string">{$vips/mms:volume/data()}</vips-v>
            <vips-fpage type="string">{$vips/mms:fpage/data()}</vips-fpage>
            <vips-i type="string">{$vips/mms:issue/data()}</vips-i>
            <vips-lpage type="string">{$vips/mms:lpage/data()}</vips-lpage>
            <vips-s type="string">{$vips/mms:sequence/data()}</vips-s>
            <pub-year type="number">{$split-pdate[1]}</pub-year>
            <pub-month type="number">{$split-pdate[2]}</pub-month>
            <pub-day type="number">{$split-pdate[3]}</pub-day>
            <abs-d type="string">{extract-data:get-abstract-from-meta($article-meta,'default')}</abs-d>
            <abs-t type="string">{extract-data:get-abstract-from-meta($article-meta,'truncated')}</abs-t>
            <abs-s type="string">{extract-data:get-abstract-from-meta($article-meta,'short')}</abs-s>
            <abs-toc type="string">{extract-data:get-abstract-from-meta($article-meta,'toc')}</abs-toc>
            <abs-summary type="string">{extract-data:get-abstract-from-meta($article-meta,'summary')}</abs-summary>
            <au-aff type="array"></au-aff>
            <au-onbehalfof type="string"/>
            <collab type="string"/>
            
            <au-surname type="array">
            {for $author in $author-names return <str type="string">{extract-data:get-author-surname($author)}</str>}
            </au-surname>
            <au-givenname type="array">
            {for $author in $author-names return <str type="string">{extract-data:get-author-given-name($author)}</str>}
            </au-givenname>
            <au-name type="array">
                {for $author in $author-names 
                return <str type="string">{extract-data:get-author-surname($author)},{extract-data:get-author-given-name($author)}</str>}
            </au-name>
            <au-degree type="array">{for $deg in extract-data:get-author-degree($authors) return <str type="string">{$deg}</str>}</au-degree>
            
            <ar-file-name type="string">{extract-data:get-article-file-name($article)}</ar-file-name>
            <z-pdf type="string">{extract-data:get-article-pdf($article)}</z-pdf>
            <z-self-supplement type="array">{for $supple in $supplements return <str type="string">{$supple}</str>}</z-self-supplement>
            <has-supplement type="boolean">{if ($supplements) then "true" else "false"}</has-supplement>
            <z-display-objects type="array">{for $object in $display-objects return <str type="string">{$object}</str>}</z-display-objects>
            <has-display-objects type="boolean">{if ($display-objects) then "true" else "false"}</has-display-objects>
            <ml-article-link type="string">{extract-data:get-ml-link($article)}</ml-article-link>
            <z-ppt-link type="string">{$ppt}</z-ppt-link>
            <has-ppt type="boolean">{if ($ppt) then "true" else "false"}</has-ppt>
            <ml-cpf-state type="string">{$cpf-prop/cpf:state/text()}</ml-cpf-state>
            <ml-cpf-process-status type="string">{$cpf-prop/cpf:processing-status/text()}</ml-cpf-process-status>
            <pub-date type="string">{$pub-date}</pub-date>
            <pub-date-rss type="string">{$pub-date}</pub-date-rss>
            <pub-date-d type="string">{$pub-date}</pub-date-d>
            <article-pages type="string">{try {$vips/mms:lpage/data() - $vips/mms:fpage/data() + 1} catch ($excep) {0} }</article-pages>
            <is-pap type="boolean">false</is-pap>
            <is-free type="boolean">{extract-data:is-free($article)}</is-free>
            <nlm-type type="string">{extract-data:get-nlm-type($article)}</nlm-type>
            <record-text type="string"></record-text>
            <has-cme type="boolean">false</has-cme>
            <doi-cme type="string"></doi-cme>
            <fn-financial-disclosure type="array"></fn-financial-disclosure>
            <image-caption type="array"></image-caption>
            <record-full type="string"></record-full>
            <timestamp type="string"/>
            <version type="string"/>
            <has-inline-graphics type="boolean">{if ($inline-graphics) then "true" else "false"}</has-inline-graphics>
            <has-attachment type="boolean">{extract-data:has-attachment($article)}</has-attachment>
         </doc>
        }
        </result>
    </response>
};

declare private function create-json($search-response as element(search:response)) {
    json:transform-to-json(<json type="object" xmlns="http://marklogic.com/xdmp/json/basic"> {create-xml($search-response) } </json>)
};

declare private function create-rss($search-response as element(search:response)) {
    <rss xmlns:dc="http://purl.org/dc/elements/1.1/" version="2.0">
        <channel>
            <title>The New England Journal of Medicine</title>
            <link>http://www.nejm.org</link>
            <description>
                The New England Journal of Medicine (NEJM) RSS feed. NEJM (http://www.nejm.org) is a weekly general medical journal that publishes new medical research findings, review articles, and editorial opinion on a wide variety of topics of importance to biomedical science and clinical practice.
            </description>
            {
            for $result in $search-response/search:result
            let $uri := $result/@uri
            let $article := fn:doc($uri)
            let $pub-date := extract-data:get-pub-date($article)/text()
            let $title := extract-data:get-article-title($article)/text()
            let $journal-meta := extract-data:get-journal-meta($article)
            let $article-meta := extract-data:get-article-meta($article)
            let $doi := $article-meta/article-id[@pub-id-type='doi']/data()
            let $publisher := $journal-meta/publisher/publisher-name/text()
            return 
                <item>
                    <title>{$title}</title>
                    <link>http://www.nejm.org/doi/full/{$doi}</link>
                    <description>
                    {for $author in extract-data:get-authors($article)
                     return fn:concat($author/name/surname/text(), ", ", $author/name/given-names//text())}
                    {extract-data:get-abstract($article)//text()}
                    </description>
                    <guid isPermaLink="false">{$doi}</guid>
                    <dc:creator/>
                    <dc:publisher>{$publisher}</dc:publisher>
                    <dc:date>{$pub-date}</dc:date>
                </item>
            }
        </channel>
    </rss>
};

declare private function create-csv($search-response as element(search:response)) {
    let $header := fn:string-join(("doi","pub_date_d","ti","category"), ",")
    let $articleCSV :=
        for $result in $search-response/search:result
        let $uri := $result/@uri
        let $article := fn:doc($uri)
        let $doi := extract-data:get-doi($article)
        let $pub-date := extract-data:get-pub-date($article)/text()
        let $title := extract-data:get-article-title($article)/text()
        let $category := extract-data:get-category($article)/text()
        return fn:string-join(($doi,$pub-date,$title,$category), ",")
    return ($header, $articleCSV)
};

declare function formats:get-format($search-response as element(search:response), $query as xs:string, $format as xs:string) {
    switch ($format)
        case "xml" return create-xml($search-response)
        case "json" return create-json($search-response)
        case "rss" return create-rss($search-response)
        case "csv" return create-csv($search-response)
        case "html" return create-html:export($search-response, $query)
        default return "oops"
};
