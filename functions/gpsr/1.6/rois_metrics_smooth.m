function smooth_value = rois_metrics_smooth(value, faces, vertex)
% Smoothes data over a cortical surface
%
% Author: Conrad Nied and Fa Hsuan Lin
%
% Based on Fa-Hsuan Lin's inverse_smooth from 2004
% Date Created: 2012.06.26
% Last Modified: 2012.06.26
%
% Inputs: Data, faces (indexing starts at 1), and coordinates
% Outputs: Smoothed data
%
% data must be positive reals, with 0 representing vertices to fill in

N_smoothings = 5;
N_vertices = length(value);
N_faces = size(faces, 2);

d1 = [faces(1,:); [1:N_faces]; ones(1, N_faces)]';
d2 = [faces(2,:); [1:N_faces]; ones(1, N_faces)]';
d3 = [faces(3,:); [1:N_faces]; ones(1, N_faces)]';
A = spones(spconvert([d1; d2; d3]));
B = spones(A*A' + speye(N_vertices));
yy = sum(B, 2);
clear A

if(min(size(value))==1)
	value=reshape(value, [N_vertices, 1]);
end

smooth_value = zeros(size(value));

for tt = 1:size(value, 2)
	w = value(:, tt);
    
	non_zero = find(w > 0);
	w0 = w(non_zero);
    
	w = griddatan(...
        vertex(1:3, non_zero)',...
        w(non_zero),...
        vertex(1:3, :)',...
        'nearest');
    
	for i_smoothing = 1:N_smoothings
		w = B * w ./ yy;
		
		w(non_zero) = w0;
    end
    
    data_min = min(w0);
    data_max = max(w0);
    smooth_value(:, tt) = (w - data_min) .* (data_max - data_min) ./ (data_max - data_min) + data_min;
end

end % function