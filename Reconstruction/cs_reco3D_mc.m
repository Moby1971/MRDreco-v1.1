
function images = cs_reco3D_mc(app,kspace_in,ncoils,autosense,coilsensitivities,coilactive,Wavelet,TVxyz,LR,TVd,dimx_new,dimy_new,dimz_new,dimd_new)


clc;


% resize k-space (kx, ky, kz, nr)
for i=1:ncoils
    kspace_in{i} = bart(['resize -c 0 ',num2str(dimx_new),' 1 ',num2str(dimy_new),' 2 ',num2str(dimz_new),' 3 ',num2str(dimd_new)],kspace_in{i});
end



dimx = size(kspace_in{1},1);
dimy = size(kspace_in{1},2);
dimz = size(kspace_in{1},3);
dimd = size(kspace_in{1},4);

for i = 1:ncoils
   kspace(:,:,:,:,i) = kspace_in{i}*coilactive(i);    
end



% Bart dimensions
% 	READ_DIM,       1   z  
% 	PHS1_DIM,       2   y  
% 	PHS2_DIM,       3   x  
% 	COIL_DIM,       4   coils
% 	MAPS_DIM,       5   sense maps
% 	TE_DIM,         6
% 	COEFF_DIM,      7
% 	COEFF2_DIM,     8
% 	ITER_DIM,       9
% 	CSHIFT_DIM,     10
% 	TIME_DIM,       11  dynamics
% 	TIME2_DIM,      12  
% 	LEVEL_DIM,      13
% 	SLICE_DIM,      14  slices
% 	AVG_DIM,        15

%                             1  2  3  4  5  6  7  8  9  10 11 
kspace_pics = permute(kspace,[3 ,2 ,1 ,5 ,6 ,7 ,8 ,9 ,10,11,4 ]);


if ncoils>1 && autosense==1
    
    % ESPIRiT reconstruction
    TextMessage(app,'ESPIRiT reconstruction ...');
    
    % espirit sensitivity maps
    kspace_pics_sum = sum(kspace_pics,11);
    sensitivities = bart('ecalib -I -S -a', kspace_pics_sum);
    
    % wavelet and TV in spatial dimensions 2^0+2^1+2^2=7, total variation in time 2^10 = 1024
    picscommand = 'pics -S'; 
    if Wavelet>0
       picscommand = [picscommand, ' -RW:7:0:',num2str(Wavelet)];
    end
    if TVxyz>0
       picscommand = [picscommand, ' -RT:7:0:',num2str(TVxyz)];
    end
    if LR>0
       picscommand = [picscommand, ' -RL:7:7:',num2str(LR)];
    end 
    if TVd>0
       picscommand = [picscommand, ' -RT:1024:0:',num2str(TVd)];
    end
    image_reg = bart(picscommand,kspace_pics,sensitivities);
    
    % Sum of squares
    image_reg = abs(bart('rss 16', image_reg));
    
end
    
    
if ncoils==1 || autosense==0
    
    % Sensitivity correction
    sensitivities = ones(dimz,dimy,dimx,ncoils,1,1,1,1,1,dimd);
    for i = 1:ncoils
        sensitivities(:,:,:,i,:) = sensitivities(:,:,:,i,:)*coilsensitivities(i)*coilactive(i);
    end
  
    % wavelet and TV in spatial dimensions 2^0+2^1+2^2=7, total variation in time 2^10 = 1024
    % regular reconstruction
    picscommand = 'pics -S'; 
    if Wavelet>0
       picscommand = [picscommand, ' -RW:7:0:',num2str(Wavelet)];
    end
    if TVxyz>0
       picscommand = [picscommand, ' -RT:7:0:',num2str(TVxyz)];
    end
    if LR>0
       picscommand = [picscommand, ' -RL:7:7:',num2str(LR)];
    end 
    if TVd>0
       picscommand = [picscommand, ' -RT:1024:0:',num2str(TVd)];
    end
    image_reg = bart(picscommand,kspace_pics,sensitivities);
    
    % Absolute value
    image_reg = abs(image_reg);
    
end


% rearrange to correct orientation: x, y, z, dynamics
image_reg = reshape(image_reg,[dimz,dimy,dimx,dimd]);
images = permute(image_reg,[3,2,1,4]);

images = flip(flip(images,2),3);

end