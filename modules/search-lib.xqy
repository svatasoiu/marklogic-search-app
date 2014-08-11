xquery version "1.0-ml";
module namespace search-lib = "http://www.marklogic.com/tutorial2/search-lib";
declare namespace didl="urn:mpeg:mpeg21:2002:02-DIDL-NS";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace dcterms="http://purl.org/dc/terms/";
declare namespace custom-field-query = "http://www.xplana.com/custom-field-query";

import module namespace search = "http://marklogic.com/appservices/search"
    at "/MarkLogic/appservices/search/search.xqy";

declare option xdmp:mapping "false";
declare variable $DIRECTORY := "/nejm_nlm_mpeg21/";
declare variable $OPTIONS :=   
 <options xmlns="http://marklogic.com/appservices/search">
  <search-option>unfiltered</search-option>
  <debug>false</debug>
  <term>
   <empty apply="all-results"/>
   <term-option>wildcarded</term-option>
   <term-option>case-insensitive</term-option>
   <term-option>punctuation-insensitive</term-option>
   <term-option>diacritic-insensitive</term-option>
  </term>
  <grammar>
    <starter strength="30" apply="grouping" delimiter=")">(</starter>
    <starter strength="40" apply="prefix" element="cts:not-query">-</starter>
    <joiner strength="10" apply="infix" element="cts:or-query" tokenize="word">OR</joiner>
    <joiner strength="20" apply="infix" element="cts:and-query" tokenize="word">AND</joiner>
    <joiner strength="20" apply="element-joiner" ns="http://www.nejm.org/custom-field-query" at="/modules/custom-fields.xqy" element="cts:element-query" tokenize="word">CHILD</joiner>
    <joiner strength="50" apply="constraint" compare="LT" tokenize="word">LT</joiner>
    <joiner strength="50" apply="constraint" compare="LE" tokenize="word">LE</joiner>
    <joiner strength="50" apply="constraint" compare="GT" tokenize="word">GT</joiner>
    <joiner strength="50" apply="constraint" compare="GE" tokenize="word">GE</joiner>
    <joiner strength="50" apply="constraint" compare="NE" tokenize="word">NE</joiner>
    <quotation>"</quotation>
    <joiner strength="50" apply="constraint">:</joiner>
  </grammar>
  
  <additional-query xmlns="http://marklogic.com/appservices/search">
    { cts:directory-query($DIRECTORY, "infinity") }
  </additional-query>
    
  <constraint name="issue-date" xmlns="http://marklogic.com/appservices/search">
    <range type="xs:date" facet="true">
      <element ns="http://www.massmed.org/elements/" name="publicationDate"/>
      <facet-option>descending</facet-option>
      <facet-option>limit=6</facet-option>
    </range>
  </constraint>
  
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
  
  <constraint name="category">
    <custom facet="true">
	     <parse apply="category" ns="http://www.nejm.org/custom-field-query" 
	       at="/modules/custom-fields.xqy"/>
	       <start-facet apply="start-category" ns="http://www.nejm.org/custom-field-query" 
	       at="/modules/custom-fields.xqy"/>
	     <finish-facet apply="finish" ns="http://www.nejm.org/custom-field-query" 
	       at="/modules/custom-fields.xqy"/>
	  </custom>
  </constraint>
  
  <constraint name="topic">
	  <custom facet="true">
	     <parse apply="topic" ns="http://www.nejm.org/custom-field-query" 
	       at="/modules/custom-fields.xqy"/>
	     <start-facet apply="start-topic" ns="http://www.nejm.org/custom-field-query" 
	       at="/modules/custom-fields.xqy"/>
	     <finish-facet apply="finish-topic" ns="http://www.nejm.org/custom-field-query" 
	       at="/modules/custom-fields.xqy"/>
	  </custom>
  </constraint>
  
  <constraint name="specialty">
	  <custom facet="true">
	     <parse apply="specialty" ns="http://www.nejm.org/custom-field-query" 
	       at="/modules/custom-fields.xqy"/>
	     <start-facet apply="start-specialty" ns="http://www.nejm.org/custom-field-query" 
	       at="/modules/custom-fields.xqy"/>
	     <finish-facet apply="finish-specialty" ns="http://www.nejm.org/custom-field-query" 
	       at="/modules/custom-fields.xqy"/>
	  </custom>
  </constraint>
  
  <constraint name="persp-topic-str" xmlns="http://marklogic.com/appservices/search">
	  <custom facet="true">
	     <parse apply="persp-topic-str" ns="http://www.nejm.org/custom-field-query" 
	       at="/modules/custom-fields.xqy"/>
	     <start-facet apply="start-persp-topic-str" ns="http://www.nejm.org/custom-field-query" 
	       at="/modules/custom-fields.xqy"/>
	     <finish-facet apply="finish-persp-topic-str" ns="http://www.nejm.org/custom-field-query" 
	       at="/modules/custom-fields.xqy"/>
	  </custom>
  </constraint>
  
  <constraint name="nlm-type" xmlns="http://marklogic.com/appservices/search">
    <range type="xs:string" facet="true" collation="http://marklogic.com/collation/">
      <element ns="http://www.massmed.org/elements/" name="articleType"/>
    </range>
  </constraint>
  
  <constraint name="has_audio">
	 <custom facet="false">
	     <parse apply="has-audio" ns="http://www.nejm.org/custom-field-query" 
	       at="/modules/custom-fields.xqy"/>
	 </custom>
  </constraint>
  
  <constraint name="has_video">
	 <custom facet="false">
	     <parse apply="has-video" ns="http://www.nejm.org/custom-field-query" 
	       at="/modules/custom-fields.xqy"/>
	 </custom>
  </constraint>
  
  <constraint name="authorSurname">
	 <custom facet="false">
	     <parse apply="authorSurname" ns="http://www.nejm.org/custom-field-query" 
	       at="/modules/custom-fields.xqy"/>
	 </custom>
  </constraint>  
   
  <constraint name="doi">
    <value>
      <element ns="urn:mpeg:mpeg21:2002:01-DII-NS" name="Identifier"/>
    </value>
  </constraint>  

  <constraint name="title">
    <word>
      <element ns="" name="article-title"/>
    </word>
  </constraint>  
  
  <constraint name="abstract">
    <word>
      <element ns="" name="abstract"/>
    </word>
  </constraint>  
  
  <constraint name="aff">
    <word>
      <element ns="" name="aff"/>
    </word>
  </constraint>  
  
  <constraint name="publisher-name">
    <word>
      <element ns="" name="publisher-name"/>
    </word>
  </constraint>  
  
  <constraint name="pub_year">
    <value>
      <element ns="" name="year"/>
    </value>
	  <!--<custom facet="false">
	     <parse apply="year" ns="http://www.nejm.org/custom-field-query" 
	       at="/modules/custom-fields.xqy"/>
	  </custom>-->
  </constraint>
  <constraint name="pub_month">
	<value>
      <element ns="" name="month"/>
    </value>
  </constraint>
  <constraint name="pub_day">
	<value>
      <element ns="" name="day"/>
    </value>
  </constraint>

  <constraint name="manuscriptId">
	  <custom facet="false">
	     <parse apply="manuscriptId" ns="http://www.nejm.org/custom-field-query" at="/modules/custom-fields.xqy"/>
	  </custom>
  </constraint>
  
  <constraint name="images">
    <custom facet="false">
	   <parse apply="images" ns="http://www.nejm.org/custom-field-query" at="/modules/custom-fields.xqy"/>
	</custom>
  </constraint>
  
  <constraint name="audio-visual">
    <custom facet="false">
	   <parse apply="audio-visual" ns="http://www.nejm.org/custom-field-query" at="/modules/custom-fields.xqy"/>
	</custom>
  </constraint>
  
  <operator name="sort">
    <state name="relevance">
      <sort-order>
        <score/>
      </sort-order>
    </state>
    <state name="pub-date">
      <sort-order direction="descending" type="xs:date" collation="http://marklogic.com/collation/">
        <element ns="http://www.massmed.org/elements/" name="publicationDate"/>
      </sort-order>
      <sort-order>
        <score/>
      </sort-order>
    </state>
    <state name="title">
      <sort-order direction="ascending" type="xs:string" collation="http://marklogic.com/collation/">
        <element ns="" name="article-title"/>
      </sort-order>
      <sort-order>
        <score/>
      </sort-order>
    </state>
  </operator>

  <return-query xmlns="http://marklogic.com/appservices/search">false</return-query>
  <return-facets xmlns="http://marklogic.com/appservices/search">true</return-facets>
  <return-metrics xmlns="http://marklogic.com/appservices/search">true</return-metrics>
</options> ;
      
declare function search-lib:get-with-default-int($field as item()*, $default as xs:integer)
as xs:integer {
    if ($field) 
    then xs:integer($field)
    else $default
};

declare function search-lib:my-search($search-query as item()*,
   $start as item()*,
   $page-length as item()*) 
as element(search:response) {
    let $options := <options xmlns="http://marklogic.com/appservices/search">
                           {$OPTIONS/*}
                           <additional-query xmlns="http://marklogic.com/appservices/search"> 
                           { cts:and-query((cts:element-query(fn:QName("","article-meta"), cts:and-query(())))) }
                           </additional-query>
                         </options>
          return search:search($search-query, $options, $start, $page-length)
};