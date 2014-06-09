(:
   This module contains functions implementing the custom queries used by the cdsSearch.xqy, which implements the search:search calls to be made by CDS -
   as a replacement for the current Solr queries.
:)

xquery version "1.0-ml";

module namespace custom-field-query = "http://www.nejm.org/custom-field-query";

declare namespace didl="urn:mpeg:mpeg21:2002:02-DIDL-NS";
declare namespace dii="urn:mpeg:mpeg21:2002:01-DII-NS";

import module namespace search = "http://marklogic.com/appservices/search" 
  at "/MarkLogic/appservices/search/search.xqy";
import module namespace topics = "http://www.nejm.org/topics"
  at "topics.xqy";
import module namespace specialties  = "http://www.nejm.org/specialties"
  at "specialties.xqy";

declare namespace cts    = "http://marklogic.com/cts";

declare variable $topic-table := topics:get-topics();
declare variable $spec-table  := specialties:get-specialties();
declare variable $specialty-path := "/didl:DIDL/didl:Item/didl:Descriptor[@id='d310']/didl:Statement/subj-group/subj-group/subject";
declare variable $topic-path := "/didl:DIDL/didl:Item/didl:Descriptor[@id='d310']/didl:Statement/subj-group/subject";
declare variable $collation := "collation=http://marklogic.com/collation/en/S1";

declare variable $OPTIONS := ("case-insensitive","punctuation-insensitive","diacritic-insensitive");

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
        let $spec-id  := fn:string(($spec-table/specialty[@spec eq $specialty]/@id)[1])
        return
            if($qtext eq "specialty:") then (
                 cts:path-range-query ($specialty-path, "=", $spec-id, $collation)
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
    for $spec in cts:values(cts:path-reference($specialty-path, ($collation)),
                                 (),
                                 ($facet-options,"concurrent"),
                                 $query,
                                 $quality-weight,
                                 $forests)
    let $spec-name := fn:string($spec-table/specialty[@id eq $spec]/@spec)
    order by $spec-name
    return <specialty-type spec="{$spec-name}" count="{cts:frequency($spec)}"/>
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
            attribute name { $range/@spec }, 
            attribute count { $range/@count }, 
            fn:string($range/@spec) (: look up proper name :)
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
        let $top-id  := fn:string(($topic-table/topic[@top eq $topic]/@id)[1])
        return
            if($qtext eq "topic:") then (
                 cts:path-range-query ($topic-path, "=", $top-id, $collation)
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
    for $top in cts:values(cts:path-reference($topic-path, ($collation)),
                                 (),
                                 ($facet-options,"concurrent"),
                                 $query,
                                 $quality-weight,
                                 $forests)
    let $top-name := fn:string($topic-table/topic[@id eq $top]/@top)
    order by $top-name
    return <topic-type top="{$top-name}" count="{cts:frequency($top)}"/>
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
            attribute name { $range/@top }, 
            attribute count { $range/@count }, 
            fn:string($range/@top) (: look up proper name :)
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


(: 
   Returns a cts-query that searches documents with elements named "Identifier" having values enumerated in the $doi-list.

   The $doi-list is a list of doi's of documents having the given subject .
:)

declare function custom-field-query:authorSurname (
	$qtext as xs:string,
	$right as schema-element(cts:query)) 
as schema-element(cts:query)	
{

    <root>{

        let $authorSurname := fn:string($right//cts:text/text())
        return
            if($qtext eq "authorSurname:") then (
                 cts:path-range-query (  "/didl:DIDL/didl:Item/didl:Descriptor[@id='d400']/didl:Statement/article-meta/contrib-group/contrib[@contrib-type='author']/name/surname",
                                         "=",
                                         $authorSurname,
                                         "collation=http://marklogic.com/collation/"
                                      )            
            ) else ()
            
	}</root>/*
};

