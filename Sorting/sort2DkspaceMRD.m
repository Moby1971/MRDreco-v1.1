function [kspace_out,nsaspace_out,fillingspace_out,trajectory] = sort2DkspaceMRD(app,parameters,uskspace,frames)

%
% Sorting of 2D k-space data based on gp_var_mul array, defined for
% NO_VIEWS direction in FLASH sequence
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


% message
app.TextMessage('Sorting k-space ...');


% size of the image matrix
dimx = parameters.NO_SAMPLES_ORIG;
dimy = parameters.NO_VIEWS;
nr_slices = parameters.NO_SLICES; 
nr_repetitions = parameters.EXPERIMENT_ARRAY;
arraylength = parameters.NO_VIEWS_ORIG;


% pre-allocate large matrices
aframes = frames;
aframes(aframes==1)=2; % allocate at least 2 frames, because preallocating 1 does not work
kspace = zeros(dimx, dimy, nr_slices, aframes);
nsaspace = zeros(dimx, dimy, nr_slices, aframes);
trajectory = ones(dimx * arraylength * nr_slices * nr_repetitions,6);


% fill the ky-space locations
i = 1:arraylength;
ky(i) = int16(parameters.gp_var_mul(i)) + round(dimy/2) + 1;     % contains the y-coordinates of the custom k-space sequentially


% duplicate for multiple acquired repetitions
ky = repmat(ky,1,nr_repetitions * nr_slices);


% number of k-space points per frame
kpointsperframe = round(parameters.NO_VIEWS_ORIG * nr_repetitions / frames);
app.TextMessage(strcat('k-lines per frame =',{' '},num2str(kpointsperframe),' ...'));



% -----------------
%      SORTING
% -----------------

% trajectory counter
cnt = 0;

% Loop over slices
for slice = 1:nr_slices
    % loop over z-dimension (slices)    NOT TESTED, SEQUENCE NEEDS TO BE IMPLEMENTED
    
    % Loop over desired number of frames
    for dynamic = 1:frames
        
        app.TextMessage(strcat('Sorting frame',{' '},num2str(dynamic),' ...'));
        
        % code below not correct for slices !!!!
        wstart = (dynamic - 1) * kpointsperframe + 1; % starting k-line for specific frame
        wend = dynamic * kpointsperframe;             % ending k-line for specific frame
        if wend > arraylength * nr_repetitions
            wend = arraylength * nr_repetitions;
        end
        
        for w = wstart:wend
            
            for x = 1:dimx
                
                kspace(x,ky(w),slice,dynamic) = kspace(x,ky(w),slice,dynamic) + uskspace((w - 1) * dimx + x);
                nsaspace(x,ky(w),slice,dynamic) = nsaspace(x,ky(w),slice,dynamic) + 1;
                
                % fill the k-space trajectory array for viewing purposes
                cnt = cnt + 1;
                trajectory(cnt,1) = x;
                trajectory(cnt,2) = ky(w);
                trajectory(cnt,3) = slice;
                trajectory(cnt,4) = dynamic;
                
            end
            
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