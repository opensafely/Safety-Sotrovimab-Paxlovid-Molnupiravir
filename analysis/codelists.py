
# --- IMPORT STATEMENTS ---

## Import code building blocks from cohort extractor package
from cohortextractor import (codelist, codelist_from_csv, combine_codelists)


# --- CODELISTS ---
#SUS-HES mabs
mabs_procedure_codes = codelist(
  ["X891", "X892"], system="opcs4"
)
# Chronic cardiac disease
chronic_cardiac_dis_codes = codelist_from_csv(
    "codelists/opensafely-chronic-cardiac-disease-snomed.csv",    system="snomed",    column="id"
)
# Chronic respiratory disease
chronic_respiratory_dis_codes = codelist_from_csv(
    "codelists/opensafely-chronic-respiratory-disease-snomed.csv",    system="snomed",    column="id"
)
# Diabetes
diabetes_codes = codelist_from_csv(
    "codelists/opensafely-diabetes-snomed.csv",    system="snomed",    column="id"
)
# Hypertension
hypertension_codes = codelist_from_csv(
    "codelists/opensafely-hypertension-snomed.csv",    system="snomed",    column="id"
)
# Critical care procedure
critical_care_opcs4_codes = codelist_from_csv(
  "codelists/user-viyaasan-critical-care.csv",   system = "opcs4",   column = "code"
)
ventilation_opcs4_codes = codelist_from_csv(
  "codelists/user-viyaasan-mechanical-ventilation.csv",   system = "opcs4",   column = "code"
)

## ELIGIBILITY CRITERIA VARIABLES ----

### Onset of symptoms of COVID-19
covid_symptoms_snomed_codes = codelist_from_csv(
  "codelists/user-MillieGreen-covid-19-symptoms.csv",  system = "snomed",  column = "code",
)

### Require hospitalisation for COVID-19
covid_icd10_codes = codelist_from_csv(
  "codelists/opensafely-covid-identification.csv",  system = "icd10",  column = "icd10_code"
)

### Pregnancy
pregnancy_primis_codes = codelist_from_csv(
  "codelists/primis-covid19-vacc-uptake-preg.csv",  system = "snomed",  column = "code",
)

### Pregnancy or delivery
pregdel_primis_codes = codelist_from_csv(
  "codelists/primis-covid19-vacc-uptake-pregdel.csv",  system = "snomed",  column = "code",
)

### Weight
weight_opensafely_snomed_codes  = codelist_from_csv(
  "codelists/opensafely-weight-snomed.csv",  system = "snomed",  column = "code",
) 


## HIGH RISK GROUPS ----

### Down's syndrome
downs_syndrome_nhsd_snomed_codes = codelist_from_csv(
  "codelists/nhsd-downs-syndrome-snomed-ct.csv",  system = "snomed",  column = "code",
)

downs_syndrome_nhsd_icd10_codes = codelist_from_csv(
  "codelists/nhsd-downs-syndrome-icd-10.csv",  system = "icd10",  column = "code",
)

### Sickle cell disease
sickle_cell_disease_nhsd_snomed_codes = codelist_from_csv(
  "codelists/nhsd-sickle-spl-atriskv4-snomed-ct.csv",  system = "snomed",  column = "code",
)

sickle_cell_disease_nhsd_icd10_codes = codelist_from_csv(
  "codelists/nhsd-sickle-spl-hes-icd-10.csv",  system = "icd10",  column = "code",
)

### Solid cancer
non_haematological_cancer_opensafely_snomed_codes = codelist_from_csv(
  "codelists/opensafely-cancer-excluding-lung-and-haematological-snomed.csv",  system = "snomed",  column = "id",
)
# non_haematological_cancer_opensafely_snomed_codes_new = codelist_from_csv(
#   "codelists/opensafely-cancer-excluding-lung-and-haematological-snomed-new.csv",#   system = "snomed",#   column = "id",
# )

lung_cancer_opensafely_snomed_codes = codelist_from_csv(
  "codelists/opensafely-lung-cancer-snomed.csv",   system = "snomed",   column = "id"
)

