function data = load_gonogo_data(fileName)
    
    % Load data from Go/NoGo task.
    %
    % USAGE: data = load_gonogo_data
    %
    % OUTPUTS:
    %   data - [S x 1] structure, where S is the number of subjects, with the following fields:
    %           .c - [N x 1] choices
    %           .r - [N x 1] rewards
    %           .s - [N x 1] states
    %           .go - [N x 1] go trial indicator (1=Go, 0=NoGo)
    %           .rt - [N x 1] response times
    %           .C - number of choice options
    %           .N - number of trials
    
   % D = csvread(fileName,1);
     D = readtable(fileName);

    % add columns that are not currently there
    D.subj_idx = ones(height(D), 1);
    if iscell(D.response_time)
        % Convert to double, 'NA' becomes NaN
        D.response_time = cellfun(@(x) str2double(x), D.response_time, 'UniformOutput', true);
    end
    D.rt = D.response_time;
    D.c = double(~isnan(D.rt));
    D.r = D.result;
    
    
    subs = unique(D.subj_idx);      % subjects
    for i = 1:size(subs,1)
        subset = D(D.subj_idx == subs(i), :);
        data(i).trial_type = subset.trial_type;
        data(i).c = subset.c;
        data(i).r = subset.r;
        data(i).rt = subset.rt;
%         data(i).C = 2;
        data(i).N = height(subset);
    end