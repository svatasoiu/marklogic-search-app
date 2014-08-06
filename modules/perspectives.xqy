xquery version "1.0-ml";

module namespace perspectives = "http://www.nejm.org/perspectives";

declare variable $PERSP-TOPIC-TABLE  := perspectives:get-perspective-topics();

declare function perspectives:id-to-str($id as xs:string) as xs:string {
    fn:string($PERSP-TOPIC-TABLE/perspective[@id eq $id]/@name)
};

declare function perspectives:str-to-id($str as xs:string) as xs:string {
    fn:string(($PERSP-TOPIC-TABLE/perspective[@name eq $str]/@id)[1])
};

declare function perspectives:get-perspective-topics() as element(perspectives)
{ <perspectives>
    <perspective id="1" name="Drug and Device Safety"/>
    <perspective id="2" name="Essays"/>
    <perspective id="3" name="Focus on Research"/>
    <perspective id="4" name="Global Health"/>
    <perspective id="5" name="Health Policy"/>
    <perspective id="6" name="Medical Education"/>
    <perspective id="7" name="Medical Ethics and Human rights"/>
    <perspective id="8" name="Medical Practice"/>
    <perspective id="9" name="Medicine and Business"/>
    <perspective id="10" name="Medicine and Business"/>
    <perspective id="11" name="Public Health"/>
   </perspectives> };