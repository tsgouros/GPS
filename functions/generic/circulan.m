function y = circulan(x)

n = ceil(length(x)/2);
% n = length(x);
i = repmat((1:n)', 1, n);
j = repmat(1:n, n, 1);

% ij = abs(i - j) + 1;
ij = (j - i) + n;

y = x(ij);

end