chemotherapy_radiotherapy_opensafely_snomed_codes = codelist_from_csv(
  "codelists/opensafely-chemotherapy-or-radiotherapy-snomed.csv",   system = "snomed",   column = "id"
)

### Patients with a haematological diseases
haematopoietic_stem_cell_transplant_nhsd_snomed_codes = codelist_from_csv(
  "codelists/nhsd-haematopoietic-stem-cell-transplant-snomed.csv",   system = "snomed",   column = "code"
)

haematopoietic_stem_cell_transplant_nhsd_icd10_codes = codelist_from_csv(
  "codelists/nhsd-haematopoietic-stem-cell-transplant-icd-10.csv",   system = "icd10",   column = "code"
)

haematopoietic_stem_cell_transplant_nhsd_opcs4_codes = codelist_from_csv(
  "codelists/nhsd-haematopoietic-stem-cell-transplant-opcs4.csv",   system = "opcs4",   column = "code"
)

haematological_malignancies_nhsd_snomed_codes = codelist_from_csv(
  "codelists/nhsd-haematological-malignancies-snomed.csv",  system = "snomed",  column = "code"
)

haematological_malignancies_nhsd_icd10_codes = codelist_from_csv(
  "codelists/nhsd-haematological-malignancies-icd-10.csv",   system = "icd10",   column = "code"
)

### Patients with renal disease

#### CKD stage 5
ckd_stage_5_nhsd_snomed_codes = codelist_from_csv(
  "codelists/nhsd-ckd-stage-5-snomed-ct.csv",   system = "snomed",   column = "code"
)
ckd_stage_5_nhsd_icd10_codes = codelist_from_csv(
  "codelists/nhsd-ckd-stage-5-icd-10.csv",   system = "icd10",   column = "code"
)
dialysis_codes_ctv = codelist_from_csv(
  "codelists/opensafely-dialysis.csv", system = "ctv3", column = "CTV3ID"
)
RRT_codelist_ctv = codelist_from_csv(
    "codelists/opensafely-renal-replacement-therapy.csv", system="ctv3", column="CTV3ID"
)
kidney_transplant_codes_ctv = codelist_from_csv(
  "codelists/opensafely-kidney-transplant.csv", system = "ctv3", column = "CTV3ID"
)
kidney_tx_opcs4_codelist = codelist_from_csv(
  "codelists/user-viyaasan-kidney-transplant-opcs-4.csv",  system="opcs4",  column="code"
)
kidney_tx_icd10_codelist=codelist(["Z940"], system="icd10"
)
##dialysis_icd10_codelist = codelist_from_csv("codelists/ukrr-dialysis.csv", system="icd10", column="code")
##dialysis_opcs4_codelist = codelist_from_csv("codelists/ukrr-dialysis-opcs-4.csv", system="opcs4",column="code")

#### Creatine and eGFR
creatinine_codes_ctv3 = codelist(["XE2q5"], system="ctv3"
)
creatinine_codes_snomed = codelist_from_csv(
  "codelists/user-bangzheng-creatinine-value.csv", system="snomed", column="code"
)
creatinine_codes_short_snomed = codelist_from_csv(
    "codelists/user-bangzheng-creatinine-value-shortlist.csv", system="snomed", column="code"
)
eGFR_level_codelist = codelist_from_csv(
    "codelists/user-ss808-estimated-glomerular-filtration-rate-egfr-values.csv",   system="snomed",  column="code",
)
eGFR_short_level_codelist = codelist_from_csv(
    "codelists/user-bangzheng-egfr-value-shortlist.csv",  system="snomed",  column="code",
)

### Patients with liver disease
liver_disease_nhsd_snomed_codes = codelist_from_csv(
  "codelists/nhsd-liver-cirrhosis.csv",   system = "snomed",   column = "code"
)

liver_disease_nhsd_icd10_codes = codelist_from_csv(
  "codelists/nhsd-liver-cirrhosis-icd-10.csv",   system = "icd10",   column = "code"
)

