function varargout = gpsa_mne_subsetcomparison_PTC3(varargin)
% Assembles Granger data for the subset
%
% Author: A. Conrad Nied
%
% Changelog:
% 2012.10.17 - Created
%% Input

[state, operation] = gpsa_inputs(varargin);

%% Prepare a report on the type or progress of the data

if(~isempty(strfind(operation, 't')))
    report.spec_subj = 0; % Subject specific?
    report.spec_subs = 0; % Subset specific?
end

%% Execute the process

if(~isempty(strfind(operation, 'c')))
    
    study = gpsa_parameter(state.study);
    state.function = 'gpsa_mne_subsetcomparison_PTC3';
    tbegin = tic;
    
    %% Create the file with the collections of all of the activation
    
    data = [];
    
    for i_subset = 1:length(study.subsets);
        subset = gpsa_parameter(study.subsets{i_subset});
        
        datafile = sprintf('%s/results/%s.mat', study.granger.dir, subset.name);
        if(exist(datafile, 'file'))
            subsdata = load(datafile);
            
            for i_ROI = 1:length(subsdata.rois)
                roi = subsdata.rois(i_ROI);
                
                if(sum(strcmp({'STG', 'SMG', 'MTG'}, roi.area)))
                    data.(roi.name).(subset.name) = squeeze(mean(subsdata.data(1, i_ROI, :), 1));
                end % If this is a phonetically interesting ROI
            end % for each ROI
        end % if the file exists
    end % for each subset
    
    % Get other information
    data.samples = subsdata.sample_times;
    
    % Save
    folder = sprintf('%s/results/Activity', study.granger.dir);
    if(~exist(folder, 'dir')); mkdir(folder); end
    
    filename = sprintf('%s/data.mat', folder);
    save(filename, '-struct', 'data');
    
    %% Create images based on specific pairings
    
    figure(1)
    clf
    
    msamples = data.samples*1000;
    
    % AW AD AP, special areas
    h = plot(msamples, data.R_STG_1.AW_AD_AP*10e9, 'm',...
        msamples, data.R_STG_2.AW_AD_AP*10e9, 'r',...
        msamples, data.L_MTG_1.AW_AD_AP*10e9, 'y',...
        msamples, data.L_SMG_1.AW_AD_AP*10e9, 'g',...
        msamples, data.L_SMG_2.AW_AD_AP*10e9, 'c',...
        msamples, data.L_SMG_3.AW_AD_AP*10e9, 'b');
    set(h, 'LineWidth', 2);
    set(gca, 'FontSize', 16);
    ylabel('Cortical Activity (nAm)');
    ylim([0 4]);
    xlabel('Time (ms)');
    xlim([min(msamples), max(msamples)])
    legend('R-STG_1', 'R-STG_2', 'L-MTG_1', 'L-SMG_1', 'L-SMG_2', 'L-SMG_3', 'Location', 'NorthEast');
    filename = sprintf('%s/%s_Primaryareas_Allstim_act.png', folder, study.name);
    saveas(gcf, filename);
    
    % RW HP v LP
    h = plot(msamples, data.R_STG_1.RW_AD_HP*10e9, 'r',...
        msamples, data.R_STG_1.RW_AD_LP*10e9, 'b');
    set(h, 'LineWidth', 2);
    set(gca, 'FontSize', 16);
    ylabel('Cortical Activity (nAm)');
    ylim([0 4]);
    xlabel('Time (ms)');
    xlim([min(msamples), max(msamples)])
    legend('High Probability','Low Probability', 'Location', 'NorthEast');
    filename = sprintf('%s/%s_R_STG_1_HPvLP_RW_act.png', folder, study.name);
    saveas(gcf, filename);
    
    % RW HD v LD
    h = plot(msamples, data.R_STG_1.RW_HD_AP*10e9, 'r',...
        msamples, data.R_STG_1.RW_LD_AP*10e9, 'b');
    set(h, 'LineWidth', 2);
    set(gca, 'FontSize', 16);
    ylabel('Cortical Activity (nAm)');
    ylim([0 4]);
    xlabel('Time (ms)');
    xlim([min(msamples), max(msamples)])
    legend('High Density','Low Density', 'Location', 'NorthEast');
    filename = sprintf('%s/%s_R_STG_1_HDvLD_RW_act.png', folder, study.name);
    saveas(gcf, filename);
    
    % NW HP v LP
    h = plot(msamples, data.R_STG_1.NW_AD_HP*10e9, 'r',...
        msamples, data.R_STG_1.NW_AD_LP*10e9, 'b');
    set(h, 'LineWidth', 2);
    set(gca, 'FontSize', 16);
    ylabel('Cortical Activity (nAm)');
    ylim([0 4]);
    xlabel('Time (ms)');
    xlim([min(msamples), max(msamples)])
    legend('High Probability','Low Probability', 'Location', 'NorthEast');
    filename = sprintf('%s/%s_R_STG_1_HPvLP_NW_act.png', folder, study.name);
    saveas(gcf, filename);
    
    % NW HD v LD
    h = plot(msamples, data.R_STG_1.NW_HD_AP*10e9, 'r',...
        msamples, data.R_STG_1.NW_LD_AP*10e9, 'b');
    set(h, 'LineWidth', 2);
    set(gca, 'FontSize', 16);
    ylabel('Cortical Activity (nAm)');
    ylim([0 4]);
    xlabel('Time (ms)');
    xlim([min(msamples), max(msamples)])
    legend('High Density','Low Density', 'Location', 'NorthEast');
    filename = sprintf('%s/%s_R_STG_1_HDvLD_NW_act.png', folder, study.name);
    saveas(gcf, filename);
    
    % Record the process
    gpsa_log(state, toc(tbegin));
    
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    study = gpsa_parameter(state.study);
    if(~isempty(study))
        % Predecessor: granger_consolidate
        filespec = sprintf('%s/input/*.mat', study.granger.dir);
        report.ready = length(dir(filespec)) >= 2;
        folder = sprintf('%s/results/Activity', study.granger.dir);
        report.progress = length(dir([folder '/*.png'])) >= 1;
        report.finished = 0;
    else
        report.ready = 0;
        report.progress = 0;
        report.finished = 0;
    end
end

%% Prepare the report and output

if(nargout == 1 && exist('report', 'var')); 
    varargout{1} = report;
end

end % function