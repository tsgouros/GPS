%% Distance (Chebyshev)

% Author: A. Conrad Nied, 2011.09.20
 
%% Inputs
% vector A, vector OR matrix B

%% Outputs
% distance from A to B
% OR
% array of distances from A to vectors in B.

%% Example:
% distLM([1 0],[3 0; 4 4; 2 1]) = [2; 4; 1]

function D = distLM(A, B)
    % Gather dimensionality
    [N_A ~] = size(A);
    [N_B ~] = size(B);
    if(N_A > 1)
        disp('The first argument must be only one value');
        return;
    end

    % Calculate Distance
    D = max(abs(repmat(A,N_B,1) - B)')';
end