### Immune-mediated inflammatory disorders (IMID) & Immunosuppression
rheumatoid_arthritis_icd10 = codelist_from_csv(
  "codelists/user-josephignace-inflammatory-arthritis-rheumatoid-arthritis-icd10.csv",  system = "icd10",  column = "code",
)
rheumatoid_arthritis_snowmed = codelist_from_csv(
  "codelists/user-markdrussell-new-rheumatoid-arthritis.csv",  system = "snomed",  column = "code",
)
SLE_icd10 = codelist_from_csv(
  "codelists/user-josephignace-connective-tissue-disorders-systematic-lupus-erythematosus.csv",  system = "icd10",  column = "code",
)
SLE_ctv = codelist_from_csv(
  "codelists/opensafely-systemic-lupus-erythematosus-sle.csv",  system = "ctv3",  column = "CTV3ID",
)
Psoriasis_ctv3 = codelist_from_csv(
  "codelists/opensafely-psoriasis.csv",  system = "ctv3",  column = "code",
)
Psoriatic_arthritis_snomed = codelist_from_csv(
  "codelists/opensafely-psoriatic-arthritis.csv",  system = "snomed",  column = "id",
)
Ankylosing_Spondylitis_ctv3 = codelist_from_csv(
  "codelists/opensafely-ankylosing-spondylitis.csv",  system = "ctv3",  column = "code",
)
IBD_ctv3 = codelist_from_csv(
  "codelists/opensafely-inflammatory-bowel-disease.csv",  system = "ctv3",  column = "CTV3ID",
)
immunosuppresant_drugs_dmd_codes = codelist_from_csv(
  "codelists/nhsd-immunosuppresant-drugs-pra-dmd.csv",   system = "snomed",   column = "code"
)
immunosuppresant_drugs_snomed_codes = codelist_from_csv(
  "codelists/nhsd-immunosuppresant-drugs-pra-snomed.csv",   system = "snomed",   column = "code"
)
oral_steroid_drugs_dmd_codes = codelist_from_csv(
  "codelists/nhsd-oral-steroid-drugs-pra-dmd.csv",  system = "snomed",  column = "dmd_id",
)
oral_steroid_drugs_snomed_codes = codelist_from_csv(
  "codelists/nhsd-oral-steroid-drugs-snomed.csv",   system = "snomed",   column = "code"
)
inj_methotrexate_drugs_snomed_codes = codelist_from_csv(
  "codelists/opensafely-methotrexate-injectable.csv",   system = "snomed",   column = "dmd_id"
)
oral_methotrexate_drugs_snomed_codes = codelist_from_csv(
  "codelists/opensafely-methotrexate-oral.csv",   system = "snomed",   column = "dmd_id"
)
oral_mycophenolate_drugs_snomed_codes = codelist_from_csv(
  "codelists/opensafely-mycophenolate.csv",   system = "snomed",   column = "dmd_id"
)
oral_ciclosporin_snomed_codes = codelist_from_csv(
  "codelists/opensafely-ciclosporin-oral-dmd.csv",   system = "snomed",   column = "dmd_id"
)
abatacept_high_cost_drugs_codes = codelist_from_csv(
  "codelists/opensafely-high-cost-drugs-abatacept.csv",   system = "high_cost_drugs",   column = "olddrugname"
)
adalimumab_high_cost_drugs_codes = codelist_from_csv(
  "codelists/opensafely-high-cost-drugs-adalimumab.csv",   system = "high_cost_drugs",   column = "olddrugname"
)
alemtuzumab_high_cost_drugs_codes = codelist_from_csv(
  "codelists/opensafely-high-cost-drugs-alemtuzumab.csv",   system = "high_cost_drugs",   column = "olddrugname"
)
baricitinib_high_cost_drugs_codes = codelist_from_csv(
  "codelists/opensafely-high-cost-drugs-baricitinib.csv",   system = "high_cost_drugs",   column = "olddrugname"
)
brodalumab_high_cost_drugs_codes = codelist_from_csv(
  "codelists/opensafely-high-cost-drugs-brodalumab.csv",   system = "high_cost_drugs",   column = "olddrugname"
)
certolizumab_high_cost_drugs_codes = codelist_from_csv(
  "codelists/opensafely-high-cost-drugs-certolizumab.csv",   system = "high_cost_drugs",   column = "olddrugname"
)
etanercept_high_cost_drugs_codes = codelist_from_csv(
  "codelists/opensafely-high-cost-drugs-etanercept.csv",   system = "high_cost_drugs",   column = "olddrugname"
)
golimumab_high_cost_drugs_codes = codelist_from_csv(
  "codelists/opensafely-high-cost-drugs-golimumab.csv",   system = "high_cost_drugs",   column = "olddrugname"
)
guselkumab_high_cost_drugs_codes = codelist_from_csv(
  "codelists/opensafely-high-cost-drugs-guselkumab.csv",   system = "high_cost_drugs",   column = "olddrugname"
)
infliximab_high_cost_drugs_codes = codelist_from_csv(
  "codelists/opensafely-high-cost-drugs-infliximab.csv",   system = "high_cost_drugs",   column = "olddrugname"
)
mepolizumab_high_cost_drugs_codes = codelist_from_csv(
  "codelists/opensafely-high-cost-drugs-mepolizumab.csv",   system = "high_cost_drugs",   column = "olddrugname"
)
risankizumab_high_cost_drugs_codes = codelist_from_csv(
  "codelists/opensafely-high-cost-drugs-risankizumab.csv",   system = "high_cost_drugs",   column = "olddrugname"
)

