import sys, os, re, subprocess

import os
import re

results = sys.argv[1]
fit_hierarchical = sys.argv[2]

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


subject_list='AA022,AA071,AA111,AA164,AA343,AA363,AA374,AA631,AA703,AB050,AB434,AB546,AB607,AB830,AB903,AD032,AD108,AE085,AF497,AF661,AG134,AH994,AJ027,AJ537,AJ577,AJ702,AJ826,AJ855,AJ975,AK027,AK028,AK303,AL023,AL233,AL627,AL747,AL752,AL808,AL925,an312,AN582,AO072,AO094,AO226,AO525,AO580,AO631,AO679,AP614,AQ340,AQ633,AQ975,AR607,AS038,AS312,AS588,AS599,AS768,AS988,AT122,AT385,AT511,AT719,AU102,AU478,AU569,AU626,AU739,AU798,AV011,AV134,AV143,AV503,AV551,AV683,AV708,AV718,AV958,AW090,AW199,AW442,AW519,AW577,AW743,aw856,AW910,AW950,AX082,AX394,AX490,AX598,AX666,AX964,AY444,AY480,AY649,AY758,AY762,AY841,AY862,AY995,AZ076,AZ175,AZ233,AZ451,AZ532,AZ608,az689,AZ690,AZ781,az790,AZ810,AZ833,AZ843,AZ873,AZ985,BA003,BA042,BA284,BA504,BA548,BA596,BA693,BA935,BA953,BA977,BB146,BB230,BB278,BB328,BB360,BB382,BB383,BB389,BB432,BB473,BB474,bb477,bb478,BB481,BB483,BB488,BB497,BB498,BB508,BB512,BB527,BB544,BB565,BB567,BB571,BB579,BB601,BB625,BB641,BB662,BB669,BB694,BB706,BB728,BB756,BB809,BB818,bb821,BB822,BB845,BB857,BB867,BB898,BB906,BB916,BB920,BB998,BC006,BC027,BC034,BC059,BC083,BC084,BC100,bc196,BC234,BC242,BC245,BC280,BC301,BC312,BC351,BC352,BC380,BC512,BC514,BC543,BC581,BC615,BC632,BC653,BC678,BC726,BC758,BC762,BC771,BC838,BC854,BC903,BC963,BC998,BD021,BD217,BD234,BD270,BD356,BD440,bd464,BD506,BD512,BD730,BD796,BD961,BE109,BE149,BE264,BE273,BE280,BE283,be286,BE350,BE369,BE376,be387,BE424,BE520,BE596,BE672,BE677,BE758,BF040,BF087,BF145,BF223,BF228,BF332,BG691,BG921,BH048,BH100,BH108,BH114,BH220,BH222,BH241,BH806,bi128,BI206,BI287,bi365,bi380,BI602,BI872,BJ024,BJ123,BJ191,BJ216,BJ523,BK050,BK144,BK211,BK413,BK415,BK516,BK526,BK545,BK578,BK620,BK978,BL502,BL641,BL760,BL953,BL970,BL973,BL974,BM050,BM152,BM183,BM242,BM250,BM320,BM336,BM558,BM678,BM732,BM742,BM770,BN061,BN114,BN250,BN251,BN269,BN280,BN291,BN337,BN460,BN494,BN536,BN579,BN811,BN867,BO240,BO269,BO297,BO344,BO399,BO480,BO642,BO719,BO745,BO762,BO822,BO986,BP181,BP185,BP189,BP222,BP305,BP318,BP539,BP708,BP801,BP814,BP835,BP993,BQ080,BQ106,BQ206,BQ211,BQ274,BQ567,BQ682,BQ730,BQ852,BQ949,BR064,BR185,BR198,BR230,BR511,BR518,BR567,BR582,BR715,BR717,BR780,BR809,BR832,BR910,BR911,BS092,BS162,BS198,BS266,BS286,BS326,BS445,BS548,BS615,BS634,BS675,BS676,BS693,BS796,BS992,BT265,BT288,BT327,BT330,BT475,BT499,BT558,BT583,BT638,BT779,BT792,BT800,BU313,BU445,BU562,BU819,BV027,BV076,BV318,XX124,XX614'
#subject_list = 'AB050,AG134,AO679,BB483,BC903'

model1 = 'beta'
model2 = 'alpha,outcome_sensitivity'
model3 = 'alpha,outcome_sensitivity,zeta'
model4 = 'alpha,outcome_sensitivity,zeta,beta'
model5 = 'alpha,outcome_sensitivity,zeta,beta,pi'
model6 = 'alpha,outcome_sensitivity,zeta,beta,pi_win,pi_loss'
model7 = 'alpha,rs,la,zeta,beta,pi_win,pi_loss'
model8 = 'alpha_win,alpha_loss,rs,la,zeta,beta,pi_win,pi_loss'

model_list = [model1,model2,model3,model4,model5,model6,model7,model8]

for field in model_list:
    combined_results_dir = results + '/' + field
    if not os.path.exists(f"{combined_results_dir}/logs"):
        os.makedirs(f"{combined_results_dir}/logs")
        print(f"Created results-logs directory {combined_results_dir}/logs")
    
    ssub_path = '/media/labs/rsmith/lab-members/cgoldman/go_no_go/DDM/RL_DDM_Millner/RL_DDM_CMG-hierarchichal/run_RL_DDM_hierarchichal.ssub'
    stdout_name = f"{combined_results_dir}/logs/hierarchichal-%J.stdout"
    stderr_name = f"{combined_results_dir}/logs/hierarchichal-%J.stderr"

    jobname = f'GNG-{field}'
    os.system(f"sbatch -J {jobname} -o {stdout_name} -e {stderr_name} {ssub_path} {subject_list} {combined_results_dir} {fit_hierarchical} {field}")
    print(f"SUBMITTED JOB [{jobname}]")




# ###python3 run_RL_DDM_hierarchichal.py /media/labs/rsmith/lab-members/cgoldman/go_no_go/DDM/RL_DDM_Millner/RL_DDM_fits/test 1
# joblist | grep GNG | grep -Po 13..... | xargs -n1 scancel