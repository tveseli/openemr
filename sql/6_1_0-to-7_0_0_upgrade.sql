--
--  Comment Meta Language Constructs:
--
--  #IfNotTable
--    argument: table_name
--    behavior: if the table_name does not exist,  the block will be executed

--  #IfTable
--    argument: table_name
--    behavior: if the table_name does exist, the block will be executed

--  #IfColumn
--    arguments: table_name colname
--    behavior:  if the table and column exist,  the block will be executed

--  #IfMissingColumn
--    arguments: table_name colname
--    behavior:  if the table exists but the column does not,  the block will be executed

--  #IfNotColumnType
--    arguments: table_name colname value
--    behavior:  If the table table_name does not have a column colname with a data type equal to value, then the block will be executed

--  #IfNotColumnTypeDefault
--    arguments: table_name colname value value2
--    behavior:  If the table table_name does not have a column colname with a data type equal to value and a default equal to value2, then the block will be executed

--  #IfNotRow
--    arguments: table_name colname value
--    behavior:  If the table table_name does not have a row where colname = value, the block will be executed.

--  #IfNotRow2D
--    arguments: table_name colname value colname2 value2
--    behavior:  If the table table_name does not have a row where colname = value AND colname2 = value2, the block will be executed.

--  #IfNotRow3D
--    arguments: table_name colname value colname2 value2 colname3 value3
--    behavior:  If the table table_name does not have a row where colname = value AND colname2 = value2 AND colname3 = value3, the block will be executed.

--  #IfNotRow4D
--    arguments: table_name colname value colname2 value2 colname3 value3 colname4 value4
--    behavior:  If the table table_name does not have a row where colname = value AND colname2 = value2 AND colname3 = value3 AND colname4 = value4, the block will be executed.

--  #IfNotRow2Dx2
--    desc:      This is a very specialized function to allow adding items to the list_options table to avoid both redundant option_id and title in each element.
--    arguments: table_name colname value colname2 value2 colname3 value3
--    behavior:  The block will be executed if both statements below are true:
--               1) The table table_name does not have a row where colname = value AND colname2 = value2.
--               2) The table table_name does not have a row where colname = value AND colname3 = value3.

--  #IfRow
--    arguments: table_name colname value
--    behavior:  If the table table_name does have a row where colname = value, the block will be executed.

--  #IfRow2D
--    arguments: table_name colname value colname2 value2
--    behavior:  If the table table_name does have a row where colname = value AND colname2 = value2, the block will be executed.

--  #IfRow3D
--        arguments: table_name colname value colname2 value2 colname3 value3
--        behavior:  If the table table_name does have a row where colname = value AND colname2 = value2 AND colname3 = value3, the block will be executed.

--  #IfRowIsNull
--    arguments: table_name colname
--    behavior:  If the table table_name does have a row where colname is null, the block will be executed.

--  #IfIndex
--    desc:      This function is most often used for dropping of indexes/keys.
--    arguments: table_name colname
--    behavior:  If the table and index exist the relevant statements are executed, otherwise not.

--  #IfNotIndex
--    desc:      This function will allow adding of indexes/keys.
--    arguments: table_name colname
--    behavior:  If the index does not exist, it will be created

--  #EndIf
--    all blocks are terminated with a #EndIf statement.

--  #IfNotListReaction
--    Custom function for creating Reaction List

--  #IfNotListOccupation
--    Custom function for creating Occupation List

--  #IfTextNullFixNeeded
--    desc: convert all text fields without default null to have default null.
--    arguments: none

--  #IfTableEngine
--    desc:      Execute SQL if the table has been created with given engine specified.
--    arguments: table_name engine
--    behavior:  Use when engine conversion requires more than one ALTER TABLE

--  #IfInnoDBMigrationNeeded
--    desc: find all MyISAM tables and convert them to InnoDB.
--    arguments: none
--    behavior: can take a long time.

--  #IfDocumentNamingNeeded
--    desc: populate name field with document names.
--    arguments: none

--  #IfUpdateEditOptionsNeeded
--    desc: Change Layout edit options.
--    arguments: mode(add or remove) layout_form_id the_edit_option comma_separated_list_of_field_ids

#IfNotRow2D layout_options form_id DEM field_id prevent_portal_apps
SET @group_id = (SELECT `group_id` FROM layout_options WHERE field_id='allow_patient_portal' AND form_id='DEM');
SET @seq_start := 0;
UPDATE `layout_options` SET `seq` = (@seq_start := @seq_start+1)*10 WHERE group_id = @group_id AND form_id='DEM' ORDER BY `seq`;
SET @seq_add_to = (SELECT seq FROM layout_options WHERE group_id = @group_id AND field_id='allow_patient_portal' AND form_id='DEM');
INSERT INTO `layout_options` (`form_id`, `field_id`, `group_id`, `title`, `seq`, `data_type`, `uor`, `fld_length`, `max_length`, `list_id`, `titlecols`, `datacols`, `default_value`, `edit_options`, `description`, `fld_rows`) VALUES ('DEM','prevent_portal_apps',@group_id,'Prevent API Access',@seq_add_to+5,21,1,0,0,'',1,1,'','','Check to not allow third party API access.',0);
ALTER TABLE `patient_data` ADD `prevent_portal_apps` TEXT;
#Endif

#IfMissingColumn clinical_rules bibliographic_citation
ALTER TABLE `clinical_rules` ADD COLUMN `bibliographic_citation` VARCHAR(255) NOT NULL DEFAULT '';
#EndIf

#IfMissingColumn clinical_rules linked_referential_cds
ALTER TABLE `clinical_rules` ADD COLUMN `linked_referential_cds` VARCHAR(50) NOT NULL DEFAULT '';
#EndIf

#IfMissingColumn clinical_rules amc_2015_flag
ALTER TABLE `clinical_rules` ADD `amc_2015_flag` TINYINT(1) NULL DEFAULT NULL
    COMMENT '2015 Automated Measure Calculation flag for (unable to customize per patient)';
