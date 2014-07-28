xquery version "1.0-ml";
module namespace extract-data = "http://www.marklogic.com/tutorial2/extract-data";
declare namespace didl="urn:mpeg:mpeg21:2002:02-DIDL-NS";
declare namespace mms="http://www.massmed.org/elements/";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace dcterms="http://purl.org/dc/terms/";

declare function extract-data:get-category($article as document-node()) as element(subject)? {
    $article/didl:DIDL/didl:Item/didl:Descriptor[@id='d400']/didl:Statement/article-meta/article-categories/subj-group[@subj-group-type='heading']/subject[1]
};

declare function extract-data:get-authors($article as document-node()) as element(contrib)* {
    $article/didl:DIDL/didl:Item/didl:Descriptor[@id='d400']/didl:Statement/article-meta/contrib-group/contrib[@contrib-type="author"]
};

declare function extract-data:get-pub-date($article as document-node()) as element(mms:publicationDate)? {
    $article/didl:DIDL/didl:Item/didl:Descriptor[@id='d100']/didl:Statement/mms:publicationDate[1]
};

declare function extract-data:get-vips($article as document-node()) as element(mms:vips) {
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
    /didl:DIDL/didl:Item/didl:Descriptor[@id='d200']/didl:Statement/mms:articleType/text()
};

declare function extract-data:get-journal-meta($article as document-node()) as element(journal-meta) {
    $article/didl:DIDL/didl:Item/didl:Descriptor[@id="d300"]/didl:Statement/journal-meta
};

declare function extract-data:get-article-meta($article as document-node()) as element(article-meta) {
    $article/didl:DIDL/didl:Item/didl:Descriptor[@id="d400"]/didl:Statement/article-meta
};