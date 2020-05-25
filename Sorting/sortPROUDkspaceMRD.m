function [kspace_out,nsaspace_out,fillingspace_out,trajectory] = sortPROUDkspaceMRD(app,parameters,uskspace,frames)


%
% Sorting of 3D k-space data based on memory loaded 3D matrix
% assuming NO_VIEWS*NO_VIEWS2 number of elements
%

%
% input:
% app = P2ROUD application
% parameters = sequence parameters structure
% uskspace = unsorted k-space
% frames = desired number of frames
%
% output:
% kspace_out = sorted k-space
% nsaspace_out = number of signal averages per k-point
% fillingspace_out = k-space point measured yes (1) or no (0)
%


app.TextMessage('Sorting k-space ...');


% size of the image matrix
dimx = parameters.NO_SAMPLES;
dimy = parameters.NO_VIEWS;
dimz = parameters.NO_VIEWS_2;
nr = parameters.EXPERIMENT_ARRAY;


% preallocate memory for the matrices
aframes = frames;
aframes(aframes==1)=2; % allocate at least 2 frames, because preallocating 1 does not work
kspace = zeros(dimx, dimy, dimz, aframes); 
nsaspace = zeros(dimx, dimy, dimz, aframes);
trajectory = ones(dimx*dimy*dimz*nr,6);


% fill the ky and kz k-space locations
for i = 1:length(parameters.proudarray)
    ky(i) = int8(parameters.proudarray(1,i)) + round(dimy/2) + 1;     % contains the y-coordinates of the custom k-space sequentially
    kz(i) = int8(parameters.proudarray(2,i)) + round(dimz/2) + 1;   % contains the z-coordinates of the custom k-space sequentially
end


% duplicate for multiple acquired repetitions
ky = repmat(ky,1,nr+1);
kz = repmat(kz,1,nr+1);


% number of k-space points per frame
klinesperframe = round(dimy*dimz*nr/frames);
app.TextMessage(strcat('k-lines per frame =',{' '},num2str(klinesperframe),' ...'));



% -----------------
%      SORTING
% -----------------

% trajectory counter
cnt = 0;

% loop over desired number of frames
for t = 1:frames
    
    app.TextMessage(strcat('Sorting frame',{' '},num2str(t),' ...'));
     
    wstart = (t - 1) * klinesperframe + 1; % starting k-line for specific frame
    wend = t * klinesperframe;             % ending k-line for specific frame
    if wend > dimy*dimz*nr 
        wend = dimy*dimz*nr; 
    end
       
    
    % loop over y- and z-dimensions (views and views2)
    for w = wstart:wend
        
        % loop over x-dimension (readout)
        for x = 1:dimx 
            
            % fill the k-space and signal averages matrix
            kspace(x,ky(w),kz(w),t) = kspace(x,ky(w),kz(w),t) + uskspace((w-1)*dimx + x);
            nsaspace(x,ky(w),kz(w),t) = nsaspace(x,ky(w),kz(w),t) + 1;
            
            % fill the k-space trajectory array
            cnt = cnt + 1;
            trajectory(cnt,1) = x;
            trajectory(cnt,2) = ky(w);
            trajectory(cnt,3) = kz(w);
            trajectory(cnt,4) = t;
            
        end
      
    end
    
end

       
% normalize by dividing through number of averages
kspace = kspace./nsaspace;
kspace(isnan(kspace)) = complex(0);
kspace_out = kspace(:,:,:,1:frames);
nsaspace_out = nsaspace(:,:,:,1:frames);


% for k-space filling visualization
fillingspace = nsaspace./nsaspace;
fillingspace(isnan(fillingspace)) = 0;
fillingspace_out = fillingspace(:,:,:,1:frames);


end