#EndIf

#IfMissingColumn clinical_rules amc_code_2015
ALTER TABLE `clinical_rules` ADD `amc_code_2015` VARCHAR(30) NOT NULL DEFAULT '' COMMENT 'Automated Measure Calculation 2014 identifier (MU rule)';
#EndIf

#IfMissingColumn patient_access_onsite date_created
-- We add the date time so we know exactly when the credentials were generated without having to lookup in the audit log
ALTER TABLE patient_access_onsite ADD `date_created` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP;
#EndIf

#IfNotRow clinical_rules id patient_access_amc
INSERT INTO `clinical_rules` (`id`, `pid`, `active_alert_flag`, `passive_alert_flag`, `cqm_flag`, `cqm_2011_flag`,
                              `cqm_2014_flag`, `cqm_nqf_code`, `cqm_pqri_code`, `amc_flag`, `amc_2011_flag`,
                              `amc_2014_flag`, `amc_code`, `amc_code_2014`, `amc_code_2015`, `amc_2014_stage1_flag`,
                              `amc_2014_stage2_flag`, `amc_2015_flag`, `patient_reminder_flag`, `developer`,
                              `funding_source`, `release_version`, `web_reference`, `access_control`,
                              `bibliographic_citation`, `linked_referential_cds`)
    VALUES ('patient_access_amc', '0', '0', '0', '0', '0', '0', '', '', '1', '0', '0', '', ''
    , '170.315(g)(1)/(2)–2c', '0', '0', '1', '0', '', '', '', '', 'patients:med', '', '');
#EndIf

#IfNotRow2D list_options list_id clinical_rules option_id patient_access_amc
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `is_default`, `option_value`, `mapping`, `notes`
                            , `codes`, `toggle_setting_1`, `toggle_setting_2`)
    VALUES ('clinical_rules', 'patient_access_amc', 'Provide Patients Electronic Access to Their Health Information - API Access'
    , 240, 0, 0, '', '', '', 0, 0);
#EndIf

#IfRow2D list_options list_id lists option_id ecqm_2021_reporting
DELETE FROM list_options WHERE list_id = "ecqm_2021_reporting";
DELETE FROM list_options WHERE list_id = 'lists' AND option_id = "ecqm_2021_reporting";
#EndIf

#IfNotRow2D list_options list_id lists option_id ecqm_2022_reporting
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `is_default`, `option_value`) VALUES ('lists','ecqm_2022_reporting','eCQM 2022 Performance Period',0,1,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS117v10','Childhood Immunization Status',10,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS122v10','Diabetes: Hemoglobin A1c (HbA1c) Poor Control (>9%)',20,1);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS124v10','Cervical Cancer Screening',30,1);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS125v10','Breast Cancer Screening',40,1);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS127v10','Pneumococcal Vaccination Status for Older Adults',50,1);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS128v10','Anti-Depressant Medication Management',60,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS129v11','Prostate Cancer: Avoidance of Overuse of Bone Scan for Staging Low Risk Prostate Cancer Patients',70,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS130v10','Colorectal Cancer Screening',80,1);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS131v10','Diabetes: Eye Exam',90,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS133v10','Cataracts: 20/40 or Better Visual Acuity within 90 Days Following Cataract Surgery',95,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS134v10','Diabetes: Medical Attention for Nephropathy',100,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS135v10','Heart Failure (HF): Angiotensin-Converting Enzyme (ACE) Inhibitor or Angiotensin Receptor Blocker (ARB) or Angiotensin Receptor-Neprilysin Inhibitor (ARNI) Therapy for Left Ventricular Systolic Dysfunction (LVSD)',110,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS136v11','Follow-Up Care for Children Prescribed ADHD Medication (ADD)',120,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS137v10','Initiation and Engagement of Alcohol and Other Drug Dependence Treatment',130,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS138v10','Preventive Care and Screening: Tobacco Use: Screening and Cessation Intervention',140,1);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS139v10','Falls: Screening for Future Fall Risk',150,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS142v10','Diabetic Retinopathy: Communication with the Physician Managing Ongoing Diabetes Care',160,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS143v10','Primary Open-Angle Glaucoma (POAG): Optic Nerve Evaluation',170,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS144v10','Heart Failure (HF): Beta-Blocker Therapy for Left Ventricular Systolic Dysfunction (LVSD)',180,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS145v10','Coronary Artery Disease (CAD): Beta-Blocker Therapy – Prior Myocardial Infarction (MI) or Left Ventricular Systolic Dysfunction (LVEF < 40%)',190,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS146v10','Appropriate Testing for Pharyngitis',200,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS147v11','Preventive Care and Screening: Influenza Immunization',210,1);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS149v10','Dementia: Cognitive Assessment',220,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS153v10','Chlamydia Screening for Women',230,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS154v10','Appropriate Treatment for Upper Respiratory Infection (URI)',240,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS155v10','Weight Assessment and Counseling for Nutrition and Physical `activity` for Children and Adolescents',250,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS156v10','Use of High-Risk Medications in Older Adults',260,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS157v10','Oncology: Medical and Radiation – Pain Intensity Quantified',280,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS159v10','Depression Remission at Twelve Months',290,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS161v10','Adult Major Depressive Disorder (MDD): Suicide Risk Assessment',300,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS165v10','Controlling High Blood Pressure',310,1);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS177v10','Child and Adolescent Major Depressive Disorder (MDD): Suicide Risk Assessment',320,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS22v10','Preventive Care and Screening: Screening for High Blood Pressure and Follow-Up Documented',330,1);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS249v4','Appropriate Use of DXA Scans in Women Under 65 Years Who Do Not Meet the Risk Factor Profile for Osteoporotic Fracture',340,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS2v11','Preventive Care and Screening: Screening for Depression and Follow-Up Plan',350,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS347v5','Statin Therapy for the Prevention and Treatment of Cardiovascular Disease',360,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS349v4','HIV Screening',370,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS50v10','Closing the Referral Loop: Receipt of Specialist Report',380,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS56v10','Functional Status Assessment for Total Hip Replacement',390,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS645v5','Bone Density Evaluation for Patients with Prostate Cancer and Receiving Androgen Deprivation Therapy',400,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS646v2','Intravesical Bacillus-Calmette-Guerin for non-muscle invasive bladder cancer',405,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS66v10','Functional Status Assessment for Total Knee Replacement',410,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS68v11','Documentation of Current Medications in the Medical Record',420,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS69v10','Preventive Care and Screening: Body Mass Index (BMI) Screening and Follow-Up Plan',430,1);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS74v11','Primary Caries Prevention Intervention as Offered by Primary Care Providers, including Dentists',440,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS75v10','Children Who Have Dental Decay or Cavities',450,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS771v3','Urinary Symptom Score Change 6-12 Months After Diagnosis of Benign Prostatic Hyperplasia',460,0);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`) VALUES ('ecqm_2022_reporting','CMS90v11','Functional Status Assessments for Congestive Heart Failure',470,0);
#EndIf

