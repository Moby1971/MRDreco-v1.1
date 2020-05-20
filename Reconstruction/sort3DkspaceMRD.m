function [kspace,nsaspace,fillingspace] = sort3DkspaceMRD(app,parameters,ukspace,frames)

app.TextMessage('Sorting k-space ...');

% size of the image matrix (X, Y, Z, NR, NFA, NE)
% for now ignoring NFA and NE
dimx = parameters.NO_SAMPLES_ORIG;
dimy = parameters.NO_VIEWS;
dimz = parameters.NO_VIEWS_2;
nr = parameters.EXPERIMENT_ARRAY;

kspace = zeros(dimx, dimy, dimz, frames);
nsaspace = zeros(dimx, dimy, dimz, frames);

% centric k-space ordering for views 2
if parameters.pe2_centric_on == 1
   kzp(1) = 0;
   for i = 1:dimz-1
       kzp(i+1) = (-1)^i * round(i/2);
   end
   kzp = kzp - min(kzp) + 1;
else
   kzp = 1:dimz; 
end

% 
totalnr = length(ukspace);
arraylength = parameters.NO_VIEWS_ORIG*dimz;



cnt1 = 1;
cnt2 = 1;
for i = 1:totalnr
    ky(i) = int16(parameters.gp_var_mul(round(cnt1/dimz)+1)) + round(dimy/2) + 1;
    cnt1 = cnt1 + 1;
    cnt1(cnt1 > arraylength) = 1;
    kz(i) = kzp(cnt2);
    cnt2 = cnt2 + 1;
    cnt2(cnt2 > dimz) = 1;
end



% number of k-space points per frame
kpointsperframe = round(parameters.NO_VIEWS_ORIG*dimz*nr/frames);
app.TextMessage(strcat('k-lines per frame =',{' '},num2str(kpointsperframe),' ...'));

% sorting

% loop over desired number of frames
for t = 1:frames
    
    app.TextMessage(strcat('Sorting frame',{' '},num2str(t),' ...'));
    
    wstart = (t - 1) * kpointsperframe + 1; % starting k-line for specific frame
    wend = t * kpointsperframe;             % ending k-line for specific frame
    wend(wend > arraylength*nr) = arraylength*nr;
    
    % loop over y-dimension (views)
    for w = wstart:wend
        
        % loop over x-dimension (readout)
        for x = 1:dimx
            
            kspace(x,ky(w),kz(w),t) = kspace(x,ky(w),kz(w),t) + ukspace((w - 1)*dimx + x);
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


end