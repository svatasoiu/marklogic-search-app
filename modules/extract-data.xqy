xquery version "1.0-ml";
module namespace extract-data = "http://www.marklogic.com/tutorial2/extract-data";
declare namespace didl="urn:mpeg:mpeg21:2002:02-DIDL-NS";
declare namespace mms="http://www.massmed.org/elements/";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace dcterms="http://purl.org/dc/terms/";
declare namespace prop="http://marklogic.com/xdmp/property";
declare namespace cpf="http://marklogic.com/cpf";

declare function extract-data:get-category($article as document-node()) as element(subject)? {
    $article/didl:DIDL/didl:Item/didl:Descriptor[@id='d400']/didl:Statement/article-meta/article-categories/subj-group[@subj-group-type='heading']/subject[1]
};

declare function extract-data:get-authors($article as document-node()) as element(contrib)* {
    $article/didl:DIDL/didl:Item/didl:Descriptor[@id='d400']/didl:Statement/article-meta/contrib-group/contrib[@contrib-type="author"]
};

declare function extract-data:get-authors-from-meta($meta as element(article-meta)) as element(contrib)* {
    $meta/contrib-group/contrib[@contrib-type="author"]
};

declare function extract-data:get-pub-date($article as document-node()) as element(mms:publicationDate)? {
    $article/didl:DIDL/didl:Item/didl:Descriptor[@id='d100']/didl:Statement/mms:publicationDate[1]
};

declare function extract-data:get-specialty-ids($article as document-node()) as xs:string* {
    $article/didl:DIDL/didl:Item/didl:Descriptor[@id='d310']/didl:Statement/subj-group/subj-group/subject/text()
};

declare function extract-data:get-topic-ids($article as document-node()) as xs:string* {
    $article/didl:DIDL/didl:Item/didl:Descriptor[@id='d310']/didl:Statement/subj-group/subject/text()
};

declare function extract-data:get-vips($article as document-node()) as element(mms:vips)? {
    $article/didl:DIDL/didl:Item/didl:Descriptor[@id='d240']/didl:Statement/mms:vips
};

declare function extract-data:get-volume-page($article as document-node()) as xs:string? {
    let $vips := extract-data:get-vips($article)
    return fn:concat(string($vips/mms:volume),':',string($vips/mms:fpage),'-',string($vips/mms:lpage))
};

declare function extract-data:get-doi($article as document-node()) as xs:string? {
    $article/didl:DIDL/didl:Item/didl:Descriptor[@id='d400']/didl:Statement/article-meta/article-id[@pub-id-type='doi']/data()
};

declare function extract-data:get-article-title($article as document-node()) as element(article-title)? {
    $article/didl:DIDL/didl:Item/didl:Descriptor[@id='d400']/didl:Statement/article-meta/title-group/article-title[1]
};

declare function extract-data:get-abstract($article as document-node()) as element(abstract)? {
    let $trunc-abs := $article/didl:DIDL/didl:Item/didl:Descriptor[@id='d400']/didl:Statement/article-meta/abstract[@abstract-type="truncated"]
    return if ($trunc-abs instance of node())
           then $trunc-abs
           else $article/didl:DIDL/didl:Item/didl:Descriptor[@id='d400']/didl:Statement/article-meta/abstract[1]
};

declare function extract-data:get-journal-title($article as document-node()) as element(journal-title)? {
    $article/didl:DIDL/didl:Item/didl:Descriptor[@id='d300']/didl:Statement/journal-meta/journal-title[1]
};

declare function extract-data:get-images($article as document-node()) as element(a)* {
    for $image in $article/didl:DIDL/didl:Item/didl:Container[@id='DisplayObjects']/didl:Component/didl:Descriptor/didl:Statement/rdf:RDF/rdf:Description
    let $tif   := $image/dcterms:hasFormat/rdf:Description/dcterms:identifier/text()
    let $jpg   := fn:replace($tif, "[.]tif", ".jpg")
    let $title := $image/mms:title/text()
    return 
        <a style="margin-left:10px;" href="{$jpg}" target="_blank">
            <img alt="Can't display image" title="{$title}" src="{$jpg}"
                onError="this.onerror=null; this.parentNode.href='{$tif}'; this.title='Cannot display image. Click to view'; this.src='{$tif}'" height="80"/>
        </a>
};

declare function extract-data:get-nlm-type($article as document-node()) as xs:string? {
    $article/didl:DIDL/didl:Item/didl:Descriptor[@id='d200']/didl:Statement/mms:articleType/text()
};

declare function extract-data:get-journal-meta($article as document-node()) as element(journal-meta)? {
    $article/didl:DIDL/didl:Item/didl:Descriptor[@id="d300"]/didl:Statement/journal-meta
};

declare function extract-data:get-publisher-from-jmeta($meta as element(journal-meta)) as xs:string? {
    $meta/publisher/publisher-name/text()
};