#IfNotRow2D list_options list_id discharge-disposition option_id home-hospice
DELETE FROM list_options WHERE list_id = "discharge-disposition";
DELETE FROM list_options WHERE list_id = 'lists' AND option_id = "discharge-disposition";

INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `is_default`, `option_value`, `mapping`, `notes`, `codes`, `toggle_setting_1`, `toggle_setting_2`, `activity`) VALUES ('lists','discharge-disposition','Discharge Disposition',0,1,0,'',NULL,'',0,0,1);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `is_default`, `option_value`, `mapping`, `notes`, `codes`, `toggle_setting_1`, `toggle_setting_2`, `activity`) VALUES ('discharge-disposition','home','Home',10,1,0,'','','SNOMED-CT:10161009',0,0,1);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `is_default`, `option_value`, `mapping`, `notes`, `codes`, `toggle_setting_1`, `toggle_setting_2`, `activity`) VALUES ('discharge-disposition','home-hospice','Discharge to home for hospice care',20,0,0,'','','SNOMED-CT:428361000124107',0,0,1);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `is_default`, `option_value`, `mapping`, `notes`, `codes`, `toggle_setting_1`, `toggle_setting_2`, `activity`) VALUES ('discharge-disposition','alt-home','Alternative Home',30,0,0,'','','',0,0,1);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `is_default`, `option_value`, `mapping`, `notes`, `codes`, `toggle_setting_1`, `toggle_setting_2`, `activity`) VALUES ('discharge-disposition','other-hcf','Other healthcare facility',40,0,0,'','','',0,0,1);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `is_default`, `option_value`, `mapping`, `notes`, `codes`, `toggle_setting_1`, `toggle_setting_2`, `activity`) VALUES ('discharge-disposition','hosp','Hospice',50,0,0,'','','SNOMED-CT:428371000124100',0,0,1);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `is_default`, `option_value`, `mapping`, `notes`, `codes`, `toggle_setting_1`, `toggle_setting_2`, `activity`) VALUES ('discharge-disposition','long','Long-term care',60,0,0,'','','',0,0,1);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `is_default`, `option_value`, `mapping`, `notes`, `codes`, `toggle_setting_1`, `toggle_setting_2`, `activity`) VALUES ('discharge-disposition','aadvice','Left against advice (Finding)',70,0,0,'','','SNOMED-CT:445060000',0,0,1);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `is_default`, `option_value`, `mapping`, `notes`, `codes`, `toggle_setting_1`, `toggle_setting_2`, `activity`) VALUES ('discharge-disposition','self-aadvice','Patient self-discharge against medical advice',80,0,0,'','','SNOMED-CT:225928004',0,0,1);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `is_default`, `option_value`, `mapping`, `notes`, `codes`, `toggle_setting_1`, `toggle_setting_2`, `activity`) VALUES ('discharge-disposition','exp','Expired',90,0,0,'','','SNOMED-CT:371828006',0,0,1);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `is_default`, `option_value`, `mapping`, `notes`, `codes`, `toggle_setting_1`, `toggle_setting_2`, `activity`) VALUES ('discharge-disposition','psy','Psychiatric hospital',100,0,0,'','','',0,0,1);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `is_default`, `option_value`, `mapping`, `notes`, `codes`, `toggle_setting_1`, `toggle_setting_2`, `activity`) VALUES ('discharge-disposition','rehab','Rehabilitation',110,0,0,'','','SNOMED-CT:433591000124103',0,0,1);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `is_default`, `option_value`, `mapping`, `notes`, `codes`, `toggle_setting_1`, `toggle_setting_2`, `activity`) VALUES ('discharge-disposition','snf','Skilled nursing facility',120,0,0,'','','',0,0,1);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `is_default`, `option_value`, `mapping`, `notes`, `codes`, `toggle_setting_1`, `toggle_setting_2`, `activity`) VALUES ('discharge-disposition','comm-hospital','Discharge to community hospital',130,0,0,'','','SNOMED-CT:306701001',0,0,1);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `is_default`, `option_value`, `mapping`, `notes`, `codes`, `toggle_setting_1`, `toggle_setting_2`, `activity`) VALUES ('discharge-disposition','oth','Other',140,0,0,'','','',0,0,1);
#EndIf

#IfNotRow2D list_options list_id clinical_rules option_id send_sum_2015_amc
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `is_default`, `option_value`, `mapping`, `notes`
                           , `codes`, `toggle_setting_1`, `toggle_setting_2`)
VALUES ('clinical_rules', 'send_sum_2015_amc', 'Support Electronic Referral Loops by Sending Health Information'
       , 240, 0, 0, '', '', '', 0, 0);
#EndIf

