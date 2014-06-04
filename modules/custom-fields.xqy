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

declare namespace cts    = "http://marklogic.com/cts";

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

        let $subject := fn:string($right//cts:text/text())
        return
            if($qtext eq "category:") then (
                 cts:path-range-query (  "/didl:DIDL/didl:Item/didl:Descriptor[@id='d310']/didl:Statement/subj-group/subj-group/subject",
                                         "=",
                                         $subject,
                                         "collation=http://marklogic.com/collation/"                                         
                                      )
            ) else ()         
	}</root>/*
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

