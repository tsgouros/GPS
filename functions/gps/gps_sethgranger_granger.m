function granger_causality_indices = gps_sethgranger_granger(data, model_order, pred_adapt, varargin)
% Performs Granger analysis on the data
%
% Author: A. Conrad Nied, Ricky Sachdeva
%
% Changelog:
% 2012.11.27 - Created based on GPS1.7/gps_granger

% Input: The data matrix of sensors by time, the model order, and the
% factor that the prediction error adapts by, and more specifications if
% they are useful
% Output: The computed granger causality indices

%% Setup

% pred_adapt = 0.5;
% model_order = 5;
[N_trials N_ROIs N_time] = size(data);
granger_causality_indices = zeros(N_ROIs, N_ROIs, N_time);

% Source and Receiving ROIs to be looked at in Granger
if (nargin == 5)
    src_ROIs = varargin{1};
    rcv_ROIs = varargin{2};
else % Do all
    src_ROIs = 1:N_ROIs; % ROIs that are being tested for influence from
    rcv_ROIs = 1:N_ROIs; % ROIs that are being tested to influence on
end

%% Analysis

% all_granger_causality_indices = zeros(N_trials, N_ROIs, N_ROIs, N_time);
% data_orig = data;
% for i_trial = 1:N_trials
%     fprintf('Trial %d\n', i_trial);
%     data = data_orig(i_trial, :, :);

% fprintf('Computing Regular Kalman\n');
prediction_error_standard = gps_sethgranger_kalman(data, model_order, pred_adapt);

% For Each ROI that influences another ROI
for i_ROI = src_ROIs
    fprintf('% 4d\t', i_ROI);
    for j_ROI = rcv_ROIs
        fprintf('%d ', j_ROI);
        % Find the prediction error matrix without the interaction
        prediction_errors_withoutROI = gps_sethgranger_kalman(data, model_order, pred_adapt, i_ROI, j_ROI);
        
        % Get instantaneous GCIs
        for i_time = (model_order + 1):N_time;
            prediction_error_withoutROI = prediction_errors_withoutROI(j_ROI, j_ROI, i_time);
            prediction_error = prediction_error_standard(j_ROI, j_ROI, i_time);
            
            granger_causality_index = log(prediction_error_withoutROI / prediction_error);
            
            granger_causality_indices(j_ROI, i_ROI, i_time) = granger_causality_index;
        end % for each timepoint
    end % for each receiving ROI
    fprintf('\n');
end % For Each ROI

end % function