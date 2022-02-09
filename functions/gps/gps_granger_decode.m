function gciPkg = gps_granger_decode(data, model_order, pred_adapt, decodingROIs, rois, varargin)
% Performs Granger analysis on the data
%
% Adapted from the original gps_granger to do some tricky stuff with ROIs associated
% with the decoding data.
%
% Changelog:
% 2022-02-03 - Copied from the original.
%
% Input: The data matrix of sensors by time, the model order, and the
% factor that the prediction error adapts by, and more specifications if
% they are useful at limiting the data overhead
% Output: The computed granger causality indices

%% Setup

[N_subjects, N_ROIs, N_time] = size(data);
granger_causality_indices = zeros(N_ROIs, N_ROIs, N_time);
granger_causality_indices_pkg = [];

% Get the *names* of the ROIs in the data.
roiList = {};

for i_ROI = 1:length(rois)
  roiList{end + 1} = rois(i_ROI).name;
end

% Source and Receiving ROIs to be looked at in Granger
if (nargin > 5)
  src_ROI_names = varargin{1};
  rcv_ROI_names = varargin{2};
  src_ROIs = varargin{1};
  rcv_ROIs = varargin{2};
else % Do all
  src_ROIs = 1:N_ROIs; % ROIs that are being tested for influence from
  rcv_ROIs = 1:N_ROIs; % ROIs that are being tested to influence on
end

%% Analysis
% Gather the index numbers of the decoding ROIs.
decodingROIlist = [];
for i_decodeROI = 1:length(decodingROIs)
  decodingROIlist = [decodingROIlist, find(string(decodingROIs(i_decodeROI).name) == roiList)];
end

