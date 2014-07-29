xquery version "1.0-ml";
module namespace formats = "http://www.marklogic.com/tutorial2/formats";

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
    $format = ("xml","json","rss","csv")
};

declare private function create-xml($search-response as element(search:response)) {
    <response type="object" xmlns="http://marklogic.com/xdmp/json/basic">
        <responseHeader type="object">
            <status type="number">0</status>
            <QTime type="number">9</QTime>
            <params type="object">
                <q type="string">{$search-response/search:qtext/text()}</q>
                <bf name="bf" type="string"/>
                <wt type="string">xml</wt>
                <fq type="string"></fq>
            </params>
        </responseHeader>
        <result name="response" numFound="{$search-response/@total}" start="{$search-response/@start}" pageLength="{$search-response/@page-length}" type="array">
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
        let $display_objects := extract-data:get-display-objects($article)
        let $inline-graphics := extract-data:get-inline-graphics($article)
        let $spec-ids := extract-data:get-specialty-ids($article)
        let $topic-ids := extract-data:get-topic-ids($article)
        let $ppt := extract-data:get-ppt($article)
        let $cpf-prop := extract-data:get-cpf-properties($article)
        let $doi := extract-data:get-doi($article)
        let $publisher := extract-data:get-publisher-from-jmeta($journal-meta)
        return 
         <doc type="array">
            <str name="id" type="string">{$doi}_nejm</str>
            <str name="pub_id" type="string">{extract-data:get-pub-id($article-meta)}</str>
            <str name="nlm_ta" type="string">{extract-data:get-id-from-jmeta($journal-meta,"nlm-ta")}</str>
            <str name="jn_pub_id" type="string">{extract-data:get-id-from-jmeta($journal-meta,"publisher-id")}</str>
            <str name="collection" type="string">nejm</str>
            <str name="doi" type="string">{$doi}</str>
            <str name="ti" type="string">{$title}</str>
            <str name="ti_prime" type="string">{$title}</str>
            <str name="ti_serial" type="string">{extract-data:get-series-title($article-meta)}</str>
            <str name="record_mpeg21" type="string">{$article//text()}</str>
            <str name="category" type="string">{extract-data:get-category($article)/text()}</str>
            <str name="article_type" type="string">...</str>
            <str name="sub_article_type" type="string">{extract-data:get-sub-article-type($article-meta)}</str>
            <arr name="specialty_str" type="array">{for $id in $spec-ids return <str type="string">{specialties:id-to-str($id)}</str>}</arr>
            <arr name="sub_topic_str" type="array">{for $id in $topic-ids return <str type="string">{topics:id-to-str($id)}</str>}</arr>
            <arr name="sub_topic" type="array">{for $id in $topic-ids return <str type="string">{$id}</str>}</arr>
            <arr name="specialty" type="array">{for $id in $spec-ids return<str type="string">{$id}</str>}</arr>
            <int name="vips_v" type="number">{$vips/mms:volume/data()}</int>
            <str name="vips_fpage" type="string">{$vips/mms:fpage/data()}</str>
            <str name="vips_i" type="string">{$vips/mms:issue/data()}</str>
            <str name="vips_lpage" type="string">{$vips/mms:lpage/data()}</str>
            <str name="vips_s" type="string">{$vips/mms:sequence/data()}</str>
            <int name="pub_year" type="number">{$split-pdate[1]}</int>
            <int name="pub_month" type="number">{$split-pdate[2]}</int>
            <int name="pub_day" type="number">{$split-pdate[3]}</int>
            <str name="abs_d" type="string">{extract-data:get-abstract-from-meta($article-meta,'default')}</str>
            <str name="abs_t" type="string">{extract-data:get-abstract-from-meta($article-meta,'truncated')}</str>
            <str name="abs_s" type="string">{extract-data:get-abstract-from-meta($article-meta,'short')}</str>
            <str name="abs_toc" type="string">{extract-data:get-abstract-from-meta($article-meta,'toc')}</str>
            <str name="abs_summary" type="string">{extract-data:get-abstract-from-meta($article-meta,'summary')}</str>
            <arr name="au_aff" type="array"></arr>
            <str name="au_onbehalfof" type="string"/>
            <str name="collab" type="string"/>
            
            <arr name="au_surname" type="array">
            {for $author in $author-names return <str type="string">{extract-data:get-author-surname($author)}</str>}
            </arr>
            <arr name="au_givenname" type="array">
            {for $author in $author-names return <str type="string">{extract-data:get-author-given-name($author)}</str>}
            </arr>
            <arr name="au_name" type="array">
                {for $author in $author-names 
                return <str type="string">{extract-data:get-author-surname($author)},{extract-data:get-author-given-name($author)}</str>}
            </arr>
            <arr name="au_degree" type="array">{for $deg in extract-data:get-author-degree($authors) return <str type="string">{$deg}</str>}</arr>
            
            <str name="ar_file_name" type="string">{extract-data:get-article-file-name($article)}</str>
            <str name="z_pdf" type="string">{extract-data:get-article-pdf($article)}</str>
            <arr name="z_self_supplement" type="array">{for $supple in $supplements return <str type="string">{$supple}</str>}</arr>
            <bool name="has_supplement" type="boolean">{if ($supplements) then "true" else "false"}</bool>
            <arr name="z_display_objects" type="array">{for $object in $display_objects return <str type="string">{$object}</str>}</arr>
            <bool name="has_display_objects" type="boolean">{if ($display_objects) then "true" else "false"}</bool>
            <str name="ml_article_link" type="string">{extract-data:get-ml-link($article)}</str>
            <str name="z_ppt_link" type="string">{$ppt}</str>
            <bool name="has_ppt" type="boolean">{if ($ppt) then "true" else "false"}</bool>
            <str name="ml_cpf_state" type="string">{$cpf-prop/cpf:state/text()}</str>
            <str name="ml_cpf_process_status" type="string">{$cpf-prop/cpf:processing-status/text()}</str>
            <date name="pub_date" type="string">{$pub-date}</date>
            <str name="pub_date_rss" type="string">{$pub-date}</str>
            <str name="pub_date_d" type="string">{$pub-date}</str>
            <int name="article_pages" type="number">{$vips/mms:lpage/data() - $vips/mms:fpage/data() + 1}</int>
            <bool name="is_pap" type="boolean">false</bool>
            <bool name="is_free" type="boolean">{extract-data:is-free($article)}</bool>
            <str name="nlm_type" type="string">{extract-data:get-nlm-type($article)}</str>
            <str name="record_text" type="string">...</str>
            <bool name="has_cme" type="boolean">false</bool>
            <str name="doi_cme" type="string">...</str>
            <arr name="fn_financial_disclosure" type="array"></arr>
            <arr name="image_caption" type="array"></arr>
            <str name="record_full" type="string">...</str>
            <date name="timestamp" type="string"/>
            <long name="_version_" type="string"/>
            <bool name="has_inline_graphics" type="boolean">{if ($inline-graphics) then "true" else "false"}</bool>
            <bool name="has_attachment" type="boolean">{extract-data:has-attachment($article)}</bool>
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

declare function formats:get-format($search-response as element(search:response), $format as xs:string) {
    switch ($format)
        case "xml" return create-xml($search-response)
        case "json" return create-json($search-response)
        case "rss" return create-rss($search-response)
        case "csv" return create-csv($search-response)
        default return "oops"
};