rituximab_high_cost_drugs_codes = codelist_from_csv(
  "codelists/opensafely-high-cost-drugs-rituximab.csv",   system = "high_cost_drugs",   column = "olddrugname"
)
sarilumab_high_cost_drugs_codes = codelist_from_csv(
  "codelists/opensafely-high-cost-drugs-sarilumab.csv",   system = "high_cost_drugs",   column = "olddrugname"
)
secukinumab_high_cost_drugs_codes = codelist_from_csv(
  "codelists/opensafely-high-cost-drugs-secukinumab.csv",   system = "high_cost_drugs",   column = "olddrugname"
)
tildrakizumab_high_cost_drugs_codes = codelist_from_csv(
  "codelists/opensafely-high-cost-drugs-tildrakizumab.csv",   system = "high_cost_drugs",   column = "olddrugname"
)
tocilizumab_high_cost_drugs_codes = codelist_from_csv(
  "codelists/opensafely-high-cost-drugs-tocilizumab.csv",   system = "high_cost_drugs",   column = "olddrugname"
)
tofacitinib_high_cost_drugs_codes = codelist_from_csv(
  "codelists/opensafely-high-cost-drugs-tofacitinib.csv",   system = "high_cost_drugs",   column = "olddrugname"
)
upadacitinib_high_cost_drugs_codes = codelist_from_csv(
  "codelists/opensafely-high-cost-drugs-upadacitinib.csv",   system = "high_cost_drugs",   column = "olddrugname"
)
ustekinumab_high_cost_drugs_codes = codelist_from_csv(
  "codelists/opensafely-high-cost-drugs-ustekinumab.csv",   system = "high_cost_drugs",   column = "olddrugname"
)
vedolizumab_high_cost_drugs_codes = codelist_from_csv(
  "codelists/opensafely-high-cost-drugs-vedolizumab.csv",   system = "high_cost_drugs",   column = "olddrugname"
)


### Primary immune deficiencies
immunosupression_nhsd_codes = codelist_from_csv(
  "codelists/nhsd-immunosupression-pcdcluster-snomed-ct.csv",  system = "snomed",  column = "code",
)
immunosupression_nhsd_codes_new = codelist_from_csv(
  "codelists/user-bangzheng-nhsd-immunosupression-pcdcluster-snomed-ct-new.csv",  system = "snomed",  column = "code",
)

## HIV/AIDs
hiv_aids_nhsd_snomed_codes = codelist_from_csv(
  "codelists/nhsd-hiv-aids-snomed.csv",   system = "snomed",   column = "code"
)

hiv_aids_nhsd_icd10_codes = codelist_from_csv(
  "codelists/nhsd-hiv-aids-icd10.csv",   system = "icd10",   column = "code"
)