#IfNotRow clinical_rules id send_sum_2015_amc
INSERT INTO `clinical_rules` (`id`, `pid`, `active_alert_flag`, `passive_alert_flag`, `cqm_flag`, `cqm_2011_flag`,
                              `cqm_2014_flag`, `cqm_nqf_code`, `cqm_pqri_code`, `amc_flag`, `amc_2011_flag`,
                              `amc_2014_flag`, `amc_code`, `amc_code_2014`, `amc_code_2015`, `amc_2014_stage1_flag`,
                              `amc_2014_stage2_flag`, `amc_2015_flag`, `patient_reminder_flag`, `developer`,
                              `funding_source`, `release_version`, `web_reference`, `access_control`,
                              `bibliographic_citation`, `linked_referential_cds`)
VALUES ('send_sum_2015_amc', '0', '0', '0', '0', '0', '0', '', '', '1', '0', '0', '', ''
       , '170.315(g)(1)/(2)–7', '0', '0', '1', '0', '', '', '', '', '', '', '');
#EndIf

#IfNotRow2D layout_options form_id LBTref field_id billing_facility_id
DELETE FROM `layout_options` WHERE `form_id`='LBTref' AND `field_id`='encounter_id' AND `data_type`=53 and `seq`=10;
INSERT INTO `layout_options` (`form_id`,`field_id`,`group_id`,`title`,`seq`,`data_type`,`uor`,`fld_length`,`max_length`
                             ,`list_id`,`titlecols`,`datacols`,`default_value`,`edit_options`,`description`,`fld_rows`)
VALUES ('LBTref', 'billing_facility_id', '1', 'Patient Billing Facility', 11, 35, 1, 0, 0, '', 1, 1, '', ''
       ,'Billing facility that patient claims are billed against', 0);
#EndIf


#IfMissingColumn report_itemized rule_id
ALTER TABLE `report_itemized` ADD COLUMN `rule_id` VARCHAR(31) DEFAULT NULL;
#EndIf

#IfMissingColumn report_itemized item_details
ALTER TABLE `report_itemized` ADD COLUMN `item_details` TEXT;
#EndIf

#IfMissingColumn ccda transaction_id
ALTER TABLE `ccda` ADD COLUMN `transaction_id` BIGINT(20) COMMENT 'fk to transactions referral record';
#EndIf

#IfMissingColumn form_care_plan date_end
ALTER TABLE `form_care_plan` ADD `date_end` DATETIME DEFAULT NULL, ADD `reason_code` VARCHAR(31) DEFAULT NULL, ADD `reason_description` TEXT, ADD `reason_date_low` DATETIME DEFAULT NULL COMMENT 'The date the reason was recorded', ADD `reason_date_high` DATETIME DEFAULT NULL COMMENT 'The date the explanation reason for the care plan entry value ends' ;
#EndIf

#IfNotColumnType insurance_companies ins_type_code int(11)
ALTER TABLE `insurance_companies` CHANGE `ins_type_code` `ins_type_code` INT(11) NULL DEFAULT NULL;
ALTER TABLE `insurance_companies` CHANGE `inactive` `inactive` TINYINT(1) NOT NULL DEFAULT '0';
#EndIf

#IfUpdateEditOptionsNeeded remove DEM C street, street_line_2, city
#EndIf

#IfUpdateEditOptionsNeeded add DEM U street, street_line_2, city
#EndIf

#IfNotRow3D layout_options form_id DEM field_id postal_code fld_length 8
UPDATE `layout_options` SET `fld_length` = '8' WHERE `layout_options`.`form_id` = 'DEM' AND `layout_options`.`field_id` = 'postal_code';
#EndIf

#IfNotColumnType form_observation date datetime
ALTER TABLE `form_observation` CHANGE `date` `date` DATETIME NULL DEFAULT NULL;
ALTER TABLE `form_observation` CHANGE `ob_code` `ob_code` VARCHAR(64) NULL DEFAULT NULL, CHANGE `ob_type` `ob_type` VARCHAR(64) NULL DEFAULT NULL, CHANGE `ob_reason_code` `ob_reason_code` VARCHAR(64) NULL DEFAULT NULL;
#EndIf

#IfMissingColumn form_care_plan reason_status
ALTER TABLE `form_care_plan` ADD `reason_status` VARCHAR(31) NULL DEFAULT NULL;
#EndIf

#IfNotColumnType lists begdate datetime
ALTER TABLE `lists` CHANGE `begdate` `begdate` DATETIME NULL DEFAULT NULL;
ALTER TABLE `lists` CHANGE `enddate` `enddate` DATETIME NULL DEFAULT NULL;
#EndIf

#IfMissingColumn form_observation date_end
ALTER TABLE `form_observation` ADD `date_end` DATETIME NULL DEFAULT NULL;
#EndIf

#IfNotColumnType form_care_plan date datetime
ALTER TABLE `form_care_plan` CHANGE `date` `date` DATETIME NULL DEFAULT NULL;
#EndIf

#IfMissingColumn api_token context
ALTER TABLE api_token ADD COLUMN `context` TEXT COMMENT 'context values that change/govern how access token are used';
#EndIf

