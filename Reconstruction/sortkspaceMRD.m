function [sorted_kspace,nsa_space,k_filling] = sortkspace(app,uskspace,matrix,ky,kz,nrrepetitions,nrframes)

app.TextMessage('Sorting k-space ...');

% size of the image matrix
dimx = matrix(1);
dimy = matrix(2);
dimz = matrix(3);

skspace = zeros(nrframes, dimx, dimy, dimz);
nsaspace = zeros(nrframes, dimx, dimy, dimz);

% number of k-space points per repetition
kpointsperframe = round(dimy*dimz*nrrepetitions/nrframes);
app.TextMessage(strcat('k-lines per frame =',{' '},num2str(kpointsperframe),' ...'));

% sorting
for t = 1:nrframes
    
    app.TextMessage(strcat('Sorting frame',{' '},num2str(t),' ...'));
     
    wstart = (t - 1) * kpointsperframe + 1;
    wend = t * kpointsperframe;
    
    for w = wstart:wend
        
        for x = 1:dimx
            
            skspace(t,x,ky(w),kz(w)) = skspace(t,x,ky(w),kz(w)) + uskspace((w-1)*dimx+x);
            nsaspace(t,x,ky(w),kz(w)) = nsaspace(t,x,ky(w),kz(w)) + 1;
            
        end
        
    end
    
    app.SortProgressViewField.Value = round(100*t/nrframes);
    
end

% normalize by dividing through number of averages
skspace = skspace./nsaspace;
skspace(isnan(skspace)) = complex(0);


% for k-space filling visualization
kfilling = nsaspace./nsaspace;
kfilling(isnan(kfilling)) = 0;

% return the values
sorted_kspace = skspace;
nsa_space = nsaspace;
k_filling = kfilling;


end