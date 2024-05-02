function check_sims
    DCM.field = {'T','alpha','outcome_sensitivity','beta','pi','w','a'};
    DCM.ddm_mapping.drift = {'qval','pav','go'};
    DCM.ddm_mapping.thresh = {};
    DCM.ddm_mapping.bias = {};
    estimation_prior.rs = 1;
    estimation_prior.la = 1;
    estimation_prior.outcome_sensitivity = 1;
    estimation_prior.alpha_win = .5;
    estimation_prior.alpha_loss = .5;
    estimation_prior.alpha = .5;
    estimation_prior.beta = 0;
    estimation_prior.zeta = .2;
    estimation_prior.pi_win = 0;
    estimation_prior.pi_loss = 0;
    estimation_prior.pi = 0;
    estimation_prior.T = .25;
    estimation_prior.a = 2;
    estimation_prior.w = .5;
    estimation_prior.v = 0;
    estimation_prior.contaminant_prob = .10;
    DCM.MDP = estimation_prior;
    DCM.use_ddm = 1;
    DCM.fit_hierarchically = 1;
    DCM.use_parfor = 0;
    DCM.Y = [];
    
    
    % get AB434's game
    filePath = strcat('L:/rsmith/lab-members/cgoldman/go_no_go/DDM/processed_behavioral_files_DDM/');
    fileName = strcat("AB434_processed_behavioral_file.csv");
    fullPath = strcat(filePath,fileName);
    data = load_gonogo_data(fullPath);
    data.subject = "AB434";    
    GCM{1,1} = DCM;
    GCM{1,1}.U = data;
    GCM{1,1}.subject = "test_sim";
    GCM{1,1}.U.keep_trial = ones(1,160);

    GCM = simulate_gonogo(GCM);
    
    num_go = sum(GCM{:}.U.c);
    percentage_go_choices = num_go/160;
    fprintf("Percentage Go Choices: %.2f\n",percentage_go_choices);
    histogram(GCM{:}.U.rt,20);
end