#IfRow2D list_options list_id language notes eng
CREATE TEMPORARY TABLE lang_updates_610 (notes char(15), twodigit_notes char(2));
START TRANSACTION;
INSERT INTO lang_updates_610 VALUES
('abk','ab'),
('aar','aa'),
('afr','af'),
('aka','ak'),
('alb(B)|sqi(T)','sq'),
('amh','am'),
('ara','ar'),
('arg','an'),
('arm(B)|hye(T)','hy'),
('asm','as'),
('ava','av'),
('ave','ae'),
('aym','ay'),
('aze','az'),
('bam','bm'),
('bak','ba'),
('baq(B)|eus(T)','eu'),
('bel','be'),
('ben','bn'),
('bih','bh'),
('bis','bi'),
('nob','nb'),
('bos','bs'),
('bre','br'),
('bul','bg'),
('bur(B)|mya(T)','my'),
('cat','ca'),
('khm','km'),
('cha','ch'),
('che','ce'),
('nya','ny'),
('chi(B)|zho(T)','zh'),
('chu','cu'),
('chv','cv'),
('cor','kw'),
('cos','co'),
('cre','cr'),
('hrv','hr'),
('cze(B)|ces(T)','cs'),
('dan','da'),
('div','dv'),
('dut(B)|nld(T)','nl'),
('dzo','dz'),
('eng','en'),
('epo','eo'),
('est','et'),
('ewe','ee'),
('fao','fo'),
('fij','fj'),
('fin','fi'),
('fre(B)|fra(T)','fr'),
('ful','ff'),
('gla','gd'),
('glg','gl'),
('lug','lg'),
('geo(B)|kat(T)','ka'),
('ger(B)|deu(T)','de'),
('gre(B)|ell(T)','el'),
('grn','gn'),
('guj','gu'),
('hat','ht'),
('hau','ha'),
('heb','he'),
('her','hz'),
('hin','hi'),
('hmo','ho'),
('hun','hu'),
('ice(B)|isl(T)','is'),
('ido','io'),
('ibo','ig'),
('ind','in'),
('ina','ia'),
('ile','ie'),
('iku','iu'),
('ipk','ik'),
('gle','ga'),
('ita','it'),
('jpn','ja'),
('jav','jv'),
('kal','kl'),
('kan','kn'),
('kau','kr'),
('kas','ks'),
('kaz','kk'),
('kik','ki'),
('kin','rw'),
('kir','ky'),
('kom','kv'),
('kon','kg'),
('kor','ko'),
('kua','kj'),
('kur','ku'),
('lao','lo'),
('lat','la'),
('lav','lv'),
('lim','li'),
('lin','ln'),
('lit','lt'),
('lub','lu'),
('ltz','lb'),
('mac(B)|mkd(T)','mk'),
('mlg','mg'),
('may(B)|msa(T)','ms'),
('mal','ml'),
('mlt','mt'),
('glv','gv'),
('mao(B)|mri(T)','mi'),
('mar','mr'),
('mah','mh'),
('mon','mn'),
('nau','na'),
('nav','nv'),
('nde','nd'),
('nbl','nr'),
('ndo','ng'),
('nep','ne'),
('sme','se'),
('nor','no'),
('nno','nn'),
('oci','oc'),
('oji','oj'),
('ori','or'),
('orm','om'),
('oss','os'),
('pli','pi'),
('per(B)|fas(T)','fa'),
('pol','pl'),
('por','pt'),
('pan','pa'),
('pus','ps'),
('que','qu'),
('rum(B)|ron(T)','ro'),
('roh','rm'),
('run','rn'),
('rus','ru'),
('smo','sm'),
('sag','sg'),
('san','sa'),
('srd','sc'),
('srp','sr'),
('sna','sn'),
('iii','ii'),
('snd','sd'),
('sin','si'),
('slo(B)|slk(T)','sk'),
('slv','sl'),
('som','so'),
('sot','st'),
('spa','es'),
('sun','su'),
('swa','sw'),
('ssw','ss'),
('swe','sv'),
('tgl','tl'),
('tah','ty'),
('tgk','tg'),
('tam','ta'),
('tat','tt'),
('tel','te'),
('tha','th'),
('tib(B)|bod(T)','bo'),
('tir','ti'),
('ton','to'),
('tso','ts'),
('tsn','tn'),
('tur','tr'),
('tuk','tk'),
('twi','tw'),
('uig','ug'),
('ukr','uk'),
('urd','ur'),
('uzb','uz'),
('ven','ve'),
('vie','vi'),
('vol','vo'),
('wln','wa'),
('wel(B)|cym(T)','cy'),
('fry','fy'),
('wol','wo'),
('xho','xh'),
('yid','yi'),
('yor','yo'),
('zha','za'),
('zul','zu');

UPDATE list_options JOIN lang_updates_610 ON list_options.list_id='language' AND list_options.notes = lang_updates_610.notes SET list_options.notes = lang_updates_610.twodigit_notes;
DROP TABLE lang_updates_610;
#EndIf;

#IfNotRow3D list_options list_id language option_id malay notes ms
UPDATE list_options SET notes='ms' WHERE list_id='language' AND option_id='malay';
#EndIf

#IfMissingColumn form_encounter date_end
ALTER TABLE `form_encounter` ADD `date_end` DATETIME DEFAULT NULL;
#EndIf

#IfMissingColumn procedure_order_code date_end
ALTER TABLE `procedure_order_code` ADD `date_end` datetime DEFAULT NULL;
ALTER TABLE `procedure_order_code` ADD `reason_code` varchar(31) DEFAULT NULL;
ALTER TABLE `procedure_order_code` ADD `reason_description` text;
ALTER TABLE `procedure_order_code` ADD `reason_date_low` datetime DEFAULT NULL;
ALTER TABLE `procedure_order_code` ADD `reason_date_high` datetime DEFAULT NULL;
ALTER TABLE `procedure_order_code` ADD `reason_status` varchar(31) DEFAULT NULL;
#EndIf

#IfNotColumnType procedure_order_code procedure_code VARCHAR(64)
ALTER TABLE `procedure_order_code` CHANGE `procedure_code` `procedure_code` VARCHAR(64) NOT NULL DEFAULT '' COMMENT 'like procedure_type.procedure_code';
#EndIf

#IfNotColumnType procedure_order date_ordered DATETIME
ALTER TABLE `procedure_order` CHANGE `date_ordered` `date_ordered` DATETIME DEFAULT NULL;
#EndIf

#IfMissingColumn immunizations reason_code
ALTER TABLE `immunizations` CHANGE `cvx_code` `cvx_code` VARCHAR(64) DEFAULT NULL;
ALTER TABLE `immunizations` ADD `reason_code` varchar(31) DEFAULT NULL COMMENT 'Medical code explaining reason of the vital observation value in form codesystem:codetype;...;';
ALTER TABLE `immunizations` ADD `reason_description` TEXT COMMENT 'Human readable text description of the reason_code column';
#EndIf

