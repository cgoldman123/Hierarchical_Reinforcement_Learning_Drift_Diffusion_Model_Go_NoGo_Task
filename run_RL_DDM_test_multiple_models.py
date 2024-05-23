import sys, os, re, subprocess

import os
import re

results = sys.argv[1]
fit_hierarchical = sys.argv[2]
use_parfor = sys.argv[3]
use_ddm = sys.argv[4]

if not os.path.exists(results):
    os.makedirs(results)
    print(f"Created results directory {results}")

# Get a list of subject names directly using list comprehension
#input_directory = '/media/labs/rsmith/lab-members/cgoldman/go_no_go/DDM/processed_behavioral_files_DDM'
#pattern = re.compile(r'(.{5})_processed_behavioral_file')
#subject_list = [pattern.search(filename).group(1)
#                 for filename in os.listdir(input_directory)
#                 if filename.endswith('.csv') and pattern.search(filename)]
#subject_list = ','.join(subject_list)


# load in subjects who both didn't do the same thing for >144 trials and had accuracy >55%
#subject_list='AA022,AA071,AA343,AA374,AB050,AB434,AB546,AB830,AB903,AD108,AE085,AF661,AG134,AH994,AJ027,AJ537,AJ577,AJ702,AJ826,AJ855,AK027,AK028,AK303,AL233,AL627,AL747,AL752,AL925,AN312,AN382,AN582,AO226,AO580,AO679,AP614,AQ633,AQ975,AR607,AS038,AS116,AS312,AS588,AS768,AS988,AT122,AT719,AT923,AU067,AU102,AU569,AU626,AU739,AU798,AV011,AV134,AV143,AV503,AV551,AV683,AV708,AV828,AV958,AW090,AW199,AW442,AW743,AW856,AW910,AW950,AX082,AX394,AX490,AX598,AX666,AX683,AY480,AY649,AY762,AY826,AY841,AY862,AY995,AZ076,AZ175,AZ233,AZ532,AZ608,AZ689,AZ690,AZ781,AZ790,AZ810,AZ833,AZ843,AZ873,BA003,BA042,BA284,BA504,BA548,BA596,BA693,BA953,BB146,BB223,BB382,BB383,BB389,BB474,BB477,BB478,BB481,BB483,BB497,BB498,BB512,BB527,BB544,BB567,BB571,BB641,BB662,BB669,BB694,BB706,BB728,BB756,BB809,BB818,BB845,BB857,BB867,BB898,BB906,BB916,BB998,BC006,BC027,BC034,BC044,BC058,BC059,BC083,BC084,BC097,BC100,BC181,BC234,BC242,BC301,BC312,BC351,BC352,BC367,BC378,BC380,BC496,BC512,BC514,BC543,BC581,BC615,BC632,BC726,BC762,BC771,BC838,BC854,BC963,BC998,BD021,BD205,BD217,BD270,BD331,BD356,BD409,BD464,BD506,BD730,BD793,BD796,BE109,BE264,BE273,BE280,BE283,BE286,BE376,BE387,BE424,BE520,BE596,BE672,BE677,BE758,BE999,BF040,BF087,BF145,BF228,BF332,BG691,BG921,BH048,BH100,BH108,BH114,BH210,BH222,BH254,BH806,BI206,BI287,BI360,BI365,BI380,BI602,BI872,BJ123,BJ191,BJ523,BK144,BK413,BK415,BK526,BK545,BK578,BK620,BK978,BL502,BL641,BL760,BL953,BL970,BL973,BM050,BM152,BM242,BM250,BM320,BM336,BM558,BM667,BM678,BM732,BM742,BM770,BN061,BN114,BN250,BN251,BN280,BN291,BN337,BN494,BN811,BO240,BO269,BO297,BO344,BO480,BO642,BO719,BO745,BO762,BO822,BP181,BP185,BP222,BP305,BP318,BP708,BP801,BP993,BQ080,BQ106,BQ206,BQ274,BQ852,BQ949,BR064,BR185,BR198,BR230,BR511,BR518,BR715,BR717,BR780,BR809,BR832,BR911,BS092,BS162,BS198,BS445,BS548,BS634,BS675,BS676,BS693,BS796,BS992,BT288,BT327,BT330,BT475,BT583,BT638,BT779,BT792,BT800,BU313,BU445,BU819,BV027,BV318,XX124,XX614';