## Solid organ transplant
solid_organ_transplant_nhsd_snomed_codes = codelist_from_csv(
  "codelists/nhsd-transplant-spl-atriskv4-snomed-ct.csv",  system = "snomed",  column = "code",
)
solid_organ_transplant_nhsd_snomed_codes_new = codelist_from_csv(
  "codelists/user-bangzheng-nhsd-transplant-spl-atriskv4-snomed-ct-new.csv",  system = "snomed",  column = "code",
)

solid_organ_transplant_nhsd_opcs4_codes = codelist_from_csv(
  "codelists/nhsd-transplant-spl-hes-opcs4.csv",   system = "opcs4",   column = "code"
)

# thymus_gland_transplant_nhsd_opcs4_codes = codelist_from_csv(
#   "codelists/nhsd-transplant-thymus-gland-spl-hes-opcs4.csv", #   system = "opcs4", #   column = "code"
# )

replacement_of_organ_transplant_nhsd_opcs4_codes = codelist_from_csv(
  "codelists/nhsd-transplant-replacement-of-organ-spl-hes-opcs4.csv",   system = "opcs4",   column = "code"
)

# conjunctiva_transplant_nhsd_opcs4_codes = codelist_from_csv(
#   "codelists/nhsd-transplant-conjunctiva-spl-hes-opcs4.csv", #   system = "opcs4", #   column = "code"
# )

conjunctiva_y_codes_transplant_nhsd_opcs4_codes = codelist_from_csv(
  "codelists/nhsd-transplant-conjunctiva-y-codes-spl-hes-opcs4.csv",   system = "opcs4",   column = "code"
)

# stomach_transplant_nhsd_opcs4_codes = codelist_from_csv(
#   "codelists/nhsd-transplant-stomach-spl-hes-opcs4.csv", #   system = "opcs4", #   column = "code"
# )

# ileum_1_transplant_nhsd_opcs4_codes = codelist_from_csv(
#   "codelists/nhsd-transplant-ileum_1-spl-hes-opcs4.csv", #   system = "opcs4", #   column = "code"
# )

# ileum_2_transplant_nhsd_opcs4_codes = codelist_from_csv(
#   "codelists/nhsd-transplant-ileum_2-spl-hes-opcs4.csv", #   system = "opcs4", #   column = "code"
# )

ileum_1_y_codes_transplant_nhsd_opcs4_codes = codelist_from_csv(
  "codelists/nhsd-transplant-ileum_1-y-codes-spl-hes-opcs4.csv",   system = "opcs4",   column = "code"
)

ileum_2_y_codes_transplant_nhsd_opcs4_codes = codelist_from_csv(
  "codelists/nhsd-transplant-ileum_2-y-codes-spl-hes-opcs4.csv",   system = "opcs4",   column = "code"
)

### Rare neurological conditions

#### Multiple sclerosis
multiple_sclerosis_nhsd_snomed_codes = codelist_from_csv(
  "codelists/nhsd-multiple-sclerosis-snomed-ct.csv",  system = "snomed",  column = "code",
)

multiple_sclerosis_nhsd_icd10_codes = codelist_from_csv(
  "codelists/nhsd-multiple-sclerosis.csv",  system = "icd10",  column = "code",
)

#### Motor neurone disease
motor_neurone_disease_nhsd_snomed_codes = codelist_from_csv(
  "codelists/nhsd-motor-neurone-disease-snomed-ct.csv",  system = "snomed",  column = "code",
)

motor_neurone_disease_nhsd_icd10_codes = codelist_from_csv(
  "codelists/nhsd-motor-neurone-disease-icd-10.csv",  system = "icd10",  column = "code",
)

#### Myasthenia gravis
myasthenia_gravis_nhsd_snomed_codes = codelist_from_csv(
  "codelists/nhsd-myasthenia-gravis-snomed-ct.csv",  system = "snomed",  column = "code",
)

myasthenia_gravis_nhsd_icd10_codes = codelist_from_csv(
  "codelists/nhsd-myasthenia-gravis.csv",  system = "icd10",  column = "code",
)

#### Huntington’s disease
huntingtons_disease_nhsd_snomed_codes = codelist_from_csv(
  "codelists/nhsd-huntingtons-snomed-ct.csv",  system = "snomed",  column = "code",
)

