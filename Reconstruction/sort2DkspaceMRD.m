function [kspace,nsaspace,fillingspace] = sort2DkspaceMRD(app,parameters,uskspace,frames)

app.TextMessage('Sorting k-space ...');

% size of the image matrix
dimx = parameters.NO_SAMPLES_ORIG;
dimy = parameters.NO_VIEWS;
dimz = parameters.NO_VIEWS_2;
nr = parameters.EXPERIMENT_ARRAY;

kspace = zeros(dimx, dimy, dimz, frames);
nsaspace = zeros(dimx, dimy, dimz, frames);

arraylength = parameters.NO_VIEWS_ORIG;

% fill the ky-space locations
cnt = 1;
for i = 1:arraylength
   
    ky(i) = int16(parameters.gp_var_mul(cnt)) + round(dimy/2) + 1;     % contains the y-coordinates of the custom k-space sequentially
    cnt = cnt + 1; 
    
end


% duplicate for multiple acquired repetitions
ky = repmat(ky,1,nr*dimz);

% number of k-space points per frame
kpointsperframe = round(parameters.NO_VIEWS_ORIG*nr/frames);

app.TextMessage(strcat('k-lines per frame =',{' '},num2str(kpointsperframe),' ...'));


% sorting

z = 1;
% loop over z-dimension (slices)    NOT CORRECT !!!

for t = 1:frames
    % loop over desired number of frames
    
    app.TextMessage(strcat('Sorting frame',{' '},num2str(t),' ...'));
    
    wstart = (t - 1) * kpointsperframe + 1; % starting k-line for specific frame
    wend = t * kpointsperframe;             % ending k-line for specific frame
    if wend > arraylength*nr 
        wend = arraylength*nr; 
    end
       
    for w = wstart:wend
        % loop over y-dimension (views)
        
        for x = 1:dimx
            % loop over x-dimension (readout)
            
            kspace(x,ky(w),z,t) = kspace(x,ky(w),z,t) + uskspace((w - 1)*dimx + x);
            nsaspace(x,ky(w),z,t) = nsaspace(x,ky(w),z,t) + 1;
        end
        
    end
    
end


       
% normalize by dividing through number of averages
kspace = kspace./nsaspace;
kspace(isnan(kspace)) = complex(0);


% for k-space filling visualization
fillingspace = nsaspace./nsaspace;
fillingspace(isnan(fillingspace)) = 0;


% flip to correct orientation
kspace = flip(flip(kspace,2),3);
nsaspace = flip(flip(nsaspace,2),3);
fillingspace = flip(flip(fillingspace,2),3);

end