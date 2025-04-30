% Figure out which models fits are finished in identifiability analysis
% Define the base directory
base_dir = 'L:\rsmith\lab-members\cgoldman\go_no_go\DDM\RL_DDM_Millner\RL_DDM_fits\model_identifiability_hierarchical';

% Get list of all items in the base directory
folders = dir(base_dir);
folders = folders([folders.isdir] & ~ismember({folders.name}, {'.', '..'}));

% Initialize list for missing subfolders
finished_fit_folders = {};

% Loop through each subfolder
for i = 1:length(folders)
    folder_name = folders(i).name;
    full_path = fullfile(base_dir, folder_name);
    
    % Check for existence of both .mat files
    fit_file = fullfile(full_path, 'Simfit_RLDDM_fit_hierarchically_gcm.mat');
    results_file = fullfile(full_path, 'Simfit_RLDDM_fit_hierarchically_results.mat');
    
    if isfile(fit_file) && isfile(results_file)
        finished_fit_folders{end+1} = folder_name; %#ok<SAGROW>
    end
end

% Display the missing folders
disp('Subfolders containing required .mat files:');
disp(finished_fit_folders);
fprintf('%s\n', finished_fit_folders{:});