huntingtons_disease_nhsd_icd10_codes = codelist_from_csv(
  "codelists/nhsd-huntingtons.csv",  system = "icd10",  column = "code",
)  

## CLINICAL/DEMOGRAPHIC COVARIATES 

### Ethnicity
ethnicity_primis_snomed_codes = codelist_from_csv(
  "codelists/primis-covid19-vacc-uptake-eth2001.csv",  system = "snomed",  column = "code",  category_column="grouping_6_id",
)


# OTHER COVARIATES ----
 
## Autism
autism_nhsd_snomed_codes = codelist_from_csv(
  "codelists/nhsd-primary-care-domain-refsets-autism_cod.csv",  system = "snomed",  column = "code",
)

## Care home 
care_home_primis_snomed_codes = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-longres.csv",     system = "snomed",     column = "code")

## Dementia
dementia_nhsd_snomed_codes = codelist_from_csv(
  "codelists/nhsd-primary-care-domain-refsets-dem_cod.csv",   system = "snomed",   column = "code",
)

## Housebound
housebound_opensafely_snomed_codes = codelist_from_csv(
    "codelists/opensafely-housebound.csv",     system = "snomed",     column = "code"
)

no_longer_housebound_opensafely_snomed_codes = codelist_from_csv(
    "codelists/opensafely-no-longer-housebound.csv",     system = "snomed",     column = "code"
)

## Learning disabilities
wider_ld_primis_snomed_codes = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-learndis.csv",     system = "snomed",     column = "code"
)

## Shielded
high_risk_primis_snomed_codes = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-shield.csv",     system = "snomed",     column = "code")
not_high_risk_primis_snomed_codes = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-nonshield.csv",     system = "snomed",     column = "code") 
## Serious mental illness
serious_mental_illness_nhsd_snomed_codes = codelist_from_csv(
  "codelists/nhsd-primary-care-domain-refsets-mh_cod.csv",  system = "snomed",  column = "code",
)
## Vaccination declined
first_dose_declined = codelist_from_csv(
  "codelists/opensafely-covid-19-vaccination-first-dose-declined.csv",  system = "snomed",  column = "code",
)
second_dose_declined = codelist_from_csv(
  "codelists/opensafely-covid-19-vaccination-second-dose-declined.csv",  system = "snomed",  column = "code",
)
covid_vaccine_declined_codes = combine_codelists(
  first_dose_declined, second_dose_declined
)
# Paxlovid interactions
drugs_do_not_use_codes = codelist_from_csv(
  "codelists/opensafely-sps-paxlovid-interactions-do-not-use.csv",  system = "snomed", column = "code"
)
drugs_consider_risk_codes = codelist_from_csv(
  "codelists/opensafely-nirmatrelvir-drug-interactions.csv",  system = "snomed", column = "code"
)
## Outcomes  ---- Pre-specified adverse drug reactions and AESIs

### Pre-specified adverse drug reactions
diverticulitis_snomed_codes = codelist_from_csv(
  "codelists/user-katiebechman-diverticulitis.csv",  system = "snomed",  column = "code",
)

diverticulitis_icd_codes = codelist_from_csv(
  "codelists/user-katiebechman-diverticulitis_icd10.csv",  system = "icd10",  column = "code",
)

diarrhoea_snomed_codes = codelist_from_csv(
  "codelists/opensafely-symptoms-diarrhoea.csv",  system = "snomed",  column = "code",
)

taste_snomed_codes = codelist_from_csv(
  "codelists/user-katiebechman-abnormal-taste.csv",  system = "snomed",  column = "code",
)

taste_icd_codes = codelist_from_csv( 
  "codelists/user-katiebechman-abnormal-taste-icd10.csv", system = "icd10",  column = "code",
)
anaphylaxis_snomed_codes = codelist_from_csv( 
  "codelists/user-katiebechman-anaphylaxis-snomed.csv", system = "snomed",  column = "code",
)
anaphylaxis_icd_codes = codelist_from_csv( 
  "codelists/user-katiebechman-anaphylaxis.csv", system = "icd10",  column = "code",
) 