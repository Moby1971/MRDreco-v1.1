
function images = reco4D(app,kspace,nsaspace,TVxyz,TVtime,Wavelet)


app.TextMessage('Reconstructing the data ...');
app.TextMessage('WARNING: THIS MAY TAKE VERY LONG FOR LARGE DATASETS !');

dimx = size(kspace,2);
dimy = size(kspace,3);
dimz = size(kspace,4);

% eleventh dimensions is the time dimension  (11-1 = 10th for bart)
sense = ones(dimx, dimy, dimz,1,1,1,1,1,1,1,1);
kspace_pics = permute(kspace,[2,3,4,5,6,7,8,9,10,11,1]);
averages_pics = permute(nsaspace,[2,3,4,5,6,7,8,9,10,11,1]).^.5;

% wavelet in spatial dimensions 2^1+2^2=6, total variation in time 2^10 = 1024
% picscommand = ['pics -RW:7:0:',num2str(Wavelet),' -RT:7:0:',num2str(TVxyz),' -RT:1024:0:',num2str(TVtime),' -p'];
% image_reg = bart(picscommand,averages_pics,kspace_pics,sense);

picscommand = ['pics -RW:7:0:',num2str(Wavelet),' -RT:7:0:',num2str(TVxyz),' -RT:1024:0:',num2str(TVtime)];
image_reg = bart(picscommand,kspace_pics,sense);


app.TextMessage('Zerofilling to next power of 2 ...');

backtokspace = bart('fft -i 7',squeeze(image_reg));

new_dimx = power(2,nextpow2(dimx));
new_dimy = power(2,nextpow2(dimy));
new_dimz = power(2,nextpow2(dimz));

backtokspace = bart(['resize -c 0 ',num2str(new_dimx),' 1 ',num2str(new_dimy),' 2 ',num2str(new_dimz)],backtokspace);

images = abs(bart('fft 7',backtokspace));

images = permute(images,[4 1 2 3]);

app.TextMessage('Reconstruction is ready ...');

end