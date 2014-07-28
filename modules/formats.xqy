xquery version "1.0-ml";
module namespace formats = "http://www.marklogic.com/tutorial2/formats";

import module namespace extract-data = "http://www.marklogic.com/tutorial2/extract-data" 
    at "extract-data.xqy";
import module namespace search = "http://marklogic.com/appservices/search" 
    at "/MarkLogic/appservices/search/search.xqy";
declare namespace didl="urn:mpeg:mpeg21:2002:02-DIDL-NS";
declare namespace dii="urn:mpeg:mpeg21:2002:01-DII-NS";
declare namespace mms="http://www.massmed.org/elements/";

declare function formats:has-format($format as xs:string) {
    $format = ("xml","json","rss","csv")
};

declare private function create-xml($search-response as element(search:response)) {
    <response>
        <lst name="responseHeader">
            <int name="status">0</int>
            <int name="QTime">9</int>
            <lst name="params">
                <str name="q">{$search-response/search:qtext/text()}</str>
                <str name="bf"/>
                <str name="wt">xml</str>
                <str name="fq"></str>
            </lst>
        </lst>
        <result name="response" numFound="{$search-response/@total}" start="{$search-response/@start}" pageLength="{$search-response/@page-length}">
        {
        for $result in $search-response/search:result
        let $uri := $result/@uri
        let $article := fn:doc($uri)
        let $pub-date := extract-data:get-pub-date($article)/text()
        let $title := extract-data:get-article-title($article)/text()
        let $vips := extract-data:get-vips($article)
        let $journal-meta := extract-data:get-journal-meta($article)
        let $article-meta := extract-data:get-article-meta($article)
        let $doi := $article-meta/article-id[@pub-id-type='doi']/data()
        let $publisher := $journal-meta/publisher/publisher-name/text()
        return 
         <doc>
            <str name="id">{$doi}_nejm</str>
            <str name="pub_id">{$article-meta/article-id[@pub-id-type="publisher-id"]/data()}</str>
            <str name="nlm_ta">{$journal-meta/journal-id[@journal-id-type="nlm-ta"]/text()}</str>
            <str name="jn_pub_id">{$journal-meta/journal-id[@journal-id-type="publisher-id"]/text()}</str>
            <str name="collection">nejm</str>
            <str name="doi">{$doi}</str>
            <str name="ti">{$title}</str>
            <str name="ti_prime">{$title}</str>
            <str name="ti_serial"/>
            <str name="record_mpeg21">{$article//text()}</str>
            <str name="category">{extract-data:get-category($article)/text()}</str>
            <str name="article_type">Review</str>
            <str name="sub_article_type"/>
            <arr name="specialty_str"></arr>
            <arr name="sub_topic_str"></arr>
            <arr name="sub_topic"></arr>
            <arr name="specialty"></arr>
            <int name="vips_v">{$vips/mms:volume/data()}</int>
            <str name="vips_fpage">{$vips/mms:fpage/data()}</str>
            <str name="vips_i">{$vips/mms:issue/data()}</str>
            <str name="vips_lpage">{$vips/mms:lpage/data()}</str>
            <str name="vips_s">{$vips/mms:sequence/data()}</str>
            <int name="pub_year">2014</int>
            <int name="pub_month">2</int>
            <int name="pub_day">13</int>
            <str name="abs_d"/>
            <str name="abs_t">...</str>
            <str name="abs_s">...</str>
            <str name="abs_toc"/>
            <str name="abs_summary"/>
            <arr name="au_aff">...</arr>
            <str name="au_onbehalfof"/>
            <str name="collab"/>
            <arr name="au_surname">...</arr>
            <arr name="au_givenname">...</arr>
            <arr name="au_name">...</arr>
            <arr name="au_degree">...</arr>
            <str name="ar_file_name">...</str>
            <str name="z_pdf">...</str>
            <arr name="z_self_supplement">...</arr>
            <bool name="has_supplement">...</bool>
            <arr name="z_display_objects">...</arr>
            <bool name="has_display_objects">...</bool>
            <str name="ml_article_link">...</str>
            <str name="z_ppt_link">...</str>
            <bool name="has_ppt">true</bool>
            <str name="ml_cpf_state"/>
            <str name="ml_cpf_process_status"/>
            <date name="pub_date">{$pub-date}</date>
            <str name="pub_date_rss">{$pub-date}</str>
            <str name="pub_date_d">{$pub-date}</str>
            <int name="article_pages">...</int>
            <bool name="is_pap">...</bool>
            <bool name="is_free">...</bool>
            <str name="nlm_type">{extract-data:get-nlm-type($article)}</str>
            <str name="record_text">...</str>
            <bool name="has_cme">true</bool>
            <str name="doi_cme">10.1056/NEJMcme1301758</str>
            <arr name="fn_financial_disclosure">...</arr>
            <arr name="image_caption">...</arr>
            <str name="record_full">...</str>
            <date name="timestamp">...</date>
            <long name="_version_">...</long>
            <bool name="has_inline_graphics">...</bool>
            <bool name="has_attachment">...</bool>
         </doc>
        }
        </result>
    </response>
};

declare private function create-json($search-response as element(search:response)) {
    "Not Implemented :("
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

