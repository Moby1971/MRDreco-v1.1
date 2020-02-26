
function images = recoMRD_mc(app,kspace_in,ncoils,Wavelet,TVxyz,TVt,dimx_new,dimy_new,dimz_new,dimt_new)

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
kspace_pics = permute(kspace,[3,2,1,5,6,7,8,9,10,11,4]);



if ncoils>1
    
    % espirit sensitivity maps
    kspace_pics_sum = sum(kspace_pics,11);
    sensitivities = bart('ecalib -I -S -a', kspace_pics_sum);
    
    % wavelet and TV in spatial dimensions 2^0+2^1+2^2=7, total variation in time 2^10 = 1024
    picscommand = ['pics -S -RW:7:0:',num2str(Wavelet),' -RT:7:0:',num2str(TVxyz),' -RT:1024:0:',num2str(TVt)];
    images = bart(picscommand,kspace_pics,sensitivities);
    
    % Sum of squares reconstruction
    images = abs(bart('rss 16', images));
    
else
    
    % z,y,x, coils, eleventh dimensions is the time (nr) dimension  (11-1 = 10th for bart)
    sensitivities = ones(dimz,dimy,dimx,1,1,1,1,1,1,dimt);
    
    % wavelet and TV in spatial dimensions 2^0+2^1+2^2=7, total variation in time 2^10 = 1024
    % regular reconstruction
    picscommand = ['pics -S -RW:7:0:',num2str(Wavelet),' -RT:7:0:',num2str(TVxyz),' -RT:1024:0:',num2str(TVt)];
    images = bart(picscommand,kspace_pics,sensitivities);
    
end



% rearrange to orientation: x, y, z, frames
images = flip(flip(permute(abs(images),[3, 2, 1, 11, 4, 5, 6, 7, 8, 9, 10]),1),2);

end