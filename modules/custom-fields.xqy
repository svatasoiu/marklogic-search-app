(:
   This module contains functions implementing the custom queries used by the cdsSearch.xqy, which implements the search:search calls to be made by CDS -
   as a replacement for the current Solr queries.
:)

xquery version "1.0-ml";

module namespace custom-field-query = "http://www.nejm.org/custom-field-query";

declare namespace didl="urn:mpeg:mpeg21:2002:02-DIDL-NS";
declare namespace dii="urn:mpeg:mpeg21:2002:01-DII-NS";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace dcterms="http://purl.org/dc/terms/";

import module namespace search = "http://marklogic.com/appservices/search" 
  at "/MarkLogic/appservices/search/search.xqy";
import module namespace topics = "http://www.nejm.org/topics"
  at "topics.xqy";
import module namespace specialties  = "http://www.nejm.org/specialties"
  at "specialties.xqy";
  import module namespace perspectives  = "http://www.nejm.org/perspectives"
  at "perspectives.xqy";

declare namespace cts = "http://marklogic.com/cts";

declare variable $CATEGORY-PATH := "/didl:DIDL/didl:Item/didl:Descriptor[@id='d400']/didl:Statement/article-meta/article-categories/subj-group[@subj-group-type='heading']/subject";
declare variable $SPECIALTY-PATH := "/didl:DIDL/didl:Item/didl:Descriptor[@id='d310']/didl:Statement/subj-group/subj-group/subject";
declare variable $TOPIC-PATH := "/didl:DIDL/didl:Item/didl:Descriptor[@id='d310']/didl:Statement/subj-group/subject";
declare variable $PERSP-TOPIC-PATH := "/didl:DIDL/didl:Item/didl:Descriptor[@id='d320']/didl:Statement/subj-group[@subj-group-type='nejm-perspective-topics']/subject";
declare variable $COLLATION := "collation=http://marklogic.com/collation/en/S1";

declare variable $OPTIONS := ("case-insensitive","punctuation-insensitive","diacritic-insensitive");

declare function custom-field-query:start (
 $constraint as element(search:constraint),
 $query as cts:query?,
 $facet-options as xs:string*,
 $quality-weight as xs:double?,
 $forests as xs:unsignedLong*,
 $path as xs:string) 
as item()* {
    for $item in cts:values(cts:path-reference($path, ($COLLATION)),
                                 (),
                                 ($facet-options,"concurrent"),
                                 $query,
                                 $quality-weight,
                                 $forests)
    return <item-type name="{$item}" count="{cts:frequency($item)}"/>
};

declare function custom-field-query:finish (
 $start as item()*,
 $constraint as element(search:constraint), 
 $query as cts:query?,
 $facet-options as xs:string*,
 $quality-weight as xs:double?, 
 $forests as xs:unsignedLong*)
as element(search:facet) {
   element search:facet {
     attribute name {$constraint/@name},
     for $range in $start 
     return 
        element search:facet-value { 
            attribute name { $range/@name }, 
            attribute count { $range/@count },
            fn:string($range/@name)
        }
   }
};

declare function custom-field-query:has-audio (
	$qtext as xs:string,
	$right as schema-element(cts:query)) 
