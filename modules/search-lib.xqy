xquery version "1.0-ml";
module namespace search-lib = "http://www.marklogic.com/tutorial2/search-lib";
declare namespace didl="urn:mpeg:mpeg21:2002:02-DIDL-NS";
declare namespace custom-field-query = "http://www.xplana.com/custom-field-query";

import module namespace search = "http://marklogic.com/appservices/search"
    at "/MarkLogic/appservices/search/search.xqy";

declare option xdmp:mapping "false";
declare variable $DIRECTORY := "/nejm_nlm_mpeg21/";
declare variable $OPTIONS :=   

 <search:options xmlns="http://marklogic.com/appservices/search">
  <search:search-option>filtered</search:search-option>  <!-- [SUPPORT !11762] -->
  <search:debug>true</search:debug>
  <search:term>
   <search:empty apply="all-results"/>
   <search:term-option>wildcarded</search:term-option>
   <search:term-option>case-insensitive</search:term-option>
   <search:term-option>punctuation-insensitive</search:term-option>
   <search:term-option>diacritic-insensitive</search:term-option>
  </search:term>
  <search:grammar>
    <search:starter strength="30" apply="grouping" delimiter=")">(</search:starter>
    <search:starter strength="40" apply="prefix" element="cts:not-query">-</search:starter>
    <search:joiner strength="10" apply="infix" element="cts:or-query" tokenize="word">OR</search:joiner>
    <search:joiner strength="20" apply="infix" element="cts:and-query" tokenize="word">AND</search:joiner>
    <search:joiner strength="20" apply="element-joiner" ns="http://www.nejm.org/custom-field-query" at="/modules/custom-fields.xqy" element="cts:element-query" tokenize="word">CHILD</search:joiner>
    <search:joiner strength="50" apply="constraint" compare="LT" tokenize="word">LT</search:joiner>
    <search:joiner strength="50" apply="constraint" compare="LE" tokenize="word">LE</search:joiner>
    <search:joiner strength="50" apply="constraint" compare="GT" tokenize="word">GT</search:joiner>
    <search:joiner strength="50" apply="constraint" compare="GE" tokenize="word">GE</search:joiner>
    <search:joiner strength="50" apply="constraint" compare="NE" tokenize="word">NE</search:joiner>
    <search:quotation>"</search:quotation>
    <search:joiner strength="50" apply="constraint">:</search:joiner>
  </search:grammar>
  
  <search:additional-query xmlns="http://marklogic.com/appservices/search">
    { cts:directory-query($DIRECTORY, "infinity") }
  </search:additional-query>
  
  <constraint name="has-cme" xmlns="http://marklogic.com/appservices/search">
    <range type="xs:string" facet="true" collation="http://marklogic.com/collation/">
      <element ns="" name="has-cme"/>
    </range>
  </constraint>
  
  <constraint name="date" xmlns="http://marklogic.com/appservices/search">
    <range type="xs:date" facet="true">
      <element ns="http://www.massmed.org/elements/" name="publicationDate"/>
      <computed-bucket lt="-P1Y" anchor="start-of-year" name="older">Older</computed-bucket>
      <computed-bucket lt="P1Y" ge="P0Y" anchor="start-of-year" name="year">This Year</computed-bucket>
      <computed-bucket lt="P0D" ge="-P90D" anchor="start-of-day" name="90days">Past 90 Days</computed-bucket>
      <computed-bucket lt="P1M" ge="P0M" anchor="start-of-month" name="month">This Month</computed-bucket>
      <computed-bucket lt="P1D" ge="P0D" anchor="start-of-day" name="today">Today</computed-bucket>
      <computed-bucket ge="P0D" anchor="now" name="future">Future</computed-bucket>
      <facet-option>descending</facet-option>
    </range>
  </constraint>
  
  <search:constraint name="category">
    <search:custom facet="true">
	     <search:parse apply="category" ns="http://www.nejm.org/custom-field-query" 
	       at="/modules/custom-fields.xqy"/>
	       <search:start-facet apply="start-category" ns="http://www.nejm.org/custom-field-query" 
	       at="/modules/custom-fields.xqy"/>
	     <search:finish-facet apply="finish" ns="http://www.nejm.org/custom-field-query" 
	       at="/modules/custom-fields.xqy"/>
	  </search:custom>
  </search:constraint>
  
  <search:constraint name="topic">
	  <search:custom facet="true">
	     <search:parse apply="topic" ns="http://www.nejm.org/custom-field-query" 
	       at="/modules/custom-fields.xqy"/>
	     <search:start-facet apply="start-topic" ns="http://www.nejm.org/custom-field-query" 
	       at="/modules/custom-fields.xqy"/>
	     <search:finish-facet apply="finish-topic" ns="http://www.nejm.org/custom-field-query" 
	       at="/modules/custom-fields.xqy"/>
	  </search:custom>
  </search:constraint>
  
  <search:constraint name="specialty">
	  <search:custom facet="true">
	     <search:parse apply="specialty" ns="http://www.nejm.org/custom-field-query" 
	       at="/modules/custom-fields.xqy"/>
	     <search:start-facet apply="start-specialty" ns="http://www.nejm.org/custom-field-query" 
	       at="/modules/custom-fields.xqy"/>
	     <search:finish-facet apply="finish-specialty" ns="http://www.nejm.org/custom-field-query" 
	       at="/modules/custom-fields.xqy"/>
	  </search:custom>
  </search:constraint>
  
   <search:constraint name="authorSurname">
	 <search:custom facet="false">
	     <search:parse apply="authorSurname" ns="http://www.nejm.org/custom-field-query" 
	       at="/modules/custom-fields.xqy"/>
	 </search:custom>
  </search:constraint>  
   
  <!-- 
  <search:constraint name="pubDate">
    <search:value>
      <search:element ns="mms" name="publicationDate"/>
    </search:value>
  </search:constraint>
-->
<!--  <search:constraint name="pubDate">
    <search:range type="xs:date" facet="false">
      <search:element ns="http://www.massmed.org/elements/" name="publicationDate"/>
    </search:range>
  </search:constraint> -->
  
  <search:constraint name="doi">
    <search:value>
      <search:element ns="urn:mpeg:mpeg21:2002:01-DII-NS" name="Identifier"/>
    </search:value>
  </search:constraint>  

  <search:constraint name="title">
    <search:value>
      <search:element ns="" name="article-title"/>
    </search:value>
  </search:constraint>  
  
  <search:constraint name="year">
	  <search:custom facet="false">
	     <search:parse apply="year" ns="http://www.nejm.org/custom-field-query" 
	       at="/modules/custom-fields.xqy"/>
	  </search:custom>
  </search:constraint>

  <search:constraint name="manuscriptId">
	  <search:custom facet="false">
	     <search:parse apply="manuscriptId" ns="http://www.nejm.org/custom-field-query" at="/modules/custom-fields.xqy"/>
	  </search:custom>
  </search:constraint>
  
  <search:operator name="sort">
    <search:state name="relevance">
      <search:sort-order>
        <search:score/>
      </search:sort-order>
    </search:state>
    <search:state name="pub-date">
      <search:sort-order direction="descending" type="xs:string" collation="http://marklogic.com/collation/">
        <search:element ns="http://www.massmed.org/elements/" name="publicationDate"/>
      </search:sort-order>
      <search:sort-order>
        <search:score/>
      </search:sort-order>
    </search:state>
    <search:state name="title">
      <search:sort-order direction="ascending" type="xs:string" collation="http://marklogic.com/collation/">
        <search:element ns="" name="article-title"/>
      </search:sort-order>
      <search:sort-order>
        <search:score/>
      </search:sort-order>
    </search:state>
  </search:operator>

  <search:return-query xmlns="http://marklogic.com/appservices/search">false</search:return-query>
  <search:return-facets xmlns="http://marklogic.com/appservices/search">true</search:return-facets>
  <search:return-metrics xmlns="http://marklogic.com/appservices/search">true</search:return-metrics>
</search:options> ;
      
declare function search-lib:get-with-default-int($field as item()*, $default as xs:integer)
as xs:integer {
    if ($field) 
    then xs:integer($field)
    else $default
};
      
declare function search-lib:my-search($search-query as item()*,
   $start as item()*,
   $page-length as item()*,
   $query-string as xs:string,
   $targets as xs:string?) 
as element(search:response) {
    if ($targets)
    then let $targets := fn:tokenize($targets, ",")
         let $additional-query := 
                         <additional-query xmlns="http://marklogic.com/appservices/search">
                           { cts:or-query( 
                                for $target in $targets
                                return cts:element-word-query(fn:QName("", $target),
                                                    $query-string,
                                                    ("case-insensitive", "punctuation-insensitive"))) }
                         </additional-query>
         let $options := <options xmlns="http://marklogic.com/appservices/search">
                           {$OPTIONS/*}
                           { $additional-query }
                         </options>
         return search:search($search-query, $options, $start, $page-length)
    else search:search($search-query, $OPTIONS, $start, $page-length)
};