% A loop across decoding ROIs.
for i_decodeROI = 1:length(decodingROIs)
  sourceROIindex = decodingROIlist(i_decodeROI);
  
  % For reasons I do not understand, the 3D arrays loaded into the
  % save file in the consolidate step come out as 2D arrays here. They
  % need to be reshaped and permuted to be in proper order.
  sourceROIdata = permute(reshape(decodingROIs(i_decodeROI).subROIdata, ...
				  [], N_subjects, N_time), [2, 1, 3]);
  [~, N_subROIs, ~] = size(sourceROIdata);
  
  % Substitute the accuracy time series for all the "good" ROIs that are
  % not the one we're looking at just now.
  modifiedData = data;
  for i_goodROI = 1:length(decodingROIlist)
    if (decodingROIlist(i_goodROI) == sourceROIindex)
      continue;  % Skip the one we're looking at just now.
    end
    % This is a good ROI, but not the one of interest. Remove it from the
    % src_ROIs list...
    src_ROIs = src_ROIs(find(decodingROIlist(i_goodROI) ~= src_ROIs));
    
    % ... and substitute the avgAccuracy time series for the activation
    % time series in the block of time series data.  The procedure is
    % different if this is the first or last ROI in the list.
    if (decodingROIlist(i_goodROI) == 1) % Are we first?
      modifiedData = cat(2, 1e-10*reshape(decodingROIs(i_goodROI).avgAccuracy, ...
        N_subjects, 1, N_time), modifiedData(:, 2:N_ROIs, :));
    elseif (decodingROIlist(i_goodROI) == N_ROIs) % Are we last?
      modifiedData = cat(2, modifiedData(:, 1:(N_ROIs-1), :), ...
          1e-10*reshape(decodingROIs(i_goodROI).avgAccuracy, N_subjects, 1, N_time));
    else % Middle, apparently.
      targetROI = decodingROIlist(i_goodROI);
      modifiedData = cat(2, modifiedData(:, 1:(targetROI-1), :), ...
          1e-10*reshape(decodingROIs(i_goodROI).avgAccuracy, N_subjects, 1, N_time),...
          modifiedData(:, (targetROI+1):N_ROIs, :));
    end
  end

  % For the ROI we're looking at just now, stick all of its subROI data in
  % place of the single time series for sourceROIindex.  Again, this looks a 
  % little different if it's the first or last ROI in the list.
  if (sourceROIindex == 1) % Are we first?
    modifiedData = cat(2, sourceROIdata, modifiedData(:, 2:N_ROIs, :));
  elseif (sourceROIindex == N_ROIs) % Are we last?
    modifiedData = cat(2, modifiedData(:, 1:(N_ROIs-1), :), sourceROIdata);
  else % Middle, apparently.
    modifiedData = cat(2, modifiedData(:, 1:(sourceROIindex-1), :),...
        sourceROIdata, modifiedData(:, (sourceROIindex+1):N_ROIs, :));
  end
  
  prediction_error_standard = gps_kalman(data, model_order, pred_adapt);
  % Excluded ROI x prediction_error matrix
  prediction_errors_withoutROI = zeros(N_ROIs, N_ROIs, N_ROIs, N_time); 

  % For Each ROI that influences another ROI
  for i_ROI = src_ROIs
    % Remove the ROI.  dataReducer is used to remove the relevant rows of data
    % from the input data block.  outputReducer is for identifying where to store
    % the corresponding kalman output.
    outputReducer = ones(N_ROIs, 1);
    outputReducer(i_ROI) = 0;
    outputReducer = find(outputReducer);
    
    dataReducer = ones(N_ROIs + N_subROIs - 1,1);
    if (i_ROI < sourceROIindex)
      dataReducer(i_ROI) = 0;
    elseif (i_ROI > sourceROIindex)
      dataReducer(i_ROI + N_subROIs - 1) = 0;
    elseif (i_ROI == sourceROIindex)
      dataReducer(i_ROI:(i_ROI + N_subROIs -1)) = 0;
    else
      disp(sprintf("Something is wrong with ROI %d.", i_ROI));
    end
    dataReducer = find(dataReducer);
    data_reduced = modifiedData(:, dataReducer, :);

    % Conform this to the full prediction error matrix
    prediction_error_withoutROI = zeros(N_ROIs, N_ROIs, N_time);

    % Find the prediction error matrix without the ROI
    kalmanOutput = gps_kalman(data_reduced, model_order, pred_adapt);

    % Find which pieces of the kalman output are to be recorded.
    kalmanReducer = ones(length(dataReducer), 1);
    if (i_ROI ~= sourceROIindex)
      % Take out the exploded ROIs.
      kalmanReducer(sourceROIindex:(sourceROIindex + N_subROIs -1)) = 0;
      % But put one back as a representative.
      kalmanReducer(sourceROIindex) = 1;
    end
    kalmanReducer = find(kalmanReducer);

    % We have an array that is too big, so we need to take pieces of
    % it and slip them into the output array that was prepared for this.
    prediction_error_withoutROI(outputReducer, outputReducer, :) = ...
        kalmanOutput(kalmanReducer, kalmanReducer, :);
    
    % Park that output data where it belongs in the collection of output data.    
    prediction_errors_withoutROI(i_ROI, :, :, :) = prediction_error_withoutROI;
  end % For Each ROI

  % For Each Time Point (starting at when you can because of the model order)
  for i_time = (model_order + 1):N_time;
    
    % For Each ROI (this one is the reduced one)
    for i_ROI = src_ROIs
        
      % For Each ROI (Again)
      for j_ROI = rcv_ROIs
        % Get the prediction error in both models
        prediction_error_withoutROI = prediction_errors_withoutROI(i_ROI, j_ROI, j_ROI, i_time);
        prediction_error = prediction_error_standard(j_ROI, j_ROI, i_time);
            
        % Calculate the difference in the prediction error with and without the ROI
        granger_causality_index = log(prediction_error_withoutROI / prediction_error);
            
        granger_causality_indices(j_ROI, i_ROI, i_time) = granger_causality_index;
      end % For Each ROI
    end % For Each ROI
  end % For Each Timepoint

% Tuck new granger_causality_indices into a struct with ROI labels.
  gciPkg(i_decodeROI).name = decodingROIs(i_decodeROI).name;
  gciPkg(i_decodeROI).indices = granger_causality_indices;

% End loop over decoding ROIs.
end

end % function
