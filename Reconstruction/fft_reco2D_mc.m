function image_out = fft_reco2D_mc(app,kspace_in,nr_coils,ndimx,ndimy)


% kspace_in = {coil}[X Y slices NR]
%                    1 2    3    4  
dimx = size(kspace_in{1},1);
dimy = size(kspace_in{1},2);
nr_slices = size(kspace_in{1},3);
nr_dynamics = size(kspace_in{1},4);

% kspace data x,y,NR,slices
for i = 1:nr_coils
    kspace_in{i} = permute(kspace_in{i},[1,2,4,3]);
end

% kspace data x,y,NR,slices,coils
for i = 1:nr_coils
    kspace(:,:,:,:,i) = kspace_in{i};
end

% reset progress counter
app.RecoProgressGauge.Value = 0;
drawnow;

% slice and dynamic loop
for slice = 1:nr_slices
    
    for dynamic = 1:nr_dynamics
        
        % kspace of dynamic and slice
        kdata = squeeze(kspace(:,:,dynamic,slice,:));
        
        % zero-fill or crop x-dimension
        if ndimx > dimx
            padsizex = round((ndimx - dimx)/2);
            kdatai = padarray(kdata,[padsizex,0,0],'both');
        else
            cropsize = round((dimx - ndimx)/2)-1;
            cropsize(cropsize<0)=0;
            kdatai = kdata(cropsize+1:end-cropsize,:,:);
        end
        
        % zero-fill or crop y-dimension
        if ndimy > dimy
            padsizey = round((ndimy - dimy)/2);
            kdatai = padarray(kdatai,[0,padsizey,0],'both');
        else
            cropsize = round((dimy - ndimy)/2)-1;
            cropsize(cropsize<0)=0;
            kdatai = kdatai(:,cropsize+1:end-cropsize,:);
        end
        
        % make sure dimensions are exactly ndimx, ndimy, coils
        kdatai = kdatai(1:ndimx,1:ndimy,:);
        
        % FFT
        for coil = 1:nr_coils
            image_tmp(:,:,coil) = fft2c_mri(kdatai(:,:,coil));
        end
        
        % root sum of squares
        image_out(:,:,slice,dynamic) = rssq(image_tmp,3);
        
    end
    
end

image_out = flip(image_out,2);


% update gauge
app.RecoProgressGauge.Value = 100;
drawnow;


end