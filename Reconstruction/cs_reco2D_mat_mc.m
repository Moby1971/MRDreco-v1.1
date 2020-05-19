function image_out = cs_reco2D_mat_mc(app,kspace_in,ncoils,lambda_W,lambda_TV,ndimx,ndimy)


% kspace_in = {coil}[X Y slices NR]
%                    1 2    3    4  
dimx = size(kspace_in{1},1);
dimy = size(kspace_in{1},2);
nr_slices = size(kspace_in{1},3);
nr_dynamics = size(kspace_in{1},4);

% kspace data x,y,NR,slices
for i = 1:ncoils
    kspace_in{i} = permute(kspace_in{i},[1,2,4,3]);
end

% kspace data x,y,NR,slices,coils
for i = 1:ncoils
    kspace(:,:,:,:,i) = kspace_in{i};
end

% reset progress counter
param.iteration = 0;
app.RecoProgressGauge.Value = 0;
drawnow;

% slice loop
for slice = 1:nr_slices
    
    % kspace of slice
    kdata = squeeze(kspace(:,:,:,slice,:));
    mask = squeeze(averages(:,:,:,slice));
    
    % fool the reco if nr_dynamics = 1, it needs at least 2 dynamics
    if nr_dynamics == 1
        kdata(:,:,2,:) = kdata(:,:,1,:);
    end
    
    % zero-fill or crop x-dimension
    if ndimx > dimx
        padsizex = round((ndimx - dimx)/2);
        kdatai = padarray(kdata,[padsizex,0,0,0],'both');
        maski = padarray(mask,[padsizex,0,0],'both');
    else
        cropsize = round((dimx - ndimx)/2)-1;
        cropsize(cropsize<0)=0;
        kdatai = kdata(cropsize+1:end-cropsize,:,:,:);
        maski = mask(cropsize+1:end-cropsize,:,:);
    end
    
    % zero-fill or crop y-dimension
    if ndimy > dimy
        padsizey = round((ndimy - dimy)/2);
        kdatai = padarray(kdatai,[0,padsizey,0,0],'both');
        maski = padarray(maski,[0,padsizey,0],'both');
    else
        cropsize = round((dimy - ndimy)/2)-1;
        cropsize(cropsize<0)=0;
        kdatai = kdatai(:,cropsize+1:end-cropsize,:,:);
        maski = maski(:,cropsize+1:end-cropsize,:);
    end
   
    % make sure dimensions are exactly ndimx, ndimy
    kdatai = kdatai(1:ndimx,1:ndimy,:,:);
    maski = maski(1:ndimx,1:ndimy,:);
    
    % make the mask
    maski = maski./maski;
    maski(isnan(maski)) = 1;
    maski = logical(maski);
    
    % size of the data
    [ny,nx,~,ncoils]=size(kdatai);
    
    % normalize the data in the range of approx 0 - 1 for better numerical stability
    kdatai = kdatai/max(abs(kdatai(:)));
        
    % coil sensitivity map
    b1 = ones(ny,nx,ncoils);
    
    % data
    param.y = kdatai;
  
    % reconstruction design matrix
    param.E = Emat_yxt(maski,b1);
    
    % Total variation (TV) constraint in the temporal domain & Wavelet in spatial domain
    param.TV = TVOP;
    param.TVWeight = lambda_TV/8;
    
    % Wavelet
    param.W = Wavelet('Daubechies',12,12);
    param.L1Weight = lambda_W; 
    
    % number of iterations, 2 x 10 iterations
    param.nite = 10;
    param.nouter = 2;
    param.totaliterations = nr_slices * param.nouter * param.nite;
    
    % linear reconstruction
    nrd = size(kdatai,3);
    kdata1 = squeeze(randn(ndimx,ndimy,nrd,ncoils))/2000 + kdatai;  % add a little bit of randomness, such that linear reco is not exactly right
    recon_dft = param.E'*kdata1;
   
    % iterative reconstruction
    recon_cs = recon_dft;
    
    for n = 1:param.nouter
        [recon_cs,param.iteration] = CSL1NlCg(app,recon_cs,param);
    end
    image_tmp = abs(recon_cs);
    
    % output reconstructed image
    if nr_dynamics == 1
        image_out(:,:,slice,:) = image_tmp(:,:,1);
    else
        image_out(:,:,slice,:) = image_tmp;
    end
    
end

image_out = round(4096*image_out/max(image_out(:)));
image_out = flip(flip(image_out,1),2);

% update gauge
app.RecoProgressGauge.Value = 100;
drawnow;


end