
function images = recoMRD(kspace,Wavelet,TVxyz,TVtime,new_dimx,new_dimy,new_dimz,new_dimr)

% resize k-space (kx, ky, kz, nr)
kspace = bart(['resize -c 0 ',num2str(new_dimx),' 1 ',num2str(new_dimy),' 2 ',num2str(new_dimz),' 3 ',num2str(new_dimr)],kspace);

dimx = size(kspace,1);
dimy = size(kspace,2);
dimz = size(kspace,3);
dimr = size(kspace,4);

% eleventh dimensions is the time (nr) dimension  (11-1 = 10th for bart)
sense = ones(dimx,dimy,dimz,1,1,1,1,1,1,dimr);
kspace_pics = permute(kspace,[1,2,3,5,6,7,8,9,10,11,4]);

% wavelet and TV in spatial dimensions 2^0+2^1+2^2=7, total variation in time 2^10 = 1024
picscommand = ['pics -RW:7:0:',num2str(Wavelet),' -RT:7:0:',num2str(TVxyz),' -RT:1024:0:',num2str(TVtime)];
images = bart(picscommand,kspace_pics,sense);

% absolute image
images = abs(images);

end