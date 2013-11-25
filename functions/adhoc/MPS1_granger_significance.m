function MPS1_granger_significance()
% Calculate granger for a condition
%
% Author: Ricky Sachdeva, Conrad Nied, Reid Vancelette
% Input: the GPS variables structure
% Output: nothing (written to files)
%
% Date Created: 2011.04.30
% Last Modified: 2012.12.05
% 2012.11.19: Code looked over for MVS1
%
% Modeled after Sato et al., 2009

% function [signif_conn, alpha_values, total_control_granger, bstrap_time] = GPS_9_Significance_Testing(sspace,residuals,data,model_order,granger_results)

%% Parameters

tbegin = tic;
GPS_vars.study = 'MPS1';
GPS_vars.condition = 'soVerbMI';
GPS_vars.subject = 'average';
GPS_vars.savedir = '/autofs/cluster/dgow/GPS1.6/data';
GPS_vars.function = 'granger_significance';
study = data_load(GPS_vars, GPS_vars.study);

subsubsets = {'300TO500', '500TO800'};
conditions = {'soVerbMI', 'soVerbMR', 'soEndI', 'soEndR', 'ssVerbMI', 'ssVerbMR', 'ssEndI', 'ssEndR' };

for i_conditions = 1:(length(conditions))
    GPS_vars.condition = conditions{i_conditions};
    
    for i_subsubset = 1:(length(subsubsets))
        subsubset = subsubsets{i_subsubset};
        
        varargin{1} = ['_subjave_' subsubset];
        
        % Study
        
        condition = data_load(GPS_vars, GPS_vars.condition);
        
        % Simple Granger Results
        
        if(length(varargin) == 1)
            special_affix = varargin{1};
            inputfilename = sprintf('%s/results/%s%s.mat',...
                study.granger.dir, condition.name, special_affix);
            outputfilename = sprintf('%s/results/%s%s_significance_%s.mat',...
                study.granger.dir, condition.name, special_affix, datestr(now, 'yyyymmdd'));
        elseif(length(varargin) == 2)
            inputfilename = varargin{1};
            outputfilename = varargin{2};
        else
            inputfilename = sprintf('%s/results/%s.mat',...
                study.granger.dir, condition.name);
            outputfilename = sprintf('%s/results/%s_significance_%d.mat',...
                study.granger.dir, condition.name, datestr(now, 'yyyymmdd'));
        end
        
        grangerfile = load(inputfilename);
        
        sspace = grangerfile.sspace;
        residuals = grangerfile.residual;
        data = grangerfile.data;
        granger_results = grangerfile.granger_results;
        % model_order = grangerfile.model_order;
        
        clear grangerfile;
        
        % Specific Parameters
        [N_trials N_ROIs N_time] = size(data);
        W_gain = 0.5;%study.granger.W_gain; %0.03;
        model_order = 5;%study.granger.model_order; %7;
        N_comp = 2000;
        
        filename_rois = sprintf('%s/rois/%s/%s/*.label', study.granger.dir, condition.name, subsubset);
        all_rois = dir(filename_rois);
        all_rois = {all_rois.name};
        
        % Define ROIs of interest for significance testing
        src_selection = {'L-STG', 'L-MTG', 'Fusi', 'ParaHip', 'L-ParsTri', 'L-ParsOper', 'L-ParsOrb'};
        snk_selection = src_selection;
        
        src_ROIs = zeros(N_ROIs, 1);
        for i_ROI = 1:N_ROIs
            for isrc_selection = 1:length(src_selection)
                if(~isempty(strfind(all_rois{i_ROI}, src_selection{isrc_selection})))
                    src_ROIs(i_ROI)=1;
                end
            end
        end
        src_ROIs = find(src_ROIs);
        snk_ROIs = src_ROIs
        N_src = length(src_ROIs);
        N_snk = length(snk_ROIs);
        
        % Preallocated Varibles
        total_control_granger = zeros(N_snk, N_src, N_time, N_comp, 'single');
        % alpha_values = zeros(N_ROIs, N_ROIs, N_time);
        % signif_conn = zeros(N_ROIs, N_ROIs, N_time);
        % bstrap_time = zeros(N_trials, N_ROIs, N_time);
        
        matlabpool 8
        
        parfor i_comp = 1:N_comp
            tcomp = tic;
            
            
            % Step 5: For each subject, resample the residuals (random sampling
            % with replacement)
            residuals_resample = zeros(N_trials, N_ROIs, N_time);
            
            % Reorder within each trial??? look into this
            %     for i_trial = 1:N_trials
            %         N_reorder = N_ROIs * N_time;
            %         reorder = randperm(N_reorder);
            %         reorder = residuals(N_reorder * (i_trial - 1) + reorder);
            %         reorder = reshape(reorder, N_ROIs, N_time);
            %
            %         residuals_resample(i_trial,:,:) = reorder;
            %     end
            % Reorder within each trial??? look into this
            %     a = tic;
            for i_trial = 1:N_trials
                for i_ROI = 1:N_ROIs
                    N_reorder = N_time;
                    reorder = randperm(N_reorder);
                    
                    residuals_resample(i_trial, i_ROI, :) = residuals(i_trial, i_ROI, reorder);
                end % For all time
            end % For all trials
            
            %     save('randomdist_significance.mat') % Save the intermediate values
            %     fprintf('resample residuals: %f\n', toc(a));
            
            % Compare all ROIs...
            for i_src = 1:N_src
                i_ROI = src_ROIs(i_src);
                
                % ... with all other ROIs
                % run time
                for i_snk = 1:N_snk
                    j_ROI = snk_ROIs(i_snk);
                    %             a = tic;
                    bstrap_time = zeros(N_trials, N_ROIs, N_time);
                    
                    % Indices in the source space that record ROI i influece.
                    model_order_end = j_ROI*model_order;
                    start_ind = model_order_end - (model_order-1);
                    
                    % Define the source space excluding ROI i (xi)
                    sspace_xi = sspace;
                    sspace_xi(start_ind:model_order_end,i_ROI,:) = 0;
                    
                    %             fprintf('initialize: %f\n', toc(a));
                    %             a = tic;
                    
                    % Build a new time series
                    
                    for n = (model_order+1):N_time   %length in terms of time
                        
                        % Build the time window for the current timepoint
                        H = data(:, :, n - (model_order:-1:1));
                        H = reshape(H, N_trials, N_ROIs * model_order);
                        
                        sspace_xi_n = squeeze(sspace_xi(:,:,n));
                        
                        % Generate a new dataset for this relationship
                        bstrap_time(:,:,n) = (H * sspace_xi_n);
                    end
                    
                    bstrap_time = bstrap_time + residuals_resample;
                    
                    bstrap_time(:,:,1:model_order) = data(:,:,1:model_order);
                    
                    % Run granger on this
                    
                    control_granger = granger(bstrap_time, model_order, W_gain, i_ROI, j_ROI); % Specifing Source and Sink nodes
                    total_control_granger(i_snk, i_src, :, i_comp) = single(control_granger(j_ROI, i_ROI, :));
                    
                end
            end % For all ROIs
            
            history_comment = sprintf('Computed Grangers for Iteration %d of %d.',...
                i_comp, N_comp);
            fprintf('%s in %3.0f seconds\n', history_comment, toc(tcomp));
            history(GPS_vars, toc(tcomp), history_comment);
        end
        
        matlabpool close
        
        alpha_values_focused = quantile(total_control_granger, 0.95, 4);
        signif_conn_focused = granger_results(snk_ROIs, src_ROIs, :) > alpha_values_focused;
        
        alpha_values = zeros(N_ROIs, N_ROIs, N_time);
        signif_conn = zeros(N_ROIs, N_ROIs, N_time);
        
        alpha_values(snk_ROIs, src_ROIs, :) = alpha_values_focused;
        signif_conn(snk_ROIs, src_ROIs, :) = signif_conn_focused;
        
        save(outputfilename, '-v7.3');
    end %end of subsets
end %end of conditions

history(GPS_vars, toc(tbegin), inputfilename);

end