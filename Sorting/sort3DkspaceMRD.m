function [kspace_out,nsaspace_out,fillingspace_out,trajectory] = sort3DkspaceMRD(app,parameters,ukspace,frames)

%
% Sorting of 3D k-space data based on gp_var_mul array, defined for
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



app.TextMessage('Sorting k-space ...');

% size of the image matrix (X, Y, Z, NR, NFA, NE)
% for now ignoring NFA and NE
dimx = parameters.NO_SAMPLES_ORIG;
dimy = parameters.NO_VIEWS;
dimz = parameters.NO_VIEWS_2;
nr_repetitions = parameters.EXPERIMENT_ARRAY;
arraylength = parameters.NO_VIEWS_ORIG*dimz;
dimy_orig = parameters.NO_VIEWS_ORIG;



% preallocate memory for the matrices
aframes = frames;
aframes(aframes==1)=2;
kspace = zeros(dimx, dimy, dimz, aframes); % allocate at least 2 frames, because preallocating 1 does not work
nsaspace = zeros(dimx, dimy, dimz, aframes);
trajectory = ones(dimx*arraylength*nr_repetitions,6);


% centric or linear k-space ordering for views2
if parameters.pe2_centric_on == 1
   kzp(1) = 0;
   for i = 1:dimz-1
       kzp(i+1) = (-1)^i * round(i/2);
   end
   kzp = kzp - min(kzp) + 1;
else
   kzp = 1:dimz; 
end


% fill the ky-space locations
cnt1 = 1;
cnt = 1;
for i = 1:arraylength
    ky(i) = int16(parameters.gp_var_mul(cnt1)) + round(dimy/2) + 1;
    kz(i) = kzp(cnt);
    cnt = cnt + 1;
    if cnt > dimz
       cnt = 1;
       cnt1 = cnt1 + 1;
       cnt1(cnt1 > dimy_orig) = 1;
    end
end


% duplicate for multiple acquired repetitions
ky = repmat(ky,1,nr_repetitions);
kz = repmat(kz,1,nr_repetitions);


% number of k-space points per frame
kpointsperframe = round(dimy_orig * dimz * nr_repetitions / frames);
app.TextMessage(strcat('k-lines per frame =',{' '},num2str(kpointsperframe),' ...'));



% -----------------
%      SORTING
% -----------------

% trajectory counter
cnt = 0;

% loop over desired number of frames
for dynamic = 1:frames
    
    app.TextMessage(strcat('Sorting frame',{' '},num2str(dynamic),' ...'));
    
    wstart = (dynamic - 1) * kpointsperframe + 1; % starting k-line for specific frame
    wend = dynamic * kpointsperframe;             % ending k-line for specific frame
    wend(wend > arraylength*nr_repetitions) = arraylength * nr_repetitions;
    
    % loop over y-dimension (views)
    for w = wstart:wend
        
        % loop over x-dimension (readout)
        for x = 1:dimx
            
            kspace(x,ky(w),kz(w),dynamic) = kspace(x,ky(w),kz(w),dynamic) + ukspace((w - 1) * dimx + x);
            nsaspace(x,ky(w),kz(w),dynamic) = nsaspace(x,ky(w),kz(w),dynamic) + 1;
            
            % fill the k-space trajectory array
            cnt = cnt + 1;
            trajectory(cnt,1) = x;
            trajectory(cnt,2) = ky(w);
            trajectory(cnt,3) = kz(w);
            trajectory(cnt,4) = dynamic;
                    
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