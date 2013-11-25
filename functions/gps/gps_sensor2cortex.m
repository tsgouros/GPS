function cortex_data = gps_sensor2cortex(sensor_data, inv, varargin)
% Takes sensor data and the inverse solution and computes the cortical data
%
% Author: A. Conrad Nied
%
% Original Code in mne_ex_compute_inverse.m of the MNE suite
% Date Created: 2012.05.25 (as separate code)
% Last Modified: 2012.09.04
%
% Changelog:
% Originally based on mne_ex_compute_inverse.m
% 2012.05.25 - Created as GPS1.6/mne_applyinverse.m
% 2012.10.10 - Adapted to GPS1.7
% 2012.10.30 - Added fixed orientation option


% Handle inputs

dSPM = 0;
orientation_ave = 1;

for i_argin = 1:length(varargin)
    parameter = varargin{i_argin};
    
    if(strcmp(parameter, 'dSPM'))
        dSPM = 1;
    elseif(strcmp(parameter, 'Fixed'))
        orientation_ave = 0;
    end
end % for each parameter

% Clean up sensor data / format for MNE
sensor_data = diag(sparse(inv.reginv)) * inv.eigen_fields.data * inv.whitener * inv.proj * double(squeeze(sensor_data));

% Map to cortex
% Modify R before here for depth weighting probably
if inv.eigen_leads_weighted % R^0.5 has been already factored in
    cortex_data = inv.eigen_leads.data * sensor_data;
else % R^0.5 has to factored in
    cortex_data = diag(sparse(sqrt(inv.source_cov.data))) * inv.eigen_leads.data * sensor_data;
end

% Patch together from multiple source orientations. Ricky stopped
% doing this for some reason and stayed to a fixed orientation
% Source Covariance matrix is diagonal, N_source*3
% points

if(orientation_ave)
    FIFF = fiff_define_constants;
    % Fixed source orientations or all source orientations?
    if inv.source_ori == FIFF.FIFFV_MNE_FREE_ORI
        cortex_data_new = zeros(size(cortex_data, 1)/3, size(cortex_data, 2));
        
        for i_time = 1:size(cortex_data, 2)
            cortex_data_new(:, i_time) = sqrt(mne_combine_xyz(cortex_data(:, i_time)));
        end % For each channel
        
        cortex_data = cortex_data_new;
        clear source_data_new;
    end % If it is all source orientations
    
else
    % Fixed Orientation (perpendicular)
    cortex_data = cortex_data(1:3:end, :);
end

% dSPM
if(dSPM)
    cortex_data = inv.noisenorm * cortex_data;
end

end % File