declare function extract-data:get-article-meta($article as document-node()) as element(article-meta)? {
    $article/didl:DIDL/didl:Item/didl:Descriptor[@id="d400"]/didl:Statement/article-meta
};

declare function extract-data:get-article-file-name($article as document-node()) as xs:string? {
    $article/didl:DIDL/didl:Item/didl:Descriptor[@id="d220"]/didl:Statement/mms:fileid/text()
};

declare function extract-data:get-article-pdf($article as document-node()) as xs:string? {
    $article/didl:DIDL/didl:Item/didl:Container[@id='Renditions']/didl:Component[@id='c130']/didl:Descriptor/didl:Statement/rdf:RDF/rdf:Description/dcterms:identifier/text()
};

declare function extract-data:get-article-supplements($article as document-node()) as xs:string* {
    $article/didl:DIDL/didl:Item/didl:Container[@id='Supplements']/didl:Component/didl:Descriptor/didl:Statement/rdf:RDF/rdf:Description/dcterms:hasFormat/rdf:Description/dcterms:identifier/text()
};

declare function extract-data:get-display-objects($article as document-node()) as xs:string* {
    $article/didl:DIDL/didl:Item/didl:Container[@id='DisplayObjects']/didl:Component/didl:Descriptor/didl:Statement/rdf:RDF/rdf:Description/dcterms:hasFormat/rdf:Description/dcterms:identifier/text()
};

declare function extract-data:get-inline-graphics($article as document-node()) as xs:string* {
    $article/didl:DIDL/didl:Item/didl:Container[@id='InlineGraphics']/didl:Component/didl:Descriptor/didl:Statement/rdf:RDF/rdf:Description/dcterms:hasFormat/rdf:Description/dcterms:identifier/text()
};

declare function extract-data:get-ml-link($article as document-node()) as xs:string? {
    $article/didl:DIDL/didl:Item/didl:Container[@id='Renditions']/didl:Component[@id='c100']/didl:Resource/@ref
};

declare function extract-data:get-ppt($article as document-node()) as xs:string? {
    $article/didl:DIDL/didl:Item/didl:Container[@id='Renditions']/didl:Component[@id='c160']/didl:Descriptor/didl:Statement/rdf:RDF/rdf:Description/dcterms:identifier/text()
};

declare function extract-data:is-free($article as document-node()) as xs:string {
    let $free := $article/didl:DIDL/didl:Item/didl:Descriptor[@id='d250']/didl:Statement/mms:freestatus/text()
    return if ($free and $free eq "Free") then "true" else "false"
};

declare function extract-data:get-cpf-properties($article as document-node()) as element(prop:properties)? {
    $article/didl:DIDL/didl:Item/didl:Descriptor[@id='d500']/didl:Statement/prop:properties
};

