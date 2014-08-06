xquery version "1.0-ml";

module namespace topics = "http://www.nejm.org/topics";

declare variable $TOPIC-TABLE := topics:get-topics();

declare function topics:id-to-str($id as xs:string) as xs:string {
    fn:string($TOPIC-TABLE/topic[@id eq $id]/@top)
};

declare function topics:str-to-id($str as xs:string) as xs:string {
    fn:string(($TOPIC-TABLE/topic[@top eq $str]/@id)[1])
};

declare function topics:get-topics() as element(topics)
{ <topics>
    <topic id="1" top="Neurology/Neurosurgery"/>
    <topic id="2" top="Hematology/Oncology"/>
    <topic id="3" top="Surgery"/>
    <topic id="4" top="Pediatrics"/>
    <topic id="5" top="Dermatology"/>
    <topic id="6" top="Endocrinology"/>
    <topic id="7" top="Psychiatry"/>
    <topic id="8" top="Nephrology"/>
    <topic id="9" top="Rheumatology"/>
    <topic id="10" top="Emergency Medicine"/>
    <topic id="11" top="Gastroenterology"/>
    <topic id="12" top="Pulmonary/Critical Care"/>
    <topic id="13" top="Genetics"/>
    <topic id="14" top="Cardiology"/>
    <topic id="15" top="Geriatrics/Aging"/>
    <topic id="16" top="Obstetrics/Gynecology"/>
    <topic id="17" top="Public Health, Policy, and Training"/>
    <topic id="18" top="Infectious Disease"/>
    <topic id="19" top="Allergy/Immunology"/>
    <topic id="20" top="Ophthalmology"/>
    <topic id="21" top="Otolaryngology"/>
    <topic id="22" top="Orthopedics"/>
    <topic id="23" top="Urology/Prostate Disease"/>
    <topic id="24" top="Health Policy and Reform"/>
    <topic id="25" top="Medical Statistics"/>
    <topic id="26" top="Medical Practice, Training, and Education"/>
    <topic id="27" top="Medical Ethics"/>
    <topic id="28" top="Primary Care/Hospitalist"/>
</topics> };