# load in subjects who both didn't do the same thing for >144 trials 
subject_list = 'AA022,AA071,AA111,AA164,AA343,AA363,AA374,AA631,AA703,AB050,AB434,AB546,AB607,AB830,AB903,AD032,AD041,AD108,AE085,AF497,AF661,AG134,AH994,AJ027,AJ537,AJ577,AJ702,AJ826,AJ855,AJ975,AK027,AK028,AK303,AK570,AL023,AL233,AL627,AL747,AL752,AL808,AL925,AN312,AN382,AN582,AO072,AO094,AO226,AO525,AO580,AO631,AO679,AP614,AQ340,AQ633,AQ975,AR607,AS038,AS116,AS312,AS588,AS599,AS768,AS988,AT122,AT385,AT511,AT719,AT923,AU067,AU102,AU478,AU569,AU626,AU739,AU798,AV011,AV134,AV143,AV503,AV551,AV683,AV708,AV718,AV828,AV958,AW090,AW199,AW442,AW519,AW577,AW743,AW856,AW910,AW938,AW950,AX082,AX394,AX490,AX598,AX666,AX683,AX964,AY444,AY480,AY649,AY758,AY762,AY826,AY841,AY862,AY995,AZ076,AZ175,AZ233,AZ451,AZ532,AZ608,AZ689,AZ690,AZ781,AZ790,AZ810,AZ833,AZ843,AZ873,AZ985,BA003,BA042,BA284,BA504,BA548,BA596,BA693,BA935,BA953,BA977,BB146,BB223,BB230,BB278,BB328,BB360,BB382,BB383,BB389,BB432,BB473,BB474,BB477,BB478,BB481,BB483,BB488,BB497,BB498,BB508,BB512,BB523,BB527,BB544,BB565,BB567,BB571,BB579,BB601,BB625,BB641,BB662,BB669,BB694,BB706,BB728,BB756,BB809,BB818,BB821,BB822,BB845,BB857,BB867,BB898,BB906,BB916,BB920,BB998,BC006,BC027,BC034,BC044,BC058,BC059,BC083,BC084,BC097,BC100,BC181,BC196,BC234,BC242,BC245,BC280,BC301,BC312,BC351,BC352,BC367,BC378,BC380,BC496,BC512,BC514,BC543,BC581,BC615,BC632,BC653,BC678,BC726,BC758,BC762,BC771,BC838,BC854,BC903,BC963,BC998,BD021,BD205,BD217,BD234,BD270,BD331,BD356,BD409,BD440,BD464,BD506,BD512,BD730,BD793,BD796,BD961,BE109,BE149,BE264,BE273,BE280,BE283,BE286,BE350,BE369,BE376,BE387,BE424,BE520,BE596,BE672,BE677,BE758,BE999,BF040,BF087,BF145,BF223,BF228,BF332,BG691,BG921,BH048,BH100,BH108,BH114,BH210,BH220,BH222,BH241,BH254,BH806,BI128,BI206,BI287,BI360,BI365,BI380,BI602,BI872,BJ024,BJ123,BJ191,BJ216,BJ523,BK050,BK144,BK211,BK413,BK415,BK516,BK526,BK545,BK578,BK620,BK978,BL502,BL641,BL760,BL953,BL970,BL973,BL974,BM050,BM152,BM183,BM242,BM250,BM320,BM336,BM558,BM667,BM678,BM732,BM742,BM770,BN061,BN114,BN250,BN251,BN269,BN280,BN291,BN337,BN460,BN494,BN536,BN579,BN811,BN867,BO240,BO269,BO297,BO344,BO399,BO480,BO642,BO719,BO745,BO762,BO822,BO986,BP181,BP185,BP189,BP222,BP305,BP318,BP539,BP708,BP801,BP814,BP835,BP993,BQ080,BQ106,BQ206,BQ211,BQ274,BQ567,BQ682,BQ730,BQ852,BQ949,BR064,BR185,BR198,BR230,BR511,BR518,BR567,BR582,BR715,BR717,BR780,BR809,BR832,BR910,BR911,BS092,BS162,BS198,BS266,BS286,BS326,BS445,BS548,BS615,BS634,BS675,BS676,BS693,BS796,BS992,BT265,BT288,BT327,BT330,BT475,BT499,BT558,BT583,BT638,BT779,BT792,BT800,BU313,BU445,BU562,BU819,BV027,BV076,BV318,XX124,XX614'


