function fit_simfit_comparrison
warning('off', 'MATLAB:integral:MaxIntervalCountReached');

for j=1:27
    str_j = num2str(j);
    try
        load(['L:\rsmith\lab-members\cgoldman\go_no_go\DDM\RL_DDM_Millner\RL_DDM_fits\fit_simfit_405_pts_small_T\model' str_j '\Simfit_RLDDM_fit_hierarchically_gcm.mat']);
    catch e
        fprintf('Couldnt load in go choices\n\n');
        continue;
    end
    try
        load(['L:\rsmith\lab-members\cgoldman\go_no_go\DDM\RL_DDM_Millner\RL_DDM_fits\fit_simfit_405_pts_small_T\model' str_j '\GCM_simmed.mat']);
    catch e
        fprintf('Couldnt load in simmed go choices\n\n');
        continue;
    end

    k = size(simfit_gcm,1);
    num_go_choices = zeros(k, 1);
    num_simmed_go_choices = zeros(k, 1);

    for i = 1:k
        choices = GCM{i, 1}.U.c;
        num_go_choices(i) = sum(choices == 1);

        simmed_choices = simfit_gcm{i,1}.U.c;
        num_simmed_go_choices(i) = sum(simmed_choices == 1);
    end
    % Create a table with subjects' indices and counts
    subjectIndices = (1:k)';
    resultsTable = table(subjectIndices, num_go_choices,num_simmed_go_choices, 'VariableNames', {'subject', 'num_go_choices','num_simmed_go_choices'});

    mean_go_choices = mean(resultsTable.num_go_choices);
    mean_simmed_go_choices = mean(resultsTable.num_simmed_go_choices);
    fprintf('Model %.f Actual Avg Num Go Choices: %.2f\n',j,mean_go_choices);
    fprintf('Simfitted Model %.f  Num Go Choices: %.2f\n',j,mean_simmed_go_choices);
    fprintf('Correlation between actual/simfitted go choices: %.2f\n\n',corr(num_go_choices, num_simmed_go_choices));


end