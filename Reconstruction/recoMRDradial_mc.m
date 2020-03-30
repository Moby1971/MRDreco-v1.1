
function images = recoMRDradial_mc(app,kspace_in,ncoils,Wavelet,TVxyz,TVt,dimx_new,dimy_new,dimz_new,dimt_new)

clc;

% resize k-space (kx, ky, kz, nr)
for i=1:ncoils
    kspace_in{i} = bart(['resize -c 0 ',num2str(dimx_new),' 1 ',num2str(dimy_new),' 2 ',num2str(dimz_new),' 3 ',num2str(dimt_new)],kspace_in{i});
end

dimx = size(kspace_in{1},1);
dimy = size(kspace_in{1},2);
dimz = size(kspace_in{1},3);
dimt = size(kspace_in{1},4);

for i = 1:ncoils
   kspace(:,:,:,:,i) = kspace_in{i};    
end
kspace_pics = permute(kspace,[3,1,2,5,6,7,8,9,10,11,4]);

% create trajectory
bartcommand = ['traj -r -y',num2str(dimy),' -x',num2str(dimx),' -q0:0:0'];
traj = bart(bartcommand);


if ncoils>1

    % sensitivity map
    sensitivities = ones(dimy,dimx);
    
    %kspace_pics_sum = sum(kspace_pics,11);
    %lowres_img = bart('nufft -i -l6 -d32:32:1 -t', traj, kspace_pics_sum);
    %lowres_ksp = bart('fft -u 7', lowres_img);

    % zeropad to full size
    %bartcommand = ['resize -c 0 ',num2str(dimy),' 1 ',num2str(dimx)];
    %ksp_zerop = bart(bartcommand, lowres_ksp);

    % calculate sensitivity map with bart
    %sensitivities = bart('ecalib -m1', ksp_zerop);
    
    % reconstruction
    picscommand = ['pics -S -u10 -RW:7:0:',num2str(Wavelet),' -RT:7:0:',num2str(TVxyz),' -RT:1024:0:',num2str(TVt),' -t'];
    images = bart(picscommand,traj,kspace_pics,sensitivities);
    
    % Sum of squares reconstruction
    images = abs(bart('rss 16', images));
    
else
    
    % sensitivity map
    sensitivities = ones(dimy,dimx);
   
    % reconstruction
    picscommand = ['pics -S -u10 -RW:7:0:',num2str(Wavelet),' -RT:7:0:',num2str(TVxyz),' -RT:1024:0:',num2str(TVt),' -t'];
    images = bart(picscommand,traj,kspace_pics,sensitivities);
    
end

% rearrange to orientation: x, y, z, frames
images = flip(flip(permute(abs(images),[3, 2, 1, 11, 4, 5, 6, 7, 8, 9, 10]),1),2);

end