models = [
    {'field': 'T,alpha,outcome_sensitivity,beta,pi,w,a', 'drift_mapping': 'qval,pav,go', 'bias_mapping': '', 'thresh_mapping': ''},
    {'field': 'T,alpha,outcome_sensitivity,beta,pi,v,a', 'drift_mapping': '', 'bias_mapping': 'qval,pav,go', 'thresh_mapping': ''},
    {'field': 'T,alpha,outcome_sensitivity,beta,pi,v,w', 'drift_mapping': '', 'bias_mapping': '', 'thresh_mapping': 'qval,pav,go'},
    {'field': 'T,alpha,outcome_sensitivity,beta,pi,a', 'drift_mapping': 'qval,pav,go', 'bias_mapping': 'qval,pav,go', 'thresh_mapping': ''},
    {'field': 'T,alpha,outcome_sensitivity,beta,pi,w', 'drift_mapping': 'qval,pav,go', 'bias_mapping': '', 'thresh_mapping': 'qval,pav,go'},
    {'field': 'T,alpha,outcome_sensitivity,beta,pi,v', 'drift_mapping': '', 'bias_mapping': 'qval,pav,go', 'thresh_mapping': 'qval,pav,go'},
    {'field': 'T,alpha,outcome_sensitivity,beta,pi', 'drift_mapping': 'qval', 'bias_mapping': 'pav', 'thresh_mapping': 'go'},
    {'field': 'T,alpha,outcome_sensitivity,beta,pi', 'drift_mapping': 'go', 'bias_mapping': 'pav', 'thresh_mapping': 'qval'},
    {'field': 'T,alpha,outcome_sensitivity,beta,pi', 'drift_mapping': 'pav', 'bias_mapping': 'qval', 'thresh_mapping': 'go'},
    {'field': 'T,alpha,outcome_sensitivity,beta,pi', 'drift_mapping': 'go', 'bias_mapping': 'qval', 'thresh_mapping': 'pav'},
    {'field': 'T,alpha,outcome_sensitivity,beta,pi', 'drift_mapping': 'qval', 'bias_mapping': 'go', 'thresh_mapping': 'pav'},
    {'field': 'T,alpha,outcome_sensitivity,beta,pi', 'drift_mapping': 'pav', 'bias_mapping': 'go', 'thresh_mapping': 'qval'},
    {'field': 'T,alpha,outcome_sensitivity,beta,pi,w', 'drift_mapping': 'pav,go', 'bias_mapping': '', 'thresh_mapping': 'qval'},
    {'field': 'T,alpha,outcome_sensitivity,beta,pi,a', 'drift_mapping': 'pav,go', 'bias_mapping': 'qval', 'thresh_mapping': ''},
    {'field': 'T,alpha,outcome_sensitivity,beta,pi,w', 'drift_mapping': 'qval,go', 'bias_mapping': '', 'thresh_mapping': 'pav'},
    {'field': 'T,alpha,outcome_sensitivity,beta,pi,a', 'drift_mapping': 'qval,go', 'bias_mapping': 'pav', 'thresh_mapping': ''},
    {'field': 'T,alpha,outcome_sensitivity,beta,pi,w', 'drift_mapping': 'pav,qval', 'bias_mapping': '', 'thresh_mapping': 'go'},
    {'field': 'T,alpha,outcome_sensitivity,beta,pi,a', 'drift_mapping': 'pav,qval', 'bias_mapping': 'go', 'thresh_mapping': ''},
    {'field': 'T,alpha,outcome_sensitivity,beta,pi,v', 'drift_mapping': '', 'bias_mapping': 'pav,go', 'thresh_mapping': 'qval'},
    {'field': 'T,alpha,outcome_sensitivity,beta,pi,a', 'drift_mapping': 'qval', 'bias_mapping': 'pav,go', 'thresh_mapping': ''},
    {'field': 'T,alpha,outcome_sensitivity,beta,pi,v', 'drift_mapping': '', 'bias_mapping': 'qval,go', 'thresh_mapping': 'pav'},
    {'field': 'T,alpha,outcome_sensitivity,beta,pi,a', 'drift_mapping': 'pav', 'bias_mapping': 'qval,go', 'thresh_mapping': ''},
    {'field': 'T,alpha,outcome_sensitivity,beta,pi,v', 'drift_mapping': '', 'bias_mapping': 'pav,qval','thresh_mapping': 'go'},
    {'field': 'T,alpha,outcome_sensitivity,beta,pi,a', 'drift_mapping': 'go', 'bias_mapping': 'pav,qval', 'thresh_mapping': ''},
    {'field': 'T,alpha,outcome_sensitivity,beta,pi,v', 'drift_mapping': '', 'bias_mapping': 'qval', 'thresh_mapping': 'pav,go'},
    {'field': 'T,alpha,outcome_sensitivity,beta,pi,w', 'drift_mapping': 'qval', 'bias_mapping': '', 'thresh_mapping': 'pav,go'},
    {'field': 'T,alpha,outcome_sensitivity,beta,pi,v', 'drift_mapping': '', 'bias_mapping': 'pav', 'thresh_mapping': 'qval,go'},
    {'field': 'T,alpha,outcome_sensitivity,beta,pi,w', 'drift_mapping': 'pav', 'bias_mapping': '', 'thresh_mapping': 'qval,go'},
    {'field': 'T,alpha,outcome_sensitivity,beta,pi,v', 'drift_mapping': '', 'bias_mapping': 'go', 'thresh_mapping': 'pav,qval'},
    {'field': 'T,alpha,outcome_sensitivity,beta,pi,w', 'drift_mapping': 'go', 'bias_mapping': '', 'thresh_mapping': 'pav,qval'}
]


