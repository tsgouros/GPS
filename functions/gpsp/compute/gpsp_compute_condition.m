function data = gpsp_compute_condition(granger, flag_contrast)
% Gathers the data and computes the granger values for a condition
%
% Author: A. Conrad Nied
%
% Changelog:
% 2013-08-10 Created in line with GPS1.8/gpsp_compute_granger.m

state = gpsp_get;

% Get settings
tstart = state.frame(1);
tstop = state.frame(2);
rois = granger.rois;

flag_count = get(state.method_countsum, 'Value') == 1;
flag_vis = ~flag_contrast;

%% Compute connection strength

values = granger.results(:,:,tstart:tstop);
if(isfield(granger, 'p_values'))
    p_values = 1 - granger.p_values(:,:,tstart:tstop);
else
    p_values = [];
end

% Threshold
if(get(state.method_thresh_gci, 'Value'))
    threshold = str2double(get(state.method_thresh_gci_val, 'String'));
    suprathreshold = values >= threshold;
    alpha = ones(size(suprathreshold)) * threshold;

    % P alpha (not going to compute)
    p_alpha = zeros(size(suprathreshold));
else % P Value threshold
    threshold = str2double(get(state.method_thresh_p_val, 'String'));
    
    % Check the threshold
    if(threshold > 1)
        warndlg('P value may not exceed 1')
        set(handles.method_thresh_p_val, 'String', '1.00');
        threshold = 1;
    elseif(threshold < 0)
        warndlg('P value may not be less than 0')
        set(handles.method_thresh_p_val, 'String', '0.00');
        threshold = 0;
    end
    
    suprathreshold = p_values <= threshold;
    % P alpha (not going to compute)
    p_alpha = ones(size(suprathreshold)) * threshold;
    
    % Get alpha level curve
    if(isfield(granger, 'perc05'))
        switch threshold
            case 0.001
                alpha = granger.perc001(:,:,tstart:tstop);
            case 0.005
                alpha = granger.perc005(:,:,tstart:tstop);
            case 0.01
                alpha = granger.perc01(:,:,tstart:tstop);
            case 0.05
                alpha = granger.perc05(:,:,tstart:tstop);
            case 0.1
                alpha = granger.perc10(:,:,tstart:tstop);
            otherwise
                fprintf('No alpha curve for %d threshold\n', threshold);
        end
    end
    if(~exist('alpha', 'var'))
        alpha = zeros(size(suprathreshold));
    end
end

% Count or sum?
switch get(state.method_countsum, 'Value')
    case 1 % Count
        connections = squeeze(sum(suprathreshold, 3));
    case 2 % Sum
        connections = granger.results(:,:,tstart:tstop);
        connections(~suprathreshold) = 0;
        connections = squeeze(sum(connections, 3));
end

% Connection Threshold
if(~flag_contrast && get(state.method_rethresh_abs, 'Value'))
    connections(abs(connections) < str2double(get(state.method_rethresh_abs_val, 'String'))) = 0;
end

%% Highlight only selected connections

selection = zeros(size(state.region_selection));
available_pairs = state.region_pairs;
selected_pairs = get(state.regions_pairs, 'Value');

for i_pair = squeeze(selected_pairs)
    selection(available_pairs(i_pair, 2), available_pairs(i_pair, 1)) = 1;
end

% Zero out connections that are not selected
connections(~selection) = 0;

% Print out the connections with values above zero
if(flag_vis)
    fprintf('Granger Computation Report:\n');
end
for i = 1:length(connections)
    for j = 1:length(connections)
        
        if connections(j, i) ~= 0 && flag_vis
            if flag_count
                fprintf('%12s\t->\t%12s\t%d\n', rois{i}, rois{j}, connections(j, i))
            else
                fprintf('%12s\t->\t%12s\t%.2f\n', rois{i}, rois{j}, connections(j, i))
            end
        end
    end
end
if(flag_vis); fprintf('\n'); end

%% Compute Node Strength

% Source
source_strength = zeros(length(connections), 1);
for i = 1:length(connections)
    value = sum(connections(:, i));
    source_strength(i) = value;
    
    % Print it out
    if value ~= 0 && flag_vis
        if flag_count
            fprintf('%12s\t->\t%12s\t%d\n', rois{i}, 'All', value)
        else
            fprintf('%12s\t->\t%12s\t%.2f\n', rois{i}, 'All', value)
        end
    end
end
if(flag_vis); fprintf('\n'); end

% Sink
sink_strength = zeros(length(connections), 1);
for j = 1:length(connections)
    value = sum(connections(j, :));
    sink_strength(j) = value;
    
    % Print it out
    if value ~= 0 && flag_vis
        if flag_count
            fprintf('%12s\t->\t%12s\t%d\n', 'All', rois{j}, value)
        else
            fprintf('%12s\t->\t%12s\t%.2f\n', 'All', rois{j}, value)
        end
    end
end
if(flag_vis); fprintf('\n'); end

%% Save and Plot

% Assemble and save a plotdata object
data.name = 'data';
data.tstart = tstart;
data.tstop = tstop;
data.selection = selection;
data.rois = rois;
data.threshold = threshold;
data.values = values;
data.p_values = p_values;
data.suprathreshold = suprathreshold;
data.alpha = alpha;
data.p_alpha = p_alpha;
data.connections = connections;
data.source_strength = source_strength;
data.sink_strength = sink_strength;
data.flag_count = flag_count;
data.flag_contrast = 0;

end % function