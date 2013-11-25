function num = alphahash(str)
% Converts a string into a number
%
% Author: Conrad Nied
%
% Date Created: 2012.06.27
% Last Modified: 2012.06.27

num = 0;
str = lower(str);
for i = 1:length(str)
    num = num + (str(i) - 'a' + 1) * 26 ^ (i - 1);
end

end