as schema-element(cts:query)	
{
    <root>{
        let $has := fn:string($right//cts:text/text())
        return
            if ($qtext eq "has_audio:") 
            then if ($has eq "true")
                 then cts:element-query(xs:QName("rdf:Description"), 
                                        cts:and-query((cts:element-value-query(xs:QName("dcterms:type"),"audio"))))
                 else cts:not-query(cts:element-query(xs:QName("rdf:Description"), 
                                        cts:and-query((cts:element-value-query(xs:QName("dcterms:type"),"audio")))))
            else ()    
	}</root>/*
};

declare function custom-field-query:has-video (
	$qtext as xs:string,
	$right as schema-element(cts:query)) 
as schema-element(cts:query)	
{
    <root>{
        let $has := fn:string($right//cts:text/text())
        return
            if ($qtext eq "has_video:") 
            then if ($has eq "true")
                 then cts:element-query(xs:QName("rdf:Description"), 
                                        cts:or-query((cts:element-value-query(xs:QName("dcterms:type"),"video"),
                                                      cts:element-value-query(xs:QName("dcterms:type"),"vcm-video"))))
                 else cts:not-query(cts:element-query(xs:QName("rdf:Description"), 
                                        cts:or-query((cts:element-value-query(xs:QName("dcterms:type"),"video"),
                                                      cts:element-value-query(xs:QName("dcterms:type"),"vcm-video")))))
            else ()    
	}</root>/*
};

declare function custom-field-query:category (
	$qtext as xs:string,
	$right as schema-element(cts:query)) 
as schema-element(cts:query)	
{
    <root>{
        let $category := fn:string($right//cts:text/text())
        return
            if ($qtext eq "category:") then 
               cts:element-query(xs:QName("didl:Descriptor"), 
                   cts:and-query((cts:element-attribute-value-query(xs:QName("didl:Descriptor"),
                                                                    xs:QName("id"),
                                                                    "d400"),
                                  cts:element-value-query ( xs:QName ("subject"), $category )
                   ))
               )
            else ()    
	}</root>/*
};

declare function custom-field-query:start-category (
 $constraint as element(search:constraint),
 $query as cts:query?,
 $facet-options as xs:string*,
 $quality-weight as xs:double?,
 $forests as xs:unsignedLong*) 
as item()* {
    start($constraint,$query, $facet-options, $quality-weight, $forests, $CATEGORY-PATH)
};

(: 
   Returns a cts-query that searches documents with elements named "Identifier" having values enumerated in the $doi-list.

   The $doi-list is a list of doi's of documents having the given subject number.
:)
declare function custom-field-query:specialty (
	$qtext as xs:string,
	$right as schema-element(cts:query)) 
as schema-element(cts:query)	
{
    <root>{

        let $specialty := fn:string($right//cts:text/text()) (: convert from str to id :)
        let $spec-id  := specialties:str-to-id($specialty)
        return
            if($qtext eq "specialty:") then (
                 cts:path-range-query ($SPECIALTY-PATH, "=", $spec-id, "collation=http://marklogic.com/collation/")
            ) else ()         
	}</root>/*
};

declare function custom-field-query:start-specialty (
 $constraint as element(search:constraint),
 $query as cts:query?,
 $facet-options as xs:string*,
 $quality-weight as xs:double?,
 $forests as xs:unsignedLong*) 
as item()* {
    for $id in cts:values(cts:path-reference($SPECIALTY-PATH, ("collation=http://marklogic.com/collation/")),
                                 (),
                                 ($facet-options,"concurrent"),
                                 $query,
                                 $quality-weight,
                                 $forests)
    let $spec-name := specialties:id-to-str($id)
    order by $spec-name
    return if ($spec-name) then <specialty-type name="{$spec-name}" count="{cts:frequency($id)}"/> else ()
};

declare function custom-field-query:finish-specialty (
 $start as item()*,
 $constraint as element(search:constraint), 
 $query as cts:query?,
 $facet-options as xs:string*,
 $quality-weight as xs:double?, 
 $forests as xs:unsignedLong*)
as element(search:facet) {
   element search:facet {
     attribute name {$constraint/@name},
     for $range in $start 
     return 
        element search:facet-value { 
            attribute name { $range/@name }, 
            attribute count { $range/@count }, 
            fn:string($range/@name) (: look up proper name :)
        }
   }
};

(: 
   Returns a cts-query that searches documents with elements named "Identifier" having values enumerated in the $doi-list.

   The $doi-list is a list of doi's of documents having the given subject number.
:)
declare function custom-field-query:topic (
	$qtext as xs:string,
	$right as schema-element(cts:query)) 
as schema-element(cts:query)	
{
    <root>{

        let $topic := fn:string($right//cts:text/text()) (: convert from str to id :)
        let $top-id  := topics:str-to-id($topic)
        return
            if($qtext eq "topic:") then (
                 cts:path-range-query ($TOPIC-PATH, "=", $top-id, $COLLATION)
            ) else ()         
	}</root>/*
};

declare function custom-field-query:start-topic (
 $constraint as element(search:constraint),
 $query as cts:query?,
 $facet-options as xs:string*,
 $quality-weight as xs:double?,
 $forests as xs:unsignedLong*) 
as item()* {
    for $id in cts:values(cts:path-reference($TOPIC-PATH, ($COLLATION)),
                                 (),
                                 ($facet-options,"concurrent"),
                                 $query,
                                 $quality-weight,
                                 $forests)
    let $top-name := topics:id-to-str($id)
    order by $top-name
    return if ($top-name) then <topic-type name="{$top-name}" count="{cts:frequency($id)}"/> else ()
};

declare function custom-field-query:finish-topic (
 $start as item()*,
 $constraint as element(search:constraint), 
 $query as cts:query?,
 $facet-options as xs:string*,
 $quality-weight as xs:double?, 
 $forests as xs:unsignedLong*)
as element(search:facet) {
    element search:facet {
     attribute name {$constraint/@name},
     for $range in $start 
     return 
        element search:facet-value{ 
            attribute name { $range/@name }, 
            attribute count { $range/@count }, 
            fn:string($range/@name) (: look up proper name :)
        }
     }
};

(: 
   Returns a cts-query that searches documents with pubdates between lower and upper
:)
declare function custom-field-query:year (
	$qtext as xs:string,
	$right as schema-element(cts:query)) 
as schema-element(cts:query)	
{
    <root>{

        let $year-range := fn:string($right//cts:text/text())
        let $split := fn:tokenize($year-range, "[-]")
        return
            if($qtext eq "year:") then (
                cts:and-query(
                    (cts:path-range-query("/didl:DIDL/didl:Item/didl:Descriptor[@id='d400']/didl:Statement/article-meta/pub-date/year",
                                         ">=",
                                         xs:gYear($split[1])),
                    cts:path-range-query("/didl:DIDL/didl:Item/didl:Descriptor[@id='d400']/didl:Statement/article-meta/pub-date/year",
                                         "<=",
                                         xs:gYear($split[2])))
                )
            ) else ()         
	}</root>/*
};
declare function custom-field-query:month (
	$qtext as xs:string,
	$right as schema-element(cts:query)) 
as schema-element(cts:query)	
{
    <root>{

        let $month := fn:string($right//cts:text/text())
        return
            if($qtext eq "month:") then (
                cts:and-query(
                    (cts:path-range-query("/didl:DIDL/didl:Item/didl:Descriptor[@id='d400']/didl:Statement/article-meta/pub-date/month",
                                         "=",
                                        $month))
                )
            ) else ()         
	}</root>/*
};

(: 
   Returns a cts-query that searches documents with elements named "Identifier" having values enumerated in the $doi-list.

   The $doi-list is a list of doi's of documents having the given subject .
:)
declare function custom-field-query:manuscriptId (
	$qtext as xs:string,
	$right as schema-element(cts:query)) 
as schema-element(cts:query)	
{

    <root>{

        let $manuscriptId := fn:string($right//cts:text/text())
        let $identifier := fn:concat("NEJMp", $manuscriptId)
        let $doi-list := /didl:DIDL[didl:Item/didl:Descriptor[@id='d210']/didl:Statement[fn:ends-with(dii:Identifier, $identifier)]]/@DIDLDocumentId
        return
            if($qtext eq "manuscriptId:") then (
                cts:and-query((
                    cts:element-value-query(fn:QName("urn:mpeg:mpeg21:2002:01-DII-NS","Identifier"), $doi-list)
                ))
            ) else ()
            
	}</root>/*
};

declare function custom-field-query:authorSurname (
	$qtext as xs:string,
	$right as schema-element(cts:query)) 
as schema-element(cts:query)	
{
    <root>{
        let $author := fn:string($right//cts:text/text())
        return
            if ($qtext eq "authorSurname:") then 
               cts:element-query(xs:QName("didl:Descriptor"), 
                   cts:and-query((cts:element-attribute-value-query(xs:QName("didl:Descriptor"),
                                                                    xs:QName("id"),
                                                                    "d400"),
                                  cts:element-value-query ( xs:QName ("surname"), $author )
                   ))
               )
            else ()    
	}</root>/*
};

declare function custom-field-query:persp-topic-str (
	$qtext as xs:string,
	$right as schema-element(cts:query)) 
as schema-element(cts:query)	
{
    <root>{

        let $top := fn:string($right//cts:text/text()) (: convert from str to id :)
        let $top-id  := perspectives:str-to-id($top)
        return
            if($qtext eq "persp-topic-str:") then (
                 cts:path-range-query ($PERSP-TOPIC-PATH, "=", $top-id, "collation=http://marklogic.com/collation/")
            ) else ()         
	}</root>/*
};

declare function custom-field-query:start-persp-topic-str (
 $constraint as element(search:constraint),
 $query as cts:query?,
 $facet-options as xs:string*,
 $quality-weight as xs:double?,
 $forests as xs:unsignedLong*) 
as item()* {
    for $id in cts:values(cts:path-reference($PERSP-TOPIC-PATH, ("collation=http://marklogic.com/collation/")),
                                 (),
                                 ($facet-options,"concurrent"),
                                 $query,
                                 $quality-weight,
                                 $forests)
    let $top-name :=  perspectives:id-to-str($id)
    order by $top-name
    return if ($top-name) then <perspective-type topic="{$top-name}" count="{cts:frequency($id)}"/> else ()
};

declare function custom-field-query:finish-persp-topic-str (
 $start as item()*,
 $constraint as element(search:constraint), 
 $query as cts:query?,
 $facet-options as xs:string*,
 $quality-weight as xs:double?, 
 $forests as xs:unsignedLong*)
as element(search:facet) {
   element search:facet {
     attribute name {$constraint/@name},
     for $range in $start 
     return 
        element search:facet-value { 
            attribute name { $range/@topic }, 
            attribute count { $range/@count }, 
            fn:string($range/@topic) (: look up proper name :)
        }
   }
};