declare function extract-data:has-attachment($article as document-node()) as xs:string {
    let $att := $article/didl:DIDL/didl:Item/didl:Container[@id='Attachments']/didl:Component/didl:Descriptor/didl:Statement/rdf:RDF/rdf:Description/*/rdf:Description/dcterms:identifier
    return if ($att) then "true" else "false"
};

declare function extract-data:get-abstract-from-meta($meta as element(article-meta), $type as xs:string) as xs:string? {
    fn:string-join($meta/abstract[@abstract-type=$type]//text(),"")
};

declare function extract-data:get-id-from-jmeta($meta as element(journal-meta), $type as xs:string) as xs:string? {
    fn:string-join($meta/journal-id[@journal-id-type=$type]/text(),"")
};

declare function extract-data:get-pub-id($meta as element(article-meta)) as xs:string? {
    $meta/article-id[@pub-id-type="publisher-id"]/data()
};

declare function extract-data:get-series-title($meta as element(article-meta)) as xs:string? {
    $meta/article-categories/series-title/text()
};

declare function extract-data:get-sub-article-type($meta as element(article-meta)) as xs:string? {
    $meta/article-categories/subj-group[@subj-group-type='subheading']/subject/text()
};

declare function extract-data:get-author-names($authors as element(contrib)*) as element(name)* {
    $authors/name
};

declare function extract-data:get-author-surname($author as element(name)) as xs:string? {
    $author/surname/text()
};

declare function extract-data:get-author-degree($authors as element(contrib)*) as xs:string* {
    $authors/degrees/text()
};

declare function extract-data:get-author-given-name($author as element(name)) as xs:string? {
    $author/given-names/text()
};

declare function extract-data:get-renditions($article as document-node()) as element(span) {
    let $renditions := $article/didl:DIDL/didl:Item/didl:Container[@id="Renditions"]
    let $free := $article/didl:DIDL/didl:Item[1]/didl:Descriptor[@id="d250"]/didl:Statement/mms:freestatus/text()
    let $cme := $article/didl:DIDL/didl:Item/didl:Descriptor[@id="d410"]/didl:Statement/has-cme/text()
    let $xml := $renditions/didl:Component[@id="c100"]/didl:Resource/@ref
    let $mpeg21 := if ($xml) then fn:replace($xml, "nejm_nlm_articles", "nejm_nlm_mpeg21") else ()
    let $pdf := $renditions/didl:Component[@id="c130"]/didl:Resource/@ref
    let $ppt := $renditions/didl:Component[@id="c160"]/didl:Resource/@ref
    let $audio := $article/didl:DIDL/didl:Item/didl:Container[@id="Attachments"]/didl:Component/didl:Descriptor/didl:Statement/rdf:RDF/rdf:Description[dcterms:type="audio"]/dcterms:hasFormat/rdf:Description[dcterms:type="mp3"]/dcterms:identifier/text()
    let $mp4-video := $article/didl:DIDL/didl:Item/didl:Container[@id="Attachments"]/didl:Component/didl:Descriptor/didl:Statement/rdf:RDF/rdf:Description[dcterms:type="video"]/dcterms:hasFormat/rdf:Description[dcterms:type="m4v"]/dcterms:identifier/text()
    let $flv-video := $article/didl:DIDL/didl:Item/didl:Container[@id="Attachments"]/didl:Component/didl:Descriptor/didl:Statement/rdf:RDF/rdf:Description[dcterms:type="video"]/dcterms:hasFormat/rdf:Description[dcterms:type="flv"]/dcterms:identifier/text()
    let $vid-preview := $article/didl:DIDL/didl:Item/didl:Container[@id="Attachments"]/didl:Component/didl:Descriptor/didl:Statement/rdf:RDF/rdf:Description[dcterms:type="video"]/dcterms:hasPart/rdf:Description[dcterms:type="preview"]/dcterms:identifier/text()
    let $supplements := $article/didl:DIDL/didl:Item/didl:Container[@id="Supplements"]/didl:Component/didl:Descriptor/didl:Statement/rdf:RDF/rdf:Description[dcterms:type="author-supplement"]
    return
        <span class="title">
        <br/>
        {if ($mp4-video or $flv-video or $audio)
         then 
         <span>
            {if ($mp4-video or $flv-video) 
            then <div style="float:left;">
                   {if ($mp4-video) 
                   then (<a href="{if ($mp4-video) then $mp4-video else $flv-video}" target="_blank">Video (click to open)</a>,<br/>,
                        <video height="160" controls="" preload="none" poster="{$vid-preview}"><source src="{$mp4-video}" type="video/mp4"/></video>)
                   else <a href="{if ($mp4-video) then $mp4-video else $flv-video}" target="_blank">Video (click to open)<br/>
                         <img height="80" title="video" alt="video" src="{$vid-preview}"/></a>}
                 </div>
            else ()}
            {if ($audio) 
            then for $link in $audio
                 return <div style="float:left;"><a href="{$link}" target="_blank">Full Text Audio (click to open)</a>
                            <br/> 
                            <audio controls="" preload="none">
                                <source src="{$link}" type="audio/mpeg"/>
                            </audio>
                        </div>
            else ()}
         </span>
         else ()}
         <div style="clear:left;">
        {if ($free and $free eq "Free") 
        then <span><img width="60" height="12" border="0" alt="Free Full Text" title="Free Full Text" src="http://images.nejm.org/hila/etoc/flag_freeFullText.gif"/> | </span>
        else ()}
        {if ($cme and $cme eq "true") 
        then <span><img width="34" height="12" src="http://images.nejm.org/hila/etoc/flag_cme.gif" title="CME Exam" alt="CME Exam"/> | </span>
        else ()}
        {if ($pdf) 
        then <span><a href="{$pdf}" target="_blank">
                <img height="12" title="Article PDF" 
                alt="Article PDF" src="http://www.nejm.org/templates/jsp/_style2/_mms/_nejm/img/pdfIcon.gif"/>PDF</a> | </span>
        else ()}
        {if ($ppt) 
        then <span><a href="{$ppt}" target="_blank">
                <img height="12" title="slide" 
                alt="slide" src="http://www.nejm.org/templates/jsp/_style2/_mms/_nejm/img/downloadSlidesIcon.gif"/>Power Point</a> | </span>
        else ()}
        {if ($xml) 
        then <span><a href="{fn:replace($xml,"markl64stby[.]dom1","mark-ed")}" target="_blank">XML</a> | </span>
        else ()}
        {if ($mpeg21) 
        then <span><a href="{fn:replace($mpeg21,"markl64stby[.]dom1","mark-ed")}" target="_blank">Mpeg21</a></span>
        else ()}
        <!-- supplements -->
        {if ($supplements) 
        then <span><br/><hr/>Supplements: 
             {for $supplement in $supplements
             return <span><a href="{$supplement/dcterms:hasFormat/rdf:Description/dcterms:identifier/text()}" target="_blank">
                        <img height="12" title="Article PDF" alt="Article PDF" src="http://www.nejm.org/templates/jsp/_style2/_mms/_nejm/img/pdfIcon.gif"/>
                        {$supplement/dcterms:title/label/text()}
                     </a> | </span>}</span>
        else ()}
        </div>
        </span>
};


