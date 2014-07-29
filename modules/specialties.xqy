xquery version "1.0-ml";

module namespace specialties = "http://www.nejm.org/specialties";

declare variable $SPEC-TABLE  := specialties:get-specialties();

declare function specialties:id-to-str($id as xs:string) as xs:string {
    fn:string($SPEC-TABLE/specialty[@id eq $id]/@spec)
};

declare function specialties:get-specialties() as element(specialties)
{ <specialties>
    <specialty id="1_1" spec="Neurology/Neurosurgery General"/>
    <specialty id="1_2" spec="Stroke"/>
    <specialty id="1_3" spec="Multiple Sclerosis"/>
    <specialty id="1_4" spec="Dementia/Alzheimer Disease"/>
    <specialty id="1_5" spec="Pain"/>
    <specialty id="1_6" spec="Neuromuscular Disease"/>
    <specialty id="1_7" spec="Coma/Brain Death"/>
    <specialty id="1_8" spec="Head Trauma"/>
    <specialty id="1_9" spec="Parkinson Disease"/>
    <specialty id="1_10" spec="Seizures"/>
    <specialty id="1_11" spec="Brain Tumor"/>
    <specialty id="2_1" spec="Hematology/Oncology General"/>
    <specialty id="2_2" spec="Colorectal Cancer"/>
    <specialty id="2_3" spec="Coagulation"/>
    <specialty id="2_4" spec="Leukemia/Lymphoma"/>
    <specialty id="2_5" spec="Childhood Cancer"/>
    <specialty id="2_6" spec="Lung Cancer"/>
    <specialty id="2_7" spec="Treatments in Oncology"/>
    <specialty id="2_8" spec="Breast Cancer"/>
    <specialty id="2_9" spec="Palliative Care"/>
    <specialty id="2_10" spec="Bone Marrow Transplantation"/>
    <specialty id="2_11" spec="Gynecologic Oncology"/>
    <specialty id="3_1" spec="Surgery General"/>
    <specialty id="3_2" spec="Cardiovascular Surgery"/>
    <specialty id="4_1" spec="Pediatrics General"/>
    <specialty id="4_2" spec="Neonatology"/>
    <specialty id="4_3" spec="Childhood Diseases"/>
    <specialty id="4_4" spec="Adolescent Medicine"/>
    <specialty id="4_5" spec="Family Systems and Communication"/>
    <specialty id="4_6" spec="Immunization"/>
    <specialty id="4_7" spec="Growth and Development"/>
    <specialty id="5_1" spec="Dermatology General"/>
    <specialty id="5_2" spec="Psoriasis"/>
    <specialty id="5_3" spec="Drug-related Skin Conditions"/>
    <specialty id="5_4" spec="Skin Cancer"/>
    <specialty id="6_1" spec="Endocrinology General"/>
    <specialty id="6_2" spec="Diet/Nutrition"/>
    <specialty id="6_3" spec="Adrenal Disease"/>
    <specialty id="6_4" spec="Diabetes"/>
    <specialty id="6_5" spec="Obesity"/>
    <specialty id="6_6" spec="Hypothalamic-Pituitary Disease"/>
    <specialty id="6_7" spec="Osteoporosis/Bone Disease"/>
    <specialty id="6_8" spec="Thyroid Disease"/>
    <specialty id="7_1" spec="Psychiatry General"/>
    <specialty id="7_2" spec="Post-traumatic Stress Disorder"/>
    <specialty id="7_3" spec="Sexuality"/>
    <specialty id="7_4" spec="Depression"/>
    <specialty id="7_5" spec="Schizophrenia"/>
    <specialty id="7_6" spec="Addiction"/>
    <specialty id="8_1" spec="Nephrology General"/>
    <specialty id="8_2" spec="Kidney Transplantation"/>
    <specialty id="8_3" spec="UTI/Pyelonephritis"/>
    <specialty id="8_4" spec="Chronic Kidney Disease"/>
    <specialty id="8_5" spec="Renal Replacement Therapy"/>
    <specialty id="8_6" spec="Hypertension"/>
    <specialty id="8_7" spec="Congenital Kidney Disease"/>
    <specialty id="8_8" spec="Glomerular Disease"/>
    <specialty id="8_9" spec="Cystic Kidney Disease"/>
    <specialty id="9_1" spec="Rheumatology General"/>
    <specialty id="9_2" spec="Vasculitis"/>
    <specialty id="9_3" spec="Osteoarthritis"/>
    <specialty id="9_4" spec="Bone Disease"/>
    <specialty id="9_5" spec="Infection-related Disease"/>
    <specialty id="9_6" spec="Rheumatoid Arthritis"/>
    <specialty id="10_1" spec="Emergency Medicine General"/>
    <specialty id="10_2" spec="Seizures"/>
    <specialty id="10_3" spec="Acute Coronary Syndromes"/>
    <specialty id="10_4" spec="Stroke"/>
    <specialty id="10_5" spec="Toxicology"/>
    <specialty id="10_6" spec="Shock"/>
    <specialty id="10_7" spec="Trauma"/>
    <specialty id="11_1" spec="Gastroenterology General"/>
    <specialty id="11_2" spec="Inflammatory Bowel Disease"/>
    <specialty id="11_3" spec="Colorectal Cancer"/>
    <specialty id="11_4" spec="Liver Disease"/>
    <specialty id="11_5" spec="Diet/Nutrition"/>
    <specialty id="12_1" spec="Pulmonary General"/>
    <specialty id="12_2" spec="Pulmonary Fibrosis"/>
    <specialty id="12_3" spec="Asthma"/>
    <specialty id="12_4" spec="COPD"/>
    <specialty id="12_5" spec="Anticoagulation/Thromboembolism"/>
    <specialty id="12_6" spec="Critical Care"/>
    <specialty id="13_1" spec="Genetics General"/>
    <specialty id="13_2" spec="Stem cells"/>
    <specialty id="13_3" spec="Cancer"/>
    <specialty id="13_4" spec="Reproductive Medicine"/>
    <specialty id="13_5" spec="Ethical and Legal Issues"/>
    <specialty id="13_6" spec="Neuroscience"/>
    <specialty id="13_7" spec="Immunity"/>
    <specialty id="13_8" spec="Endocrinology"/>
    <specialty id="14_1" spec="Cardiology General"/>
    <specialty id="14_2" spec="Prevention"/>
    <specialty id="14_3" spec="Hypertension"/>
    <specialty id="14_4" spec="Coronary Disease/Myocardial Infarction"/>
    <specialty id="14_5" spec="Anticoagulation/Thromboembolism"/>
    <specialty id="14_6" spec="Cardiomyopathy/Myocarditis"/>
    <specialty id="14_7" spec="Lipids"/>
    <specialty id="14_8" spec="Arrhythmias/Pacemakers"/>
    <specialty id="14_9" spec="Heart Failure"/>
    <specialty id="15_1" spec="Geriatrics/Aging General"/>
    <specialty id="15_2" spec="End-of-Life Care"/>
    <specialty id="15_3" spec="Osteoporosis"/>
    <specialty id="15_4" spec="Dementia/Alzheimer Disease"/>
    <specialty id="15_5" spec="Rehabilitation"/>
    <specialty id="16_1" spec="Obstetrics/Gynecology General"/>
    <specialty id="16_2" spec="Complications of Pregnancy"/>
    <specialty id="16_3" spec="Gynecologic Oncology"/>
    <specialty id="16_4" spec="Birth Defects"/>
    <specialty id="17_1" spec="Public Health, Policy, and Training General"/>
    <specialty id="17_2" spec="Global Health"/>
    <specialty id="17_3" spec="Legal Issues in Medicine"/>
    <specialty id="17_4" spec="Health Care Delivery"/>
    <specialty id="17_5" spec="Statistics"/>
    <specialty id="17_6" spec="Medical Education, Training, and Primary Care"/>
    <specialty id="17_7" spec="Health Policy/Health Economics"/>
    <specialty id="17_8" spec="Medical Ethics"/>
    <specialty id="18_1" spec="Infectious Disease General"/>
    <specialty id="18_2" spec="Vaccines"/>
    <specialty id="18_3" spec="HIV/AIDS"/>
    <specialty id="18_4" spec="Parasitic Infections"/>
    <specialty id="18_5" spec="Bacterial Infections"/>
    <specialty id="18_6" spec="Viral Infections"/>
    <specialty id="18_7" spec="Tuberculosis"/>
    <specialty id="18_8" spec="Fungal Infections"/>
    <specialty id="18_9" spec="Global Health"/>
    <specialty id="18_10" spec="Diagnostics"/>
    <specialty id="18_11" spec="Influenza"/>
    <specialty id="19_1" spec="Allergy/Immunology General"/>
    <specialty id="19_4" spec="Allergy"/>
    <specialty id="19_2" spec="Asthma"/>
    <specialty id="19_3" spec="Autoimmune Disease"/>
    <specialty id="20_1" spec="Ophthalmology General"/>
    <specialty id="21_1" spec="Otolaryngology General"/>
    <specialty id="22_1" spec="Orthopedics General"/>
    <specialty id="23_1" spec="Urology/Prostate Disease General"/>
    <specialty id="24_1" spec="Reform Implementation"/>
    <specialty id="24_2" spec="Cost of Health Care"/>
    <specialty id="24_3" spec="Medicare and Medicaid"/>
    <specialty id="24_4" spec="Insurance Coverage"/>
    <specialty id="24_5" spec="Health Care Delivery"/>
    <specialty id="24_6" spec="Accountable Care Organizations"/>
    <specialty id="24_7" spec="Politics of Health Care Reform"/>
    <specialty id="24_8" spec="Health IT"/>
    <specialty id="24_9" spec="Drugs"/>
    <specialty id="24_10" spec="Comparative Effectiveness"/>
    <specialty id="24_11" spec="International Health Policy"/>
    <specialty id="24_12" spec="Health Law"/>
    <specialty id="24_13" spec="Public Health"/>
    <specialty id="24_14" spec="Quality of Care"/>
    <specialty id="25_1" spec="Medical Statistics"/>
    <specialty id="26_1" spec="Training"/>
    <specialty id="27_1" spec="Medical Ethics"/>
    <specialty id="28_1" spec="Primary Care/Hospitalist;"/>
</specialties> };