#IfMissingColumn categories codes
ALTER TABLE categories ADD COLUMN `codes` varchar(255) NOT NULL DEFAULT '' COMMENT 'Category codes for documents stored in this category';
UPDATE categories SET codes='LOINC:LP173418-7' WHERE name='Advance Directive';
UPDATE categories SET codes='LOINC:LP173421-1' WHERE name='FHIR Export Document';
UPDATE categories SET codes='LOINC:LP173394-0' WHERE name='Reviewed';
#EndIf

#IfMissingColumn form_vital_details reason_code
ALTER TABLE `form_vital_details` ADD `reason_code` VARCHAR(31) DEFAULT NULL COMMENT 'Medical code explaining reason of the vital observation value in form codesystem:codetype;...;', ADD `reason_description` TEXT COMMENT 'Human readable text description of the reason_code column', ADD `reason_status` VARCHAR(31) NULL DEFAULT NULL COMMENT 'The status of the reason ie completed, in progress, etc';
#EndIf

#IfNotRow2D list_options list_id lists option_id encounter-types
INSERT INTO list_options (list_id,option_id,title, seq, is_default, option_value) VALUES ('lists','encounter-types','Encounter Types',0, 1, 0);
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity) VALUES ('encounter-types','visit-after-hours','Visit out of hours',10,0,1);
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity) VALUES ('encounter-types','visit-after-hours-not-night','Out of Hours visit (Not Night)',20,0,1);
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity) VALUES ('encounter-types','weekend-visit','Weekend Visit',30,0,1);
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity) VALUES ('encounter-types','office-visit','Office visit for pediatric care and assessment',40,0,1);
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity) VALUES ('encounter-types','established-patient','Evaluation and management of established patient in office or outpatient facility',50,0,1);
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity) VALUES ('encounter-types','new-patient','Evaluation and management of new patient in office or outpatient facility',60,0,1);
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity) VALUES ('encounter-types','postoperative-follow-up','Postoperative follow-up visit',70,0,1);
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity) VALUES ('encounter-types','new-patient-10','New Patient - 10 Minutes',80,0,1);
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity) VALUES ('encounter-types','new-patient-15-29','New Patient - 15-29 Minutes',90,0,1);
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity) VALUES ('encounter-types','new-patient-30-44','New Patient - 30-44 Minutes',100,0,1);
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity) VALUES ('encounter-types','new-patient-45-59','New Patient - 45-59 Minutes',110,0,1);
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity) VALUES ('encounter-types','new-patient-60-74','New Patient - 60-74 Minutes',120,0,1);
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity) VALUES ('encounter-types','established-patient-10-19','Established Patient - 10-19 Minutes',130,0,1);
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity) VALUES ('encounter-types','established-patient-20-29','Established Patient - 20-29 Minutes',140,0,1);
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity) VALUES ('encounter-types','established-patient-30-39','Established Patient - 30-39 Minutes',140,0,1);
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity) VALUES ('encounter-types','established-patient-40-54','Established Patient - 40-54 Minutes',150,0,1);
#EndIf

