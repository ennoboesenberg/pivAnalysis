%% Adjust Dataset
% according to given mask defined by rect_vec and its respective rotation rot_vec
function [v] = adjustDataHARD(lonam, rect_vec, rot_vec)

    adj_counter = size(rot_vec, 2);

    % Masking entire dataset    
    v                               = loadvec(lonam);                       % loads part of VC7 files
    for qq = 1:adj_counter
        v                           = rotatef(v,rot_vec(qq));
        v                           = extractf(v, rect_vec(qq,1:4));
    end
    %v                               = rotatef(v,-sum(rot_vec));             % rotating back to original image orientation

end