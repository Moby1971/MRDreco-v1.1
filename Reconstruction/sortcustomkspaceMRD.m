function [kspace,nsaspace,fillingspace] = sortcustomkspaceMRD(app,parameters,uskspace,frames)

app.TextMessage('Sorting k-space ...');

% size of the image matrix
dimx = parameters.NO_SAMPLES;
dimy = parameters.NO_VIEWS;
dimz = parameters.NO_VIEWS_2;
nr = parameters.EXPERIMENT_ARRAY;

kspace = zeros(dimx, dimy, dimz, frames);
nsaspace = zeros(dimx, dimy, dimz, frames);

disp(size(kspace));

cnt = 1;
for i = 1:dimy*dimz
   
    ky(i) = int8(parameters.gp_var_proud(cnt))+round(dimy/2)+1;
    kz(i) = int8(parameters.gp_var_proud(cnt+1))+round(dimz/2)+1;
    cnt = cnt + 2;
    
end


% number of k-space points per repetition
kpointsperframe = round(dimy*dimz*nr/frames);
app.TextMessage(strcat('k-lines per frame =',{' '},num2str(kpointsperframe),' ...'));


% sorting
for t = 1:frames
    
    app.TextMessage(strcat('Sorting frame',{' '},num2str(t),' ...'));
     
    wstart = (t - 1) * kpointsperframe + 1;
    wend = t * kpointsperframe;
    
    for w = wstart:wend
        
        for x = 1:dimx
            
            kspace(x,ky(w),kz(w),t) = kspace(x,ky(w),kz(w),t) + uskspace((w-1)*dimx+x);
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