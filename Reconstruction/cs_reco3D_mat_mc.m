function image_out = cs_reco3D_mat_mc(app,kspace_in,averages,ncoils,autosense,coilsensitivities,coilactive,lambda_W,lambda_TV,ndimx,ndimy,ndimz)


% kspace_in = {coil}[X Y Z NR]
%                    1 2 3 4  
dimx = size(kspace_in{1},1);
dimy = size(kspace_in{1},2);
dimz = size(kspace_in{1},3);
nr_dynamics = size(kspace_in{1},4);


% kspace data [x,y,z,dynamics,coils]
if autosense == 1
    for i = 1:ncoils
        kspace(:,:,:,:,i) = kspace_in{i}*coilactive(i);
    end
else
    for i = 1:ncoils
        kspace(:,:,:,:,i) = kspace_in{i}*coilsensitivities(i)*coilactive(i);
    end
end



% reset progress counter
param.iteration = 0;
app.RecoProgressGauge.Value = 0;
drawnow;


% kspace of slice
kdata = kspace(:,:,:,:,:);
mask = averages(:,:,:,:);

% fool the reco if nr_dynamics = 1, it needs at least 2 dynamics
if nr_dynamics == 1
    kdata(:,:,:,2,:) = kdata(:,:,:,1,:);
end

% zero-fill or crop x-dimension
if ndimx > dimx
    padsizex = round((ndimx - dimx)/2);
    kdatai = padarray(kdata,[padsizex,0,0,0,0],'both');
    maski = padarray(mask,[padsizex,0,0,0],'both');
else
    cropsize = round((dimx - ndimx)/2)-1;
    cropsize(cropsize<0)=0;
    kdatai = kdata(cropsize+1:end-cropsize,:,:,:,:);
    maski = mask(cropsize+1:end-cropsize,:,:,:);
end

% zero-fill or crop y-dimension
if ndimy > dimy
    padsizey = round((ndimy - dimy)/2);
    kdatai = padarray(kdatai,[0,padsizey,0,0,0],'both');
    maski = padarray(maski,[0,padsizey,0,0],'both');
else
    cropsize = round((dimy - ndimy)/2)-1;
    cropsize(cropsize<0)=0;
    kdatai = kdatai(:,cropsize+1:end-cropsize,:,:,:);
    maski = maski(:,cropsize+1:end-cropsize,:,:);
end

% zero-fill or crop z-dimension
if ndimz > dimz
    padsizez = round((ndimz - dimz)/2);
    kdatai = padarray(kdatai,[0,0,padsizez,0,0],'both');
    maski = padarray(maski,[0,0,padsizez,0],'both');
else
    cropsize = round((dimz - ndimz)/2)-1;
    cropsize(cropsize<0)=0;
    kdatai = kdatai(:,:,cropsize+1:end-cropsize,:,:);
    maski = maski(:,:,cropsize+1:end-cropsize,:);
end

% make sure dimensions are exactly ndimx, ndimy, ndimz
kdatai = kdatai(1:ndimx,1:ndimy,1:ndimz,:,:);
maski = maski(1:ndimx,1:ndimy,1:ndimz,:);

% make the mask
maski = maski./maski;
maski(isnan(maski)) = 1;
maski = logical(maski);

% size of the data
[nx,ny,nz,ncoils]=size(kdatai);

% normalize the data in the range of approx 0 - 1 for better numerical stability
kdatai = kdatai/max(abs(kdatai(:)));

% coil sensitivity map
b1 = ones(nx,ny,nz,ncoils);

% data
param.y = kdatai;

% reconstruction design matrix
param.E = Emat_zyxt(maski,b1);

% Total variation (TV) constraint in the temporal domain & Wavelet in spatial domain
param.TV = TVOP3D;
param.TVWeight = lambda_TV/8;

% Wavelet
param.W = Wavelet('Daubechies',12,12);
param.L1Weight = lambda_W;

% number of iterations, 2 x 10 iterations
param.nite = 10;
param.nouter = 2;
param.totaliterations = param.nouter * param.nite;

% linear reconstruction
kdata1 = randn(size(kdatai))/2000 + kdatai;  % add a little bit of randomness, such that linear reco is not exactly right
recon_dft = param.E'*kdata1;

% iterative reconstruction
recon_cs = recon_dft;

for n = 1:param.nouter
    [recon_cs,param.iteration] = CSL1NlCg(app,recon_cs,param);
end
image_tmp = abs(recon_cs);

% output reconstructed image
if nr_dynamics == 1
    image_out = image_tmp(:,:,:,1);
else
    image_out = image_tmp(:,:,:,:);
end

% images are flipped in all dimensions
image_out = flip(image_out,1);

% there seems to be a 1 pixel shift with this reco, correct for this:
image_out = circshift(image_out,1,1);
image_out = circshift(image_out,-1,2);
image_out = circshift(image_out,-1,3);

% update gauge
app.RecoProgressGauge.Value = 100;
drawnow;


end