for index, model in enumerate(models, start=1):
    if index < 26:
        continue
    combined_results_dir = os.path.join(results, f"model{index}")
    drift_mapping = model['drift_mapping']
    bias_mapping = model['bias_mapping']
    thresh_mapping = model['thresh_mapping']
    field = model['field']

    simfit_drift_mapping = drift_mapping
    simfit_bias_mapping = bias_mapping
    simfit_thresh_mapping = thresh_mapping
    simfit_field = field

    if not os.path.exists(f"{combined_results_dir}/logs"):
        os.makedirs(f"{combined_results_dir}/logs")
        print(f"Created results-logs directory {combined_results_dir}/logs")
    
    ssub_path = '/media/labs/rsmith/lab-members/cgoldman/go_no_go/DDM/RL_DDM_Millner/RL_DDM_CMG-hierarchichal/run_RL_DDM_test_multiple_models.ssub'
    stdout_name = f"{combined_results_dir}/logs/hierarchichal-%J.stdout"
    stderr_name = f"{combined_results_dir}/logs/hierarchichal-%J.stderr"

    jobname = f'GNG-Model-{index}'
    os.system(f"sbatch -J {jobname} -o {stdout_name} -e {stderr_name} {ssub_path} \"{subject_list}\" \"{combined_results_dir}\" \"{fit_hierarchical}\" \"{field}\" \"{drift_mapping}\" \"{bias_mapping}\" \"{thresh_mapping}\" \"{simfit_field}\" \"{simfit_drift_mapping}\" \"{simfit_bias_mapping}\" \"{simfit_thresh_mapping}\" \"{use_parfor}\" \"{use_ddm}\"")
    #os.system(f"sbatch -J {jobname} -o {stdout_name} -e {stderr_name} {ssub_path} {subject_list} {combined_results_dir} {fit_hierarchical} {field} {drift_mapping} {bias_mapping} {thresh_mapping} {use_parfor} {use_ddm}")

    print(f"SUBMITTED JOB [{jobname}]")
    

 
    




# ###python3 run_RL_DDM_test_multiple_models.py /media/labs/rsmith/lab-members/cgoldman/go_no_go/DDM/RL_DDM_Millner/RL_DDM_fits/simfit_winning_model_nonhierarchical 1 1 1
# joblist | grep GNG | grep -Po 13..... | xargs -n1 scancel