#IfNotRow2D list_options list_id immunization_refusal_reason option_id financial_problem
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`, `notes`) VALUES ('immunization_refusal_reason','financial_problem','Financial Problem',50,1, "03");
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`, `notes`) VALUES ('immunization_refusal_reason','financial_circumstances_change','Financial circumstances change',60,1, "03");
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`, `notes`) VALUES ('immunization_refusal_reason','alternative_treatment_requested','Alternative Treatment Requested',70,1, "03");
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`, `notes`) VALUES ('immunization_refusal_reason','patient_declined_procedure','Patient declined procedure',80,1, "03");
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`, `notes`) VALUES ('immunization_refusal_reason','patient_declined_drug','Patient declined drug',90,1, "03");
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`, `notes`) VALUES ('immunization_refusal_reason','patient_declined_drug_effects','Patient declined drug - side effects',100,1, "03");
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`, `notes`) VALUES ('immunization_refusal_reason','patient_declined_drug_beliefs','Patient declined drug - patient beliefs',110,1, "01");
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`, `notes`) VALUES ('immunization_refusal_reason','patient_declined_drug_cannot_pay','Patient declined drug - cannot pay script',120,1, "03");
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`, `notes`) VALUES ('immunization_refusal_reason','patient_moved','Patient moved',130,1, "03");
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`, `notes`) VALUES ('immunization_refusal_reason','patient_dissatisfied_result','Patient dissatisfied with result',140,1, "03");
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`, `notes`) VALUES ('immunization_refusal_reason','patient_dissatisfied_doctor','Patient dissatisfied with doctor',150,1, "03");
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`, `notes`) VALUES ('immunization_refusal_reason','patient_variable_income','Variable income',160,1, "03");
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`, `notes`) VALUES ('immunization_refusal_reason','patient_self_discharge','Patient self-discharge against medical advice',170,1, "03");
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`, `notes`) VALUES ('immunization_refusal_reason','drugs_not_completed','Drugs not taken/completed',180,1, "03");
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`, `notes`) VALUES ('immunization_refusal_reason','family_illness','Family illness',190,1, "02");
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`, `notes`) VALUES ('immunization_refusal_reason','follow_defaulted','Patient defaulted from follow-up',200,1, "03");
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`, `notes`) VALUES ('immunization_refusal_reason','patient_noncompliance','Patient noncompliance - general',210,1, "03");
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`, `notes`) VALUES ('immunization_refusal_reason','patient_noshow','Patient did not attend',220,1, "03");
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`, `notes`) VALUES ('immunization_refusal_reason','patient_further_opinion','Further opinion sought',230,1, "03");
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`, `notes`) VALUES ('immunization_refusal_reason','patient_treatment_delay','Treatment delay - patient choice',240,1, "03");
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`, `notes`) VALUES ('immunization_refusal_reason','patient_medication_declined','Medication declined',250,1, "03");
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`, `notes`) VALUES ('immunization_refusal_reason','patient_medication_forgot','Patient forgets to take medication',260,1, "03");
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`, `notes`) VALUES ('immunization_refusal_reason','patient_non_compliant','Patient non-compliant declined intervention/support',270,1, "03");
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`, `notes`) VALUES ('immunization_refusal_reason','procedure_not_wanted','Procedure not wanted',280,1, "03");
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`, `notes`) VALUES ('immunization_refusal_reason','income_insufficient','Income insufficient to buy necessities',290,1, "03");
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`, `notes`) VALUES ('immunization_refusal_reason','income_necessities_only','Income sufficient to buy only necessities',300,1, "03");
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`, `notes`) VALUES ('immunization_refusal_reason','refused','Refused',310,1, "03");
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `activity`, `notes`) VALUES ('immunization_refusal_reason','patient_procedure_discontinued','Procedure discontinued by patient',320,1, "03");
#EndIf

#IfNotRow2D list_options list_id Plan_of_Care_Type option_id planned_medication_activity
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `is_default`, `option_value`, `mapping`, `notes`, `codes`, `toggle_setting_1`, `toggle_setting_2`, `activity`, `subtype`, `edit_options`) VALUES ('Plan_of_Care_Type', 'planned_medication_activity', 'Planned Medication Act', '20', '0', '0', '', 'RQO', '', '0', '0', '1', '', '1');
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `is_default`, `option_value`, `mapping`, `notes`, `codes`, `toggle_setting_1`, `toggle_setting_2`, `activity`, `subtype`, `edit_options`) VALUES ('Plan_of_Care_Type', 'supply_order', 'Supply Order Act', '30', '0', '0', '', 'RQO', '', '0', '0', '1', '', '1');
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `is_default`, `option_value`, `mapping`, `notes`, `codes`, `toggle_setting_1`, `toggle_setting_2`, `activity`, `subtype`, `edit_options`) VALUES ('Plan_of_Care_Type', 'device_order', 'Device Order', '40', '0', '0', '', 'RQO', '', '0', '0', '1', '', '1');
#EndIf

-- below is missing in some demos and test databases
#IfNotRow2D list_options list_id Plan_of_Care_Type option_id medication
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `is_default`, `option_value`, `mapping`, `notes`, `codes`, `activity`, `toggle_setting_1`, `toggle_setting_2`, `subtype`) VALUES('Plan_of_Care_Type','medication','Medication','8','0','0','','INT','','1','0','0','');
#EndIf

#IfNotRow2D list_options list_id issue_subtypes option_id assessment
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`) VALUES ('issue_subtypes','assessment','Assessment',20);
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`) VALUES ('issue_subtypes','concern','Concern',30);
#EndIf

#IfNotRow2D list_options list_id Observation_Types option_id assessment
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `is_default`, `option_value`, `mapping`, `notes`, `codes`, `toggle_setting_1`, `toggle_setting_2`, `activity`, `subtype`) VALUES ('lists','Observation_Types','Observation Types',0,1,0,'',NULL,'',0,0,1,'');
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `is_default`, `option_value`, `mapping`, `notes`, `codes`, `toggle_setting_1`, `toggle_setting_2`, `activity`, `subtype`) VALUES ('Observation_Types','assessment','Assessment',10,0,0,'','','',0,0,1,'');
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `is_default`, `option_value`, `mapping`, `notes`, `codes`, `toggle_setting_1`, `toggle_setting_2`, `activity`, `subtype`) VALUES ('Observation_Types','procedure_diagnostic','Procedure Diagnostic',20,0,0,'','','',0,0,1,'');
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `is_default`, `option_value`, `mapping`, `notes`, `codes`, `toggle_setting_1`, `toggle_setting_2`, `activity`, `subtype`) VALUES ('Observation_Types','physical_exam_performed','Physical Exam Performed',30,0,0,'','','',0,0,1,'');
#EndIf

#IfNotRow2D list_options list_id Plan_of_Care_Type option_id intervention
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`, `is_default`, `option_value`, `mapping`, `notes`, `codes`, `toggle_setting_1`, `toggle_setting_2`, `activity`, `subtype`, `edit_options`) VALUES ('Plan_of_Care_Type', 'intervention', 'Intervention', '9', '0', '0', '', 'RQO', '', '0', '0', '1', '', '1');
#EndIf

#IfNotTable valueset_oid
CREATE TABLE `valueset_oid` (
  `nqf_code` varchar(255) NOT NULL DEFAULT '',
  `code` varchar(255) NOT NULL DEFAULT '',
  `code_system` varchar(255) NOT NULL DEFAULT '',
  `code_type` varchar(255) DEFAULT NULL,
  `valueset` varchar(255) NOT NULL DEFAULT '',
  `description` varchar(255) DEFAULT NULL,
  `valueset_name` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`nqf_code`,`code`,`valueset`)
) ENGINE=InnoDB;
#EndIf

#IfNotRow code_types ct_key OID
DROP TABLE IF EXISTS `temp_table_one`;
CREATE TABLE `temp_table_one` (`id` int(11) NOT NULL DEFAULT '0',`seq` int(11) NOT NULL DEFAULT '0') ENGINE=InnoDB;
INSERT INTO `temp_table_one` (`id`, `seq`) VALUES (
  IF(((SELECT MAX(`ct_id` ) FROM `code_types`) >= 100), ((SELECT MAX(`ct_id` ) FROM `code_types`) + 1), 100),
  IF(((SELECT MAX(`ct_seq`) FROM `code_types`) >= 100), ((SELECT MAX(`ct_seq`) FROM `code_types`) + 1), 100));
INSERT INTO `code_types` (`ct_key`, `ct_id`, `ct_seq`, `ct_mod`, `ct_just`, `ct_mask`, `ct_fee`, `ct_rel`, `ct_nofs`, `ct_diag`, `ct_active`, `ct_label`, `ct_external`, `ct_claim`, `ct_proc`, `ct_term`, `ct_problem`, `ct_drug`) VALUES
    ('OID', (SELECT MAX(`id`) FROM `temp_table_one`), (SELECT MAX(`seq`) FROM `temp_table_one`), '0', '', '', '1', '1', '0', '1', '1', 'OID Valueset', '14', '1', '1', '1', '1', '1');
