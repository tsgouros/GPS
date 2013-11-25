function gpsp_draw_buttonbg(hObject)
% Does the usual background color check on GUI buttons. I moved it from the
% function collection because it cluttered it up.
% 
% Author: A. Conrad Nied
%
% Changelog:
% 2013-07-15 Created as GPS1.8/gpsp_draw_buttonbg

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end % function