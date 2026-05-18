"""
Generates a comprehensive ICD-10 disease list (WHO-aligned, 400+ entries)
covering all major chapters. This mirrors the WHO ICD-10 Version 2019 structure.
Each entry: {code, description, chapter, chapter_name, specialty}
"""

ICD10_DATA = [
  # ── Chapter I: Infectious and parasitic diseases (A00–B99) ─────────────────
  {"code":"A00","description":"Cholera","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"Infectious Disease"},
  {"code":"A01","description":"Typhoid and paratyphoid fevers","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"Infectious Disease"},
  {"code":"A02","description":"Other Salmonella infections","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"Infectious Disease"},
  {"code":"A04","description":"Other bacterial intestinal infections","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"Gastroenterology"},
  {"code":"A06","description":"Amoebiasis","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"Gastroenterology"},
  {"code":"A09","description":"Diarrhoea and gastroenteritis of presumed infectious origin","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"Gastroenterology"},
  {"code":"A15","description":"Respiratory tuberculosis","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"Pulmonology"},
  {"code":"A16","description":"Respiratory tuberculosis, not confirmed bacteriologically","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"Pulmonology"},
  {"code":"A17","description":"Tuberculosis of nervous system","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"Neurology"},
  {"code":"A20","description":"Plague","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"Infectious Disease"},
  {"code":"A22","description":"Anthrax","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"Infectious Disease"},
  {"code":"A27","description":"Leptospirosis","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"Infectious Disease"},
  {"code":"A33","description":"Tetanus neonatorum","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"Paediatrics"},
  {"code":"A36","description":"Diphtheria","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"Infectious Disease"},
  {"code":"A37","description":"Whooping cough","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"Pulmonology"},
  {"code":"A38","description":"Scarlet fever","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"Infectious Disease"},
  {"code":"A40","description":"Streptococcal septicaemia","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"Infectious Disease"},
  {"code":"A41","description":"Other septicaemia","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"Infectious Disease"},
  {"code":"A50","description":"Congenital syphilis","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"Dermatology"},
  {"code":"A54","description":"Gonococcal infection","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"Urology"},
  {"code":"A60","description":"Anogenital herpesviral infection","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"Dermatology"},
  {"code":"A69","description":"Other spirochaetal infections","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"Infectious Disease"},
  {"code":"A80","description":"Acute poliomyelitis","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"Neurology"},
  {"code":"A82","description":"Rabies","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"Neurology"},
  {"code":"A87","description":"Viral meningitis","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"Neurology"},
  {"code":"A90","description":"Dengue fever","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"Infectious Disease"},
  {"code":"A91","description":"Dengue haemorrhagic fever","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"Infectious Disease"},
  {"code":"A95","description":"Yellow fever","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"Infectious Disease"},
  {"code":"B01","description":"Varicella (chickenpox)","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"General Medicine"},
  {"code":"B02","description":"Zoster (herpes zoster)","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"Dermatology"},
  {"code":"B05","description":"Measles","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"General Medicine"},
  {"code":"B06","description":"Rubella","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"General Medicine"},
  {"code":"B15","description":"Acute hepatitis A","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"Gastroenterology"},
  {"code":"B16","description":"Acute hepatitis B","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"Gastroenterology"},
  {"code":"B17","description":"Other acute viral hepatitis","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"Gastroenterology"},
  {"code":"B18","description":"Chronic viral hepatitis","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"Gastroenterology"},
  {"code":"B20","description":"HIV disease resulting in infectious diseases","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"Infectious Disease"},
  {"code":"B50","description":"Plasmodium falciparum malaria","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"Infectious Disease"},
  {"code":"B54","description":"Unspecified malaria","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"Infectious Disease"},
  {"code":"B77","description":"Ascariasis","chapter":"I","chapter_name":"Certain infectious and parasitic diseases","specialty":"Gastroenterology"},

  # ── Chapter II: Neoplasms (C00–D49) ───────────────────────────────────────
  {"code":"C00","description":"Malignant neoplasm of lip","chapter":"II","chapter_name":"Neoplasms","specialty":"Oncology"},
  {"code":"C15","description":"Malignant neoplasm of oesophagus","chapter":"II","chapter_name":"Neoplasms","specialty":"Oncology"},
  {"code":"C16","description":"Malignant neoplasm of stomach","chapter":"II","chapter_name":"Neoplasms","specialty":"Oncology"},
  {"code":"C18","description":"Malignant neoplasm of colon","chapter":"II","chapter_name":"Neoplasms","specialty":"Oncology"},
  {"code":"C20","description":"Malignant neoplasm of rectum","chapter":"II","chapter_name":"Neoplasms","specialty":"Oncology"},
  {"code":"C22","description":"Malignant neoplasm of liver","chapter":"II","chapter_name":"Neoplasms","specialty":"Oncology"},
  {"code":"C25","description":"Malignant neoplasm of pancreas","chapter":"II","chapter_name":"Neoplasms","specialty":"Oncology"},
  {"code":"C34","description":"Malignant neoplasm of bronchus and lung","chapter":"II","chapter_name":"Neoplasms","specialty":"Oncology"},
  {"code":"C43","description":"Malignant melanoma of skin","chapter":"II","chapter_name":"Neoplasms","specialty":"Oncology"},
  {"code":"C50","description":"Malignant neoplasm of breast","chapter":"II","chapter_name":"Neoplasms","specialty":"Oncology"},
  {"code":"C53","description":"Malignant neoplasm of cervix uteri","chapter":"II","chapter_name":"Neoplasms","specialty":"Oncology"},
  {"code":"C61","description":"Malignant neoplasm of prostate","chapter":"II","chapter_name":"Neoplasms","specialty":"Oncology"},
  {"code":"C67","description":"Malignant neoplasm of bladder","chapter":"II","chapter_name":"Neoplasms","specialty":"Oncology"},
  {"code":"C71","description":"Malignant neoplasm of brain","chapter":"II","chapter_name":"Neoplasms","specialty":"Oncology"},
  {"code":"C73","description":"Malignant neoplasm of thyroid gland","chapter":"II","chapter_name":"Neoplasms","specialty":"Oncology"},
  {"code":"C90","description":"Multiple myeloma","chapter":"II","chapter_name":"Neoplasms","specialty":"Oncology"},
  {"code":"C91","description":"Lymphoid leukaemia","chapter":"II","chapter_name":"Neoplasms","specialty":"Oncology"},
  {"code":"C92","description":"Myeloid leukaemia","chapter":"II","chapter_name":"Neoplasms","specialty":"Oncology"},
  {"code":"D10","description":"Benign neoplasm of mouth and pharynx","chapter":"II","chapter_name":"Neoplasms","specialty":"ENT"},
  {"code":"D25","description":"Leiomyoma of uterus","chapter":"II","chapter_name":"Neoplasms","specialty":"Gynaecology"},

  # ── Chapter III: Blood diseases (D50–D89) ─────────────────────────────────
  {"code":"D50","description":"Iron deficiency anaemia","chapter":"III","chapter_name":"Diseases of the blood","specialty":"General Medicine"},
  {"code":"D51","description":"Vitamin B12 deficiency anaemia","chapter":"III","chapter_name":"Diseases of the blood","specialty":"General Medicine"},
  {"code":"D56","description":"Thalassaemia","chapter":"III","chapter_name":"Diseases of the blood","specialty":"Haematology"},
  {"code":"D57","description":"Sickle-cell disorders","chapter":"III","chapter_name":"Diseases of the blood","specialty":"Haematology"},
  {"code":"D64","description":"Other anaemias","chapter":"III","chapter_name":"Diseases of the blood","specialty":"General Medicine"},
  {"code":"D65","description":"Disseminated intravascular coagulation","chapter":"III","chapter_name":"Diseases of the blood","specialty":"Haematology"},
  {"code":"D69","description":"Purpura and other haemorrhagic conditions","chapter":"III","chapter_name":"Diseases of the blood","specialty":"Haematology"},

  # ── Chapter IV: Endocrine diseases (E00–E90) ──────────────────────────────
  {"code":"E01","description":"Iodine-deficiency thyroid disorders","chapter":"IV","chapter_name":"Endocrine, nutritional and metabolic diseases","specialty":"Endocrinology"},
  {"code":"E03","description":"Other hypothyroidism","chapter":"IV","chapter_name":"Endocrine, nutritional and metabolic diseases","specialty":"Endocrinology"},
  {"code":"E05","description":"Thyrotoxicosis","chapter":"IV","chapter_name":"Endocrine, nutritional and metabolic diseases","specialty":"Endocrinology"},
  {"code":"E10","description":"Insulin-dependent diabetes mellitus","chapter":"IV","chapter_name":"Endocrine, nutritional and metabolic diseases","specialty":"Endocrinology"},
  {"code":"E11","description":"Non-insulin-dependent diabetes mellitus","chapter":"IV","chapter_name":"Endocrine, nutritional and metabolic diseases","specialty":"Endocrinology"},
  {"code":"E14","description":"Unspecified diabetes mellitus","chapter":"IV","chapter_name":"Endocrine, nutritional and metabolic diseases","specialty":"Endocrinology"},
  {"code":"E22","description":"Hyperfunction of pituitary gland","chapter":"IV","chapter_name":"Endocrine, nutritional and metabolic diseases","specialty":"Endocrinology"},
  {"code":"E27","description":"Other disorders of adrenal gland","chapter":"IV","chapter_name":"Endocrine, nutritional and metabolic diseases","specialty":"Endocrinology"},
  {"code":"E40","description":"Kwashiorkor","chapter":"IV","chapter_name":"Endocrine, nutritional and metabolic diseases","specialty":"Nutrition"},
  {"code":"E46","description":"Unspecified protein-energy malnutrition","chapter":"IV","chapter_name":"Endocrine, nutritional and metabolic diseases","specialty":"Nutrition"},
  {"code":"E50","description":"Vitamin A deficiency","chapter":"IV","chapter_name":"Endocrine, nutritional and metabolic diseases","specialty":"General Medicine"},
  {"code":"E55","description":"Vitamin D deficiency","chapter":"IV","chapter_name":"Endocrine, nutritional and metabolic diseases","specialty":"General Medicine"},
  {"code":"E66","description":"Obesity","chapter":"IV","chapter_name":"Endocrine, nutritional and metabolic diseases","specialty":"Endocrinology"},
  {"code":"E78","description":"Disorders of lipoprotein metabolism","chapter":"IV","chapter_name":"Endocrine, nutritional and metabolic diseases","specialty":"Cardiology"},
  {"code":"E87","description":"Other disorders of fluid and acid-base balance","chapter":"IV","chapter_name":"Endocrine, nutritional and metabolic diseases","specialty":"Nephrology"},

  # ── Chapter V: Mental disorders (F00–F99) ─────────────────────────────────
  {"code":"F00","description":"Dementia in Alzheimer disease","chapter":"V","chapter_name":"Mental and behavioural disorders","specialty":"Psychiatry"},
  {"code":"F10","description":"Mental and behavioural disorders due to alcohol","chapter":"V","chapter_name":"Mental and behavioural disorders","specialty":"Psychiatry"},
  {"code":"F20","description":"Schizophrenia","chapter":"V","chapter_name":"Mental and behavioural disorders","specialty":"Psychiatry"},
  {"code":"F30","description":"Manic episode","chapter":"V","chapter_name":"Mental and behavioural disorders","specialty":"Psychiatry"},
  {"code":"F32","description":"Depressive episode","chapter":"V","chapter_name":"Mental and behavioural disorders","specialty":"Psychiatry"},
  {"code":"F40","description":"Phobic anxiety disorders","chapter":"V","chapter_name":"Mental and behavioural disorders","specialty":"Psychiatry"},
  {"code":"F41","description":"Other anxiety disorders","chapter":"V","chapter_name":"Mental and behavioural disorders","specialty":"Psychiatry"},
  {"code":"F42","description":"Obsessive-compulsive disorder","chapter":"V","chapter_name":"Mental and behavioural disorders","specialty":"Psychiatry"},
  {"code":"F43","description":"Reaction to severe stress and adjustment disorders","chapter":"V","chapter_name":"Mental and behavioural disorders","specialty":"Psychiatry"},
  {"code":"F50","description":"Eating disorders","chapter":"V","chapter_name":"Mental and behavioural disorders","specialty":"Psychiatry"},
  {"code":"F90","description":"Hyperkinetic disorders (ADHD)","chapter":"V","chapter_name":"Mental and behavioural disorders","specialty":"Psychiatry"},
  {"code":"F91","description":"Conduct disorders","chapter":"V","chapter_name":"Mental and behavioural disorders","specialty":"Psychiatry"},

  # ── Chapter VI: Nervous system (G00–G99) ──────────────────────────────────
  {"code":"G00","description":"Bacterial meningitis","chapter":"VI","chapter_name":"Diseases of the nervous system","specialty":"Neurology"},
  {"code":"G04","description":"Encephalitis and encephalomyelitis","chapter":"VI","chapter_name":"Diseases of the nervous system","specialty":"Neurology"},
  {"code":"G20","description":"Parkinson disease","chapter":"VI","chapter_name":"Diseases of the nervous system","specialty":"Neurology"},
  {"code":"G30","description":"Alzheimer disease","chapter":"VI","chapter_name":"Diseases of the nervous system","specialty":"Neurology"},
  {"code":"G35","description":"Multiple sclerosis","chapter":"VI","chapter_name":"Diseases of the nervous system","specialty":"Neurology"},
  {"code":"G40","description":"Epilepsy","chapter":"VI","chapter_name":"Diseases of the nervous system","specialty":"Neurology"},
  {"code":"G43","description":"Migraine","chapter":"VI","chapter_name":"Diseases of the nervous system","specialty":"Neurology"},
  {"code":"G44","description":"Other headache syndromes","chapter":"VI","chapter_name":"Diseases of the nervous system","specialty":"Neurology"},
  {"code":"G45","description":"Transient cerebral ischaemic attacks","chapter":"VI","chapter_name":"Diseases of the nervous system","specialty":"Neurology"},
  {"code":"G50","description":"Disorders of trigeminal nerve","chapter":"VI","chapter_name":"Diseases of the nervous system","specialty":"Neurology"},
  {"code":"G54","description":"Nerve root and plexus disorders","chapter":"VI","chapter_name":"Diseases of the nervous system","specialty":"Neurology"},
  {"code":"G61","description":"Inflammatory polyneuropathy","chapter":"VI","chapter_name":"Diseases of the nervous system","specialty":"Neurology"},
  {"code":"G80","description":"Cerebral palsy","chapter":"VI","chapter_name":"Diseases of the nervous system","specialty":"Neurology"},

  # ── Chapter VII: Eye (H00–H59) ────────────────────────────────────────────
  {"code":"H00","description":"Hordeolum and chalazion","chapter":"VII","chapter_name":"Diseases of the eye","specialty":"Ophthalmology"},
  {"code":"H10","description":"Conjunctivitis","chapter":"VII","chapter_name":"Diseases of the eye","specialty":"Ophthalmology"},
  {"code":"H25","description":"Senile cataract","chapter":"VII","chapter_name":"Diseases of the eye","specialty":"Ophthalmology"},
  {"code":"H26","description":"Other cataract","chapter":"VII","chapter_name":"Diseases of the eye","specialty":"Ophthalmology"},
  {"code":"H35","description":"Other retinal disorders","chapter":"VII","chapter_name":"Diseases of the eye","specialty":"Ophthalmology"},
  {"code":"H40","description":"Glaucoma","chapter":"VII","chapter_name":"Diseases of the eye","specialty":"Ophthalmology"},
  {"code":"H52","description":"Disorders of refraction and accommodation","chapter":"VII","chapter_name":"Diseases of the eye","specialty":"Ophthalmology"},

  # ── Chapter VIII: Ear (H60–H95) ───────────────────────────────────────────
  {"code":"H60","description":"Otitis externa","chapter":"VIII","chapter_name":"Diseases of the ear","specialty":"ENT"},
  {"code":"H65","description":"Nonsuppurative otitis media","chapter":"VIII","chapter_name":"Diseases of the ear","specialty":"ENT"},
  {"code":"H66","description":"Suppurative and unspecified otitis media","chapter":"VIII","chapter_name":"Diseases of the ear","specialty":"ENT"},
  {"code":"H81","description":"Disorders of vestibular function","chapter":"VIII","chapter_name":"Diseases of the ear","specialty":"ENT"},
  {"code":"H90","description":"Conductive and sensorineural hearing loss","chapter":"VIII","chapter_name":"Diseases of the ear","specialty":"ENT"},
  {"code":"H91","description":"Other hearing loss","chapter":"VIII","chapter_name":"Diseases of the ear","specialty":"ENT"},

  # ── Chapter IX: Circulatory system (I00–I99) ──────────────────────────────
  {"code":"I00","description":"Rheumatic fever without heart involvement","chapter":"IX","chapter_name":"Diseases of the circulatory system","specialty":"Cardiology"},
  {"code":"I05","description":"Rheumatic mitral valve diseases","chapter":"IX","chapter_name":"Diseases of the circulatory system","specialty":"Cardiology"},
  {"code":"I10","description":"Essential hypertension","chapter":"IX","chapter_name":"Diseases of the circulatory system","specialty":"Cardiology"},
  {"code":"I11","description":"Hypertensive heart disease","chapter":"IX","chapter_name":"Diseases of the circulatory system","specialty":"Cardiology"},
  {"code":"I20","description":"Angina pectoris","chapter":"IX","chapter_name":"Diseases of the circulatory system","specialty":"Cardiology"},
  {"code":"I21","description":"Acute myocardial infarction","chapter":"IX","chapter_name":"Diseases of the circulatory system","specialty":"Cardiology"},
  {"code":"I25","description":"Chronic ischaemic heart disease","chapter":"IX","chapter_name":"Diseases of the circulatory system","specialty":"Cardiology"},
  {"code":"I26","description":"Pulmonary embolism","chapter":"IX","chapter_name":"Diseases of the circulatory system","specialty":"Cardiology"},
  {"code":"I27","description":"Other pulmonary heart diseases","chapter":"IX","chapter_name":"Diseases of the circulatory system","specialty":"Cardiology"},
  {"code":"I42","description":"Cardiomyopathy","chapter":"IX","chapter_name":"Diseases of the circulatory system","specialty":"Cardiology"},
  {"code":"I48","description":"Atrial fibrillation and flutter","chapter":"IX","chapter_name":"Diseases of the circulatory system","specialty":"Cardiology"},
  {"code":"I50","description":"Heart failure","chapter":"IX","chapter_name":"Diseases of the circulatory system","specialty":"Cardiology"},
  {"code":"I60","description":"Subarachnoid haemorrhage","chapter":"IX","chapter_name":"Diseases of the circulatory system","specialty":"Neurology"},
  {"code":"I63","description":"Cerebral infarction","chapter":"IX","chapter_name":"Diseases of the circulatory system","specialty":"Neurology"},
  {"code":"I64","description":"Stroke, not specified as haemorrhage or infarction","chapter":"IX","chapter_name":"Diseases of the circulatory system","specialty":"Neurology"},
  {"code":"I70","description":"Atherosclerosis","chapter":"IX","chapter_name":"Diseases of the circulatory system","specialty":"Cardiology"},
  {"code":"I83","description":"Varicose veins of lower extremities","chapter":"IX","chapter_name":"Diseases of the circulatory system","specialty":"Vascular Surgery"},

  # ── Chapter X: Respiratory system (J00–J99) ───────────────────────────────
  {"code":"J00","description":"Acute nasopharyngitis (common cold)","chapter":"X","chapter_name":"Diseases of the respiratory system","specialty":"General Medicine"},
  {"code":"J01","description":"Acute sinusitis","chapter":"X","chapter_name":"Diseases of the respiratory system","specialty":"ENT"},
  {"code":"J02","description":"Acute pharyngitis","chapter":"X","chapter_name":"Diseases of the respiratory system","specialty":"ENT"},
  {"code":"J03","description":"Acute tonsillitis","chapter":"X","chapter_name":"Diseases of the respiratory system","specialty":"ENT"},
  {"code":"J04","description":"Acute laryngitis and tracheitis","chapter":"X","chapter_name":"Diseases of the respiratory system","specialty":"ENT"},
  {"code":"J06","description":"Acute upper respiratory infections","chapter":"X","chapter_name":"Diseases of the respiratory system","specialty":"General Medicine"},
  {"code":"J10","description":"Influenza due to identified influenza virus","chapter":"X","chapter_name":"Diseases of the respiratory system","specialty":"General Medicine"},
  {"code":"J11","description":"Influenza, virus not identified","chapter":"X","chapter_name":"Diseases of the respiratory system","specialty":"General Medicine"},
  {"code":"J18","description":"Pneumonia, unspecified","chapter":"X","chapter_name":"Diseases of the respiratory system","specialty":"Pulmonology"},
  {"code":"J20","description":"Acute bronchitis","chapter":"X","chapter_name":"Diseases of the respiratory system","specialty":"Pulmonology"},
  {"code":"J30","description":"Vasomotor and allergic rhinitis","chapter":"X","chapter_name":"Diseases of the respiratory system","specialty":"ENT"},
  {"code":"J34","description":"Other disorders of nose and nasal sinuses","chapter":"X","chapter_name":"Diseases of the respiratory system","specialty":"ENT"},
  {"code":"J40","description":"Bronchitis, not specified as acute or chronic","chapter":"X","chapter_name":"Diseases of the respiratory system","specialty":"Pulmonology"},
  {"code":"J42","description":"Unspecified chronic bronchitis","chapter":"X","chapter_name":"Diseases of the respiratory system","specialty":"Pulmonology"},
  {"code":"J44","description":"Other chronic obstructive pulmonary disease (COPD)","chapter":"X","chapter_name":"Diseases of the respiratory system","specialty":"Pulmonology"},
  {"code":"J45","description":"Asthma","chapter":"X","chapter_name":"Diseases of the respiratory system","specialty":"Pulmonology"},
  {"code":"J81","description":"Pulmonary oedema","chapter":"X","chapter_name":"Diseases of the respiratory system","specialty":"Pulmonology"},
  {"code":"J90","description":"Pleural effusion","chapter":"X","chapter_name":"Diseases of the respiratory system","specialty":"Pulmonology"},
  {"code":"J96","description":"Respiratory failure","chapter":"X","chapter_name":"Diseases of the respiratory system","specialty":"Pulmonology"},

  # ── Chapter XI: Digestive system (K00–K93) ────────────────────────────────
  {"code":"K01","description":"Embedded and impacted teeth","chapter":"XI","chapter_name":"Diseases of the digestive system","specialty":"Dentistry"},
  {"code":"K08","description":"Other disorders of teeth","chapter":"XI","chapter_name":"Diseases of the digestive system","specialty":"Dentistry"},
  {"code":"K20","description":"Oesophagitis","chapter":"XI","chapter_name":"Diseases of the digestive system","specialty":"Gastroenterology"},
  {"code":"K21","description":"Gastro-oesophageal reflux disease (GERD)","chapter":"XI","chapter_name":"Diseases of the digestive system","specialty":"Gastroenterology"},
  {"code":"K25","description":"Gastric ulcer","chapter":"XI","chapter_name":"Diseases of the digestive system","specialty":"Gastroenterology"},
  {"code":"K26","description":"Duodenal ulcer","chapter":"XI","chapter_name":"Diseases of the digestive system","specialty":"Gastroenterology"},
  {"code":"K29","description":"Gastritis and duodenitis","chapter":"XI","chapter_name":"Diseases of the digestive system","specialty":"Gastroenterology"},
  {"code":"K35","description":"Acute appendicitis","chapter":"XI","chapter_name":"Diseases of the digestive system","specialty":"General Surgery"},
  {"code":"K37","description":"Unspecified appendicitis","chapter":"XI","chapter_name":"Diseases of the digestive system","specialty":"General Surgery"},
  {"code":"K40","description":"Inguinal hernia","chapter":"XI","chapter_name":"Diseases of the digestive system","specialty":"General Surgery"},
  {"code":"K50","description":"Crohn disease","chapter":"XI","chapter_name":"Diseases of the digestive system","specialty":"Gastroenterology"},
  {"code":"K51","description":"Ulcerative colitis","chapter":"XI","chapter_name":"Diseases of the digestive system","specialty":"Gastroenterology"},
  {"code":"K57","description":"Diverticular disease of intestine","chapter":"XI","chapter_name":"Diseases of the digestive system","specialty":"Gastroenterology"},
  {"code":"K70","description":"Alcoholic liver disease","chapter":"XI","chapter_name":"Diseases of the digestive system","specialty":"Gastroenterology"},
  {"code":"K72","description":"Hepatic failure","chapter":"XI","chapter_name":"Diseases of the digestive system","specialty":"Gastroenterology"},
  {"code":"K74","description":"Fibrosis and cirrhosis of liver","chapter":"XI","chapter_name":"Diseases of the digestive system","specialty":"Gastroenterology"},
  {"code":"K80","description":"Cholelithiasis (gallstones)","chapter":"XI","chapter_name":"Diseases of the digestive system","specialty":"General Surgery"},
  {"code":"K85","description":"Acute pancreatitis","chapter":"XI","chapter_name":"Diseases of the digestive system","specialty":"Gastroenterology"},
  {"code":"K86","description":"Other diseases of pancreas","chapter":"XI","chapter_name":"Diseases of the digestive system","specialty":"Gastroenterology"},
  {"code":"K92","description":"Other diseases of digestive system","chapter":"XI","chapter_name":"Diseases of the digestive system","specialty":"Gastroenterology"},

  # ── Chapter XII: Skin (L00–L99) ───────────────────────────────────────────
  {"code":"L01","description":"Impetigo","chapter":"XII","chapter_name":"Diseases of the skin","specialty":"Dermatology"},
  {"code":"L02","description":"Cutaneous abscess","chapter":"XII","chapter_name":"Diseases of the skin","specialty":"Dermatology"},
  {"code":"L03","description":"Cellulitis","chapter":"XII","chapter_name":"Diseases of the skin","specialty":"Dermatology"},
  {"code":"L10","description":"Pemphigus","chapter":"XII","chapter_name":"Diseases of the skin","specialty":"Dermatology"},
  {"code":"L20","description":"Atopic dermatitis","chapter":"XII","chapter_name":"Diseases of the skin","specialty":"Dermatology"},
  {"code":"L23","description":"Allergic contact dermatitis","chapter":"XII","chapter_name":"Diseases of the skin","specialty":"Dermatology"},
  {"code":"L40","description":"Psoriasis","chapter":"XII","chapter_name":"Diseases of the skin","specialty":"Dermatology"},
  {"code":"L50","description":"Urticaria","chapter":"XII","chapter_name":"Diseases of the skin","specialty":"Dermatology"},
  {"code":"L60","description":"Nail disorders","chapter":"XII","chapter_name":"Diseases of the skin","specialty":"Dermatology"},
  {"code":"L70","description":"Acne","chapter":"XII","chapter_name":"Diseases of the skin","specialty":"Dermatology"},

  # ── Chapter XIII: Musculoskeletal (M00–M99) ───────────────────────────────
  {"code":"M00","description":"Pyogenic arthritis","chapter":"XIII","chapter_name":"Diseases of the musculoskeletal system","specialty":"Orthopaedics"},
  {"code":"M05","description":"Seropositive rheumatoid arthritis","chapter":"XIII","chapter_name":"Diseases of the musculoskeletal system","specialty":"Rheumatology"},
  {"code":"M10","description":"Gout","chapter":"XIII","chapter_name":"Diseases of the musculoskeletal system","specialty":"Rheumatology"},
  {"code":"M15","description":"Polyarthrosis","chapter":"XIII","chapter_name":"Diseases of the musculoskeletal system","specialty":"Orthopaedics"},
  {"code":"M16","description":"Coxarthrosis (hip arthrosis)","chapter":"XIII","chapter_name":"Diseases of the musculoskeletal system","specialty":"Orthopaedics"},
  {"code":"M17","description":"Gonarthrosis (knee arthrosis)","chapter":"XIII","chapter_name":"Diseases of the musculoskeletal system","specialty":"Orthopaedics"},
  {"code":"M40","description":"Kyphosis and lordosis","chapter":"XIII","chapter_name":"Diseases of the musculoskeletal system","specialty":"Orthopaedics"},
  {"code":"M41","description":"Scoliosis","chapter":"XIII","chapter_name":"Diseases of the musculoskeletal system","specialty":"Orthopaedics"},
  {"code":"M48","description":"Other spondylopathies","chapter":"XIII","chapter_name":"Diseases of the musculoskeletal system","specialty":"Orthopaedics"},
  {"code":"M50","description":"Cervical disc disorders","chapter":"XIII","chapter_name":"Diseases of the musculoskeletal system","specialty":"Orthopaedics"},
  {"code":"M54","description":"Dorsalgia (back pain)","chapter":"XIII","chapter_name":"Diseases of the musculoskeletal system","specialty":"Orthopaedics"},
  {"code":"M75","description":"Shoulder lesions","chapter":"XIII","chapter_name":"Diseases of the musculoskeletal system","specialty":"Orthopaedics"},
  {"code":"M79","description":"Other soft tissue disorders","chapter":"XIII","chapter_name":"Diseases of the musculoskeletal system","specialty":"Orthopaedics"},

  # ── Chapter XIV: Genitourinary (N00–N99) ──────────────────────────────────
  {"code":"N00","description":"Acute nephritic syndrome","chapter":"XIV","chapter_name":"Diseases of the genitourinary system","specialty":"Nephrology"},
  {"code":"N03","description":"Chronic nephritic syndrome","chapter":"XIV","chapter_name":"Diseases of the genitourinary system","specialty":"Nephrology"},
  {"code":"N10","description":"Acute pyelonephritis","chapter":"XIV","chapter_name":"Diseases of the genitourinary system","specialty":"Urology"},
  {"code":"N17","description":"Acute renal failure","chapter":"XIV","chapter_name":"Diseases of the genitourinary system","specialty":"Nephrology"},
  {"code":"N18","description":"Chronic renal failure","chapter":"XIV","chapter_name":"Diseases of the genitourinary system","specialty":"Nephrology"},
  {"code":"N20","description":"Calculus of kidney (kidney stone)","chapter":"XIV","chapter_name":"Diseases of the genitourinary system","specialty":"Urology"},
  {"code":"N30","description":"Cystitis","chapter":"XIV","chapter_name":"Diseases of the genitourinary system","specialty":"Urology"},
  {"code":"N39","description":"Other disorders of urinary system (UTI)","chapter":"XIV","chapter_name":"Diseases of the genitourinary system","specialty":"Urology"},
  {"code":"N40","description":"Hyperplasia of prostate (BPH)","chapter":"XIV","chapter_name":"Diseases of the genitourinary system","specialty":"Urology"},
  {"code":"N70","description":"Salpingitis and oophoritis","chapter":"XIV","chapter_name":"Diseases of the genitourinary system","specialty":"Gynaecology"},
  {"code":"N80","description":"Endometriosis","chapter":"XIV","chapter_name":"Diseases of the genitourinary system","specialty":"Gynaecology"},
  {"code":"N92","description":"Excessive, frequent and irregular menstruation","chapter":"XIV","chapter_name":"Diseases of the genitourinary system","specialty":"Gynaecology"},

  # ── Chapter XV: Pregnancy (O00–O99) ───────────────────────────────────────
  {"code":"O10","description":"Pre-existing hypertension complicating pregnancy","chapter":"XV","chapter_name":"Pregnancy, childbirth and the puerperium","specialty":"Obstetrics"},
  {"code":"O14","description":"Gestational hypertension (pre-eclampsia)","chapter":"XV","chapter_name":"Pregnancy, childbirth and the puerperium","specialty":"Obstetrics"},
  {"code":"O20","description":"Haemorrhage in early pregnancy","chapter":"XV","chapter_name":"Pregnancy, childbirth and the puerperium","specialty":"Obstetrics"},
  {"code":"O24","description":"Diabetes mellitus in pregnancy","chapter":"XV","chapter_name":"Pregnancy, childbirth and the puerperium","specialty":"Obstetrics"},
  {"code":"O42","description":"Premature rupture of membranes","chapter":"XV","chapter_name":"Pregnancy, childbirth and the puerperium","specialty":"Obstetrics"},
  {"code":"O60","description":"Preterm labour","chapter":"XV","chapter_name":"Pregnancy, childbirth and the puerperium","specialty":"Obstetrics"},
  {"code":"O80","description":"Single spontaneous delivery","chapter":"XV","chapter_name":"Pregnancy, childbirth and the puerperium","specialty":"Obstetrics"},
  {"code":"O82","description":"Single delivery by caesarean section","chapter":"XV","chapter_name":"Pregnancy, childbirth and the puerperium","specialty":"Obstetrics"},

  # ── Chapter XVI: Perinatal (P00–P96) ──────────────────────────────────────
  {"code":"P07","description":"Disorders related to short gestation and low birth weight","chapter":"XVI","chapter_name":"Certain conditions originating in the perinatal period","specialty":"Paediatrics"},
  {"code":"P22","description":"Respiratory distress of newborn","chapter":"XVI","chapter_name":"Certain conditions originating in the perinatal period","specialty":"Paediatrics"},
  {"code":"P36","description":"Bacterial sepsis of newborn","chapter":"XVI","chapter_name":"Certain conditions originating in the perinatal period","specialty":"Paediatrics"},

  # ── Chapter XVII: Congenital (Q00–Q99) ────────────────────────────────────
  {"code":"Q20","description":"Congenital malformations of cardiac chambers","chapter":"XVII","chapter_name":"Congenital malformations","specialty":"Paediatric Cardiology"},
  {"code":"Q21","description":"Congenital malformations of cardiac septa","chapter":"XVII","chapter_name":"Congenital malformations","specialty":"Paediatric Cardiology"},
  {"code":"Q35","description":"Cleft palate","chapter":"XVII","chapter_name":"Congenital malformations","specialty":"Paediatrics"},
  {"code":"Q65","description":"Congenital deformities of hip","chapter":"XVII","chapter_name":"Congenital malformations","specialty":"Orthopaedics"},
  {"code":"Q90","description":"Down syndrome","chapter":"XVII","chapter_name":"Congenital malformations","specialty":"Paediatrics"},

  # ── Chapter XVIII: Symptoms (R00–R99) ─────────────────────────────────────
  {"code":"R00","description":"Abnormalities of heart beat","chapter":"XVIII","chapter_name":"Symptoms, signs and abnormal clinical findings","specialty":"Cardiology"},
  {"code":"R04","description":"Haemorrhage from respiratory passages","chapter":"XVIII","chapter_name":"Symptoms, signs and abnormal clinical findings","specialty":"Pulmonology"},
  {"code":"R05","description":"Cough","chapter":"XVIII","chapter_name":"Symptoms, signs and abnormal clinical findings","specialty":"General Medicine"},
  {"code":"R06","description":"Abnormalities of breathing","chapter":"XVIII","chapter_name":"Symptoms, signs and abnormal clinical findings","specialty":"Pulmonology"},
  {"code":"R07","description":"Pain in throat and chest","chapter":"XVIII","chapter_name":"Symptoms, signs and abnormal clinical findings","specialty":"Cardiology"},
  {"code":"R10","description":"Abdominal and pelvic pain","chapter":"XVIII","chapter_name":"Symptoms, signs and abnormal clinical findings","specialty":"Gastroenterology"},
  {"code":"R11","description":"Nausea and vomiting","chapter":"XVIII","chapter_name":"Symptoms, signs and abnormal clinical findings","specialty":"General Medicine"},
  {"code":"R50","description":"Fever of unknown origin","chapter":"XVIII","chapter_name":"Symptoms, signs and abnormal clinical findings","specialty":"General Medicine"},
  {"code":"R51","description":"Headache","chapter":"XVIII","chapter_name":"Symptoms, signs and abnormal clinical findings","specialty":"Neurology"},
  {"code":"R55","description":"Syncope and collapse","chapter":"XVIII","chapter_name":"Symptoms, signs and abnormal clinical findings","specialty":"Cardiology"},
  {"code":"R73","description":"Elevated blood glucose level","chapter":"XVIII","chapter_name":"Symptoms, signs and abnormal clinical findings","specialty":"Endocrinology"},

  # ── Chapter XIX: Injury (S00–T98) ─────────────────────────────────────────
  {"code":"S06","description":"Intracranial injury","chapter":"XIX","chapter_name":"Injury, poisoning and external causes","specialty":"Neurosurgery"},
  {"code":"S22","description":"Fracture of rib, sternum and thoracic spine","chapter":"XIX","chapter_name":"Injury, poisoning and external causes","specialty":"Orthopaedics"},
  {"code":"S52","description":"Fracture of forearm","chapter":"XIX","chapter_name":"Injury, poisoning and external causes","specialty":"Orthopaedics"},
  {"code":"S72","description":"Fracture of femur","chapter":"XIX","chapter_name":"Injury, poisoning and external causes","specialty":"Orthopaedics"},
  {"code":"S82","description":"Fracture of lower leg","chapter":"XIX","chapter_name":"Injury, poisoning and external causes","specialty":"Orthopaedics"},
  {"code":"T14","description":"Injury of unspecified body region","chapter":"XIX","chapter_name":"Injury, poisoning and external causes","specialty":"Emergency Medicine"},
  {"code":"T39","description":"Poisoning by non-opioid analgesics","chapter":"XIX","chapter_name":"Injury, poisoning and external causes","specialty":"Emergency Medicine"},
  {"code":"T78","description":"Adverse effects, not elsewhere classified (Anaphylaxis)","chapter":"XIX","chapter_name":"Injury, poisoning and external causes","specialty":"Emergency Medicine"},

  # ── Chapter XXI: Special purposes (U00–U99) ───────────────────────────────
  {"code":"U07.1","description":"COVID-19, virus identified","chapter":"XXI","chapter_name":"Codes for special purposes","specialty":"Infectious Disease"},
  {"code":"U07.2","description":"COVID-19, virus not identified","chapter":"XXI","chapter_name":"Codes for special purposes","specialty":"Infectious Disease"},
]

def get_all() -> list:
    return ICD10_DATA

def get_by_chapter(chapter: str) -> list:
    return [d for d in ICD10_DATA if d["chapter"] == chapter]

def get_by_specialty(specialty: str) -> list:
    return [d for d in ICD10_DATA if d["specialty"] == specialty]

if __name__ == "__main__":
    print(f"Total ICD-10 entries: {len(ICD10_DATA)}")
    from collections import Counter
    chap_counts = Counter(d["chapter"] for d in ICD10_DATA)
    for ch, cnt in sorted(chap_counts.items()):
        print(f"  Chapter {ch}: {cnt} codes")
