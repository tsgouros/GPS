function gpsp_compute_granger
% Computes the granger activity given the time samples and focus
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2013-07-15 Created GPS1.8/gpsp_compute_granger out of GPS1.7/plot_draw
% 2013-08-05 Can be specified as pairs of connections
% 2013-08-10 Added constrasting options
% 2013-09-17 Added asterisk marking routines

%% Parameters

state = gpsp_get;

%% Get data matrices and perform any necessary computations

switch get(state.method_condition, 'Value')
    case 1
        granger = gpsp_get('granger');
        if(isempty(granger) || ~isfield(granger, 'results')); return; end
        plotdata = gpsp_compute_condition(granger, 0);
    case 2
        granger = gpsp_get('granger2');
        if(isempty(granger) || ~isfield(granger, 'results')); return; end
        plotdata = gpsp_compute_condition(granger, 0);
    case 3
        granger = gpsp_get('granger');
        if(isempty(granger) || ~isfield(granger, 'results')); return; end
        plotdata1 = gpsp_compute_condition(granger, 1);
        granger = gpsp_get('granger2');
        if(isempty(granger) || ~isfield(granger, 'results')); return; end
        plotdata2 = gpsp_compute_condition(granger, 1);
    case 4
        granger = gpsp_get('granger2');
        if(isempty(granger) || ~isfield(granger, 'results')); return; end
        plotdata1 = gpsp_compute_condition(granger, 1);
        granger = gpsp_get('granger');
        if(isempty(granger) || ~isfield(granger, 'results')); return; end
        plotdata2 = gpsp_compute_condition(granger, 1);
    otherwise
        return
end

% Contrast if available
if(exist('plotdata2', 'var'))
    
    % Compute connection difference
    plotdata = plotdata1;
    plotdata.flag_contrast = 1;
    plotdata.connections = plotdata.connections - plotdata2.connections;
    
    if(get(state.method_rethresh_abs, 'Value'))
        plotdata.connections(abs(plotdata.connections) < str2double(get(state.method_rethresh_abs_val, 'String'))) = 0;
    end
    
    % Compute p(difference)
    plotdata.p_diff = zeros(size(plotdata.connections));
    plotdata.asterisk = zeros(size(plotdata.connections));
    p_thresh = str2double(get(state.method_rethresh_p_val, 'String'));
%     if(get(state.method_rethresh_p, 'Value'))
%         plotdata.connections(abs(plotdata.p_diff) > str2double(get(state.method_rethresh_p_val, 'String'))) = 0;
%     end
    
    % Report values
    flag_vis = 1;
    fprintf('Granger Computation Report:\n');
    fprintf('Source\tSink\t%s\t%s\tDifference\tp(same)\n', state.condition, state.condition2);
    for i = 1:length(plotdata.connections)
        for j = 1:length(plotdata.connections)
            
            if plotdata.connections(j, i) ~= 0
                % Compute p(difference)
                report = gps_binomdiff(squeeze(plotdata1.suprathreshold(j, i, :)),...
                    squeeze(plotdata2.suprathreshold(j, i, :)));
                plotdata.p_diff(j, i) = report.p;
                if(plotdata.p_diff(j, i) >= p_thresh)
                    special = '';
                else
                    special = '*';
                    plotdata.asterisk(j, i) = 1;
                end
                
                if plotdata.flag_count
                    fprintf('%s\t%s\t%d\t%d\t%d\t%.3f\t%s\n', plotdata.rois{i}, plotdata.rois{j}, plotdata1.connections(j, i), plotdata2.connections(j, i), plotdata.connections(j, i), plotdata.p_diff(j, i), special)
                else
                    fprintf('%s\t%s\t%.2f\t%.2f\t%.2f\t%.3f\t%s\n', plotdata.rois{i}, plotdata.rois{j}, plotdata1.connections(j, i), plotdata2.connections(j, i), plotdata.connections(j, i), plotdata.p_diff(j, i), special)
                end
                
                if(get(state.method_rethresh_p, 'Value') && plotdata.p_diff(j, i) >= p_thresh)
                    plotdata.connections(j, i) = 0;
                end
                
%                 figure(2)
%                 clf
%                 sig_bins = report.diff_bins <= -abs(report.N_diff) |...
%                     report.diff_bins >= abs(report.N_diff);
%                 if(~sum(sig_bins))
%                     sig_bins(1) = 1;
%                     sig_bins(end) = 1;
%                 end
%                 hold on
%                 bar(report.diff_bins(sig_bins),...
%                     report.diff_density(sig_bins), 'Facecolor', 'g');
%                 bar(report.diff_bins(~sig_bins),...
%                     report.diff_density(~sig_bins), 'Facecolor', 'w');
%                 line([report.N_diff report.N_diff], [0 max(report.diff_density)]);
%                 line(-[report.N_diff report.N_diff], [0 max(report.diff_density)]);
%                 plot(report.diff_bins(report.diff_density > 0),...
%                     report.diff_density((report.diff_density > 0)), 'k');
%                 axis([min(report.diff_bins) max(report.diff_bins) 0 max(report.diff_density)]);
%                 
%                 pause
                
            end
        end
    end
    fprintf('\n');
    
    %% Compute Node Strength
    plotdata.asterisk_src = sum(plotdata.asterisk, 1);
    plotdata.asterisk_snk = sum(plotdata.asterisk, 2);
    
    % Source
    for i = 1:length(plotdata.connections)
        value = sum(plotdata.connections(:, i));
        plotdata.source_strength(i) = value;
        
        % Print it out
        if value ~= 0 && flag_vis
            if plotdata.flag_count
                fprintf('%s\t%s\t%d\t%d\t%d\n', plotdata.rois{i}, 'All', plotdata1.source_strength(i), plotdata2.source_strength(i), value)
            else
                fprintf('%s\t%s\t%.2f\t%.2f\t%.2f\n', plotdata.rois{i}, 'All', plotdata1.source_strength(i), plotdata2.source_strength(i), value)
            end
        end
    end
    fprintf('\n');
    
    % Sink
    for j = 1:length(plotdata.connections)
        value = sum(plotdata.connections(j, :));
        plotdata.sink_strength(j) = value;
        
        % Print it out
        if value ~= 0 && flag_vis
            if plotdata.flag_count
                fprintf('%s\t%s\t%d\t%d\t%d\n', 'All', plotdata.rois{j}, plotdata1.sink_strength(j), plotdata2.sink_strength(j), value)
            else
                fprintf('%s\t%s\t%.2f\t%.2f\t%.2f\n', 'All', plotdata.rois{j}, plotdata1.sink_strength(j), plotdata2.sink_strength(j), value)
            end
        end
    end
else
    plotdata.asterisk = zeros(size(plotdata.connections));
    plotdata.asterisk_src = zeros(size(plotdata.connections, 1));
    plotdata.asterisk_snk = zeros(size(plotdata.connections, 2));
end

%% Save Data

plotdata.name = 'plotdata';
gpsp_set(plotdata);

% Draw the plot
gpsp_draw_plot;
% gpsp_draw_tc;
% gpsp_draw_granger;

end % function
