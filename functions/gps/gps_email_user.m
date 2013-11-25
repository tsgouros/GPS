function gps_email_user(message, varargin)
% Emails the user in the martinos network a message
%
% Author: Conrad Nied
%
% Input: Message
%
% Changelog:
% 2012.08.07 - Created as GPS1.6/email_user.m
% 2012.09.19 - Updated to GPS1.7
% 2012.10.31 - Expanded user functionality, restricts to the triad for now
% 2013.01.10 - Corrected mispelling
% 2013.03.12 - Can specify user too
% 2013.06.28 - Added fail condition

try
if(~ischar(message) && ~iscell(message))
    message = message.message;
end
if(nargin >= 2)
    title = varargin{1};
else
    title = 'MATLAB Notification';
end
if(nargin >= 3)
    user = varargin{2};
else
    user = getenv('USER');
end

if(~strcmp({'conrad', 'vancelet', 'dgow'}, user))
    user = 'conrad';
    message{end + 1} = sprintf('Unknown user %s', user);
end
emailaddress = sprintf('%s@nmr.mgh.harvard.edu', user);

sendmail(emailaddress, title, message);

catch error
    fprintf('Emailing failed, %s\n', error.message');
end


end