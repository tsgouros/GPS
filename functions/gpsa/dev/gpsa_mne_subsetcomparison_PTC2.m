function varargout = gpsa_mne_subsetcomparison_PTC2(varargin)
% Assembles Granger data for the subset
%
% Author: A. Conrad Nied
%
% Changelog:
% 2012.10.17 - Created for gpsa_mne_subsetcomparison_PTC3
% 2012.11.12 - Adapted for PTC2
%                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           

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
    
    for i_subset = 1:9%length(study.subsets);
        subset = gpsa_parameter(study.subsets{i_subset});
        
        datafile = sprintf('%s/results/%s.mat', study.granger.dir, subset.name);
        if(~strcmp(subset.name, subset.cortex.roiset))
            datafile = sprintf('%s/results/%s_%s.mat', study.granger.dir, subset.name, subset.cortex.roiset);
        end
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
    set(1, 'Color', 'w');
    
    msamples = data.samples * 1000;
    
    % All areas per each subset
    for i_subset = 1:7
        subset = study.subsets{i_subset};
        h = plot(msamples, data.L_MTG_1.(subset) * 10e9, 'g',...
            msamples, data.L_STG_1.(subset) * 10e9, 'b',...
            msamples, data.L_SMG_1.(subset) * 10e9, 'm');
        set(h, 'LineWidth', 2);
        set(gca, 'FontSize', 16);
        ylabel('Cortical Activity (nAm)');
        ylim([0 4]);
        xlabel('Time (ms)');
        xlim([min(msamples), max(msamples)])
        legend('L-SMG_1', 'L-STG_1', 'L-SMG_1', 'Location', 'NorthEast');
        filename = sprintf('%s/%s_Primaryareas_%s_act.png', folder, study.name, subset);
%         saveas(gcf, filename);
frame = getframe(gcf);
imwrite(frame.cdata, filename, 'png');
    end % for each subset
    
    figure(1)
    pairs = {{'Endpoint_PTBcons', 'Endpoint_PTBincons'},...
        {'Endpoint_PTBcons_Sibcons', 'Endpoint_PTBcons_Sibincons'},...
        {'Endpoint_PTBincons_Sibcons', 'Endpoint_PTBincons_Sibincons'},...
        {'Endpoint_PTBcons_Sibcons', 'Endpoint_PTBincons_Sibcons'},...
        {'Endpoint_PTBcons_Sibincons', 'Endpoint_PTBincons_Sibincons'}};
    pairslegend = {{'PTBcons', 'PTBincons'},...
        {'Sibcons', 'Sibincons'},...
        {'Sibcons', 'Sibincons'},...
        {'PTBcons', 'PTBincons'},...
        {'PTBcons', 'PTBincons'}};
    pairs_short = {'E-PTBcvi', 'E-PTBc-Sibcvi', 'E-PTBi-Sibcvi', 'E-PTBcvi-Sibc', 'E-PTBcvi-Sibi'};
        
    for i_pair = 1:length(pairs)
        pair = pairs{i_pair};
    h = plot(msamples, data.L_MTG_1.(pair{1}) * 10e9, 'b',...
            msamples, data.L_STG_1.(pair{1}) * 10e9, 'r');
        set(h, 'LineWidth', 2);
        set(gca, 'FontSize', 16);
        ylabel('Cortical Activity (nAm)');
        ylim([0 4]);
        xlabel('Time (ms)');
        xlim([min(msamples), max(msamples)])
        legend(pairslegend{i_pair}, 'Location', 'NorthEast');
        filename = sprintf('%s/%s_LSTG_%s_act.png', folder, study.name, pairs_short{i_pair});
        frame = getframe(gcf);
        imwrite(frame.cdata, filename, 'png');
    end % for each pair
    
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