DROP TABLE `temp_table_one`;
#EndIf

#IfNotRow2D list_options list_id issue_subtypes option_id diagnosis
INSERT INTO `list_options` (`list_id`, `option_id`, `title`, `seq`) VALUES ('issue_subtypes','diagnosis','Diagnosis',40);
#EndIf

#IfColumn patient_data deceased_date
SET @currentSQLMode = (SELECT @@sql_mode);
SET sql_mode = '';
UPDATE `patient_data` SET `deceased_date` = NULL WHERE `deceased_date` = '0000-00-00 00:00:00';
SET sql_mode = @currentSQLMode;
#EndIf

#IfMissingColumn insurance_companies cqm_sop
ALTER TABLE `insurance_companies` ADD `cqm_sop` int DEFAULT NULL COMMENT 'HL7 Source of Payment for eCQMs';
#EndIf

#IfNotRow2D list_options list_id order_type option_id order
INSERT INTO list_options ( list_id, option_id, title, seq, is_default ) VALUES ('order_type','order','Order',90,0);
#EndIf

#IfNotColumnType procedure_type procedure_code varchar(64)
ALTER TABLE `procedure_type` MODIFY `procedure_code` varchar(64) NOT NULL DEFAULT '' COMMENT 'code identifying this procedure';
#EndIf

#IfNotRow2D categories name CCD codes LOINC:34133-9
Update categories SET codes='LOINC:34133-9' WHERE name='CCD';
#EndIf

#IfNotRow2D list_options list_id lists option_id ccda-sections
INSERT INTO list_options (list_id,option_id,title, seq, is_default, option_value) VALUES ('lists','ccda-sections','CCDA Sections',0, 1, 0);
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity, codes) VALUES ('ccda-sections','allergies_required','Allergies and Intollerances (entries required)',10,0,1, 'oid:2.16.840.1.113883.10.20.22.2.6.1');
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity, codes) VALUES ('ccda-sections','medications','History of medication use',20,0,1, 'oid:2.16.840.1.113883.10.20.22.2.1.1');
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity, codes) VALUES ('ccda-sections','problems','Problem list',30,0,1, 'oid:2.16.840.1.113883.10.20.22.2.5.1');
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity, codes) VALUES ('ccda-sections','procedures','History of procedures',40,0,1, 'oid:2.16.840.1.113883.10.20.22.2.7.1');
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity, codes) VALUES ('ccda-sections','dx_tests_labdata','Relevant Dx tests/lab data',50,0,1, 'oid:2.16.840.1.113883.10.20.22.2.3.1');
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity, codes) VALUES ('ccda-sections','functional_status','Functional Status',60,0,1, 'oid:2.16.840.1.113883.10.20.22.2.14');
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity, codes) VALUES ('ccda-sections','progress_note','Clinical Notes (History & Physical,Procedure,Discharge,Imaging)',70,0,1, 'oid:2.16.840.1.113883.10.20.22.2.65');
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity, codes) VALUES ('ccda-sections','procedures_section','Procedures Section',80,0,1, 'oid:2.16.840.1.113883.10.20.22.2.7.1');
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity, codes) VALUES ('ccda-sections','encounters','Encounters',110,0,1, 'oid:2.16.840.1.113883.10.20.22.2.22.1');
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity, codes) VALUES ('ccda-sections','immunizations','Immunizations',120,0,1, 'oid:2.16.840.1.113883.10.20.22.2.2');
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity, codes) VALUES ('ccda-sections','assessments','Assessments',130,0,1, 'oid:2.16.840.1.113883.10.20.22.2.8');
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity, codes) VALUES ('ccda-sections','treatment_plan','Treatment Plan',140,0,1, 'oid:2.16.840.1.113883.10.20.22.2.10');
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity, codes) VALUES ('ccda-sections','goals','Goals',150,0,1, 'oid:2.16.840.1.113883.10.20.22.2.60');
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity, codes) VALUES ('ccda-sections','health_concerns','Health Concerns',160,0,1, 'oid:2.16.840.1.113883.10.20.22.2.58');
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity, codes) VALUES ('ccda-sections','reason_of_visit','Reason for Referral',170,0,1, 'oid:1.3.6.1.4.1.19376.1.5.3.1.3.1');
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity, codes) VALUES ('ccda-sections','mental_status','Mental Status',180,0,1, 'oid:2.16.840.1.113883.10.20.22.2.56');
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity, codes) VALUES ('ccda-sections','social_history','Social History',190,0,1, 'oid:2.16.840.1.113883.10.20.22.2.17');
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity, codes) VALUES ('ccda-sections','vital_signs','Vital Signs',200,0,1, 'oid:2.16.840.1.113883.10.20.22.2.4.1');
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity, codes) VALUES ('ccda-sections','medical_equipment','Medical Equipment',210,0,1, 'oid:2.16.840.1.113883.10.20.22.2.23');
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity, codes) VALUES ('ccda-sections','us_realm_person_name','US Realm Person Name',220,0,1, 'oid:2.16.840.1.113883.10.20.22.5.1.1');
#EndIf


#IfNotRow2D list_options list_id drug_interval option_id WK
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity) VALUES ('drug_interval','WK','Weekly',19,0,1);
INSERT INTO list_options (list_id,option_id,title,seq,is_default,activity) VALUES ('drug_interval','MO','Monthly',20,0,1);
#EndIf

#IfRow3D list_options list_id immunization_refusal_reason option_id parental_decision seq 10
UPDATE list_options SET seq=40 WHERE list_id="immunization_refusal_reason" AND option_id="parental_decision";
UPDATE list_options SET seq=10 WHERE list_id="immunization_refusal_reason" AND option_id="patient_decision";
#EndIf

#IfMissingColumn procedure_result date_end
ALTER TABLE `procedure_result` ADD `date_end` datetime DEFAULT NULL COMMENT 'lab-provided end date specific to this result';
#EndIf
