xquery version "1.0-ml";

module namespace topics = "http://www.nejm.org/topics";

declare function topics:get-topics() as element(topics)
{ <topics>
    <topic id="1" name="Neurology/Neurosurgery"/>
    <topic id="2" name="Hematology/Oncology"/>
    <topic id="3" name="Surgery"/>
    <topic id="4" name="Pediatrics"/>
    <topic id="5" name="Dermatology"/>
    <topic id="6" name="Endocrinology"/>
    <topic id="7" name="Psychiatry"/>
    <topic id="8" name="Nephrology"/>
    <topic id="9" name="Rheumatology"/>
    <topic id="10" name="Emergency Medicine"/>
    <topic id="11" name="Gastroenterology"/>
    <topic id="12" name="Pulmonary/Critical Care"/>
    <topic id="13" name="Genetics"/>
    <topic id="14" name="Cardiology"/>
    <topic id="15" name="Geriatrics/Aging"/>
    <topic id="16" name="Obstetrics/Gynecology"/>
    <topic id="17" name="Public Health, Policy, and Training"/>
    <topic id="18" name="Infectious Disease"/>
    <topic id="19" name="Allergy/Immunology"/>
    <topic id="20" name="Ophthalmology"/>
    <topic id="21" name="Otolaryngology"/>
    <topic id="22" name="Orthopedics"/>
    <topic id="23" name="Urology/Prostate Disease"/>
    <topic id="24" name="Health Policy and Reform"/>
    <topic id="25" name="Medical Statistics"/>
    <topic id="26" name="Medical Practice, Training, and Education"/>
    <topic id="27" name="Medical Ethics"/>
    <topic id="28" name="Primary Care/Hospitalist"/>
</topics> };