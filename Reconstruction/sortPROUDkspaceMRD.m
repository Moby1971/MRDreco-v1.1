function [kspace,nsaspace,fillingspace] = sortPROUDkspaceMRD(app,parameters,uskspace,frames)

app.TextMessage('Sorting k-space ...');

% size of the image matrix
dimx = parameters.NO_SAMPLES;
dimy = parameters.NO_VIEWS;
dimz = parameters.NO_VIEWS_2;
nr = parameters.EXPERIMENT_ARRAY;

kspace = zeros(dimx, dimy, dimz, frames);
nsaspace = zeros(dimx, dimy, dimz, frames);

arraylength = parameters.NO_VIEWS_ORIG*parameters.NO_VIEWS_2_ORIG;

% fill the ky and kz k-space locations
cnt = 1;
for i = 1:arraylength
   
    ky(i) = int8(parameters.gp_var_proud(cnt)) + round(dimy/2) + 1;     % contains the y-coordinates of the custom k-space sequentially
    kz(i) = int8(parameters.gp_var_proud(cnt+1)) + round(dimz/2) + 1;   % contains the z-coordinates of the custom k-space sequentially
    cnt = cnt + 2; 
    
end

% duplicate for multiple acquired repetitions
ky = repmat(ky,1,nr+1);
kz = repmat(kz,1,nr+1);

% number of k-space points per frame
kpointsperframe = round(dimy*dimz*nr/frames);
app.TextMessage(strcat('k-lines per frame =',{' '},num2str(kpointsperframe),' ...'));


% sorting
for t = 1:frames
    % loop over desired number of frames
    
    app.TextMessage(strcat('Sorting frame',{' '},num2str(t),' ...'));
     
    wstart = (t - 1) * kpointsperframe + 1; % starting k-line for specific frame
    wend = t * kpointsperframe;             % ending k-line for specific frame
    if wend>dimy*dimz*nr 
        wend = dimy*dimz*nr; 
    end
    
    for w = wstart:wend
        % loop over y- and z-dimensions (views and views2)
        
        for x = 1:dimx 
            % loop over x-dimension (readout)
            
            kspace(x,ky(w),kz(w),t) = kspace(x,ky(w),kz(w),t) + uskspace((w-1)*dimx + x);
            nsaspace(x,ky(w),kz(w),t) = nsaspace(x,ky(w),kz(w),t) + 1;
            
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