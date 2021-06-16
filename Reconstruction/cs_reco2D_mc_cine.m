function images = cs_reco2D_mc_cine(app,kspace_in,ncoils,autosense,coilsensitivities,coilactive,Wavelet,TVxy,LR,TVd,dimx_new,dimy_new,dimd_new)

% app = matlab app
% kspace_in = sorted k-space 
% nc = number of RF receiver coils
% Wavelet = wavelet L1-norm regularization factor
% TVt = total variation in CINE dimension
% TVxy = total variation in xy-dimension regularization


% kspace_in = {coil}[X Y slices NR FA NE z]
%                    1 2    3    4 5  6  7
dimx = dimx_new;
dimy = dimy_new;
dimz = size(kspace_in{1},3);
dimd = dimd_new;
dimte = size(kspace_in{1},6);


% resize k-space to next power of 2
for i = 1:ncoils 
    kspace_in{i} = bart(['resize -c 0 ',num2str(dimx),' 1 ',num2str(dimy),' 2 ',num2str(dimz),' 3 ',num2str(dimd)],kspace_in{i});
end


% put all data in a normal matrix
for i = 1:ncoils
    kspace(:,:,:,:,:,:,1,i) = kspace_in{i}*coilactive(i);
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

%                             1  2  3  4  5  6  7  8  9  10 11 12 13 14
kspace_pics = permute(kspace,[7 ,2 ,1 ,8 ,9 ,6 ,5 ,10,11,12,4 ,13,14,3 ]);


% wavelet in y and x spatial dimensions 2^1 + 2^2 = 6
% total variation in y and x spatial dimensions 2^1 + 2^2 = 6
% total variation in TE and dynamic dimension 2^5 + 2^10 = 1056


if ncoils>1 && autosense==1
    
    % ESPIRiT reconstruction
    TextMessage(app,'ESPIRiT reconstruction ...');
    
    % Calculate coil sensitivity maps with ecalib bart function
    kspace_pics_sum = sum(kspace_pics,[11,12]);
    sensitivities = bart('ecalib -S -I -a', kspace_pics_sum);      % ecalib with softsense
    
    picscommand = ['pics -S -RL:6:7:',num2str(LR),' -RW:6:0:',num2str(Wavelet),' -RT:6:0:',num2str(TVxy),' -RT:1056:0:',num2str(TVd)];
    image_reg = bart(picscommand,kspace_pics,sensitivities);
    
    % Sum of squares reconstruction
    image_reg = bart('rss 16', image_reg);
    image_reg = abs(image_reg);
 
end
    
    
if ncoils==1 || autosense==0
    
    % Sensitivity correction
    sensitivities = ones(1,dimy,dimx,ncoils,1,1,1,1,1,1,1,1,1,dimz);
    for i = 1:ncoils
        sensitivities(:,:,:,i,:) = sensitivities(:,:,:,i,:)*coilsensitivities(i)*coilactive(i);
    end
    
    % regular reconstruction
    picscommand = ['pics -S -RL:6:7:',num2str(LR),' -RW:6:0:',num2str(Wavelet),' -RT:6:0:',num2str(TVxy),' -RT:1056:0:',num2str(TVd)];
    image_reg = bart(picscommand,kspace_pics,sensitivities);
    
    % Take absolute values
    image_reg = abs(image_reg);
    
end


% rearrange to correct orientation: x, y, slices, dynamics
image_reg = reshape(image_reg,[1,dimy,dimx,dimte,dimd,dimz]);


% X Y slices NR flip-angles echo-times
images = permute(image_reg,[3,2,6,5,4,1]);
images = flip(images,2);



end