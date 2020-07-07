function kspace = backtokspace(twoD,images)


if twoD == 1
    
    % Images = (X, Y, slices, NR, NFA, NE)
    [~, ~, slices, NR, NFA, NE] = size(images);
    
    kspace = zeros(size(images));
    images = circshift(images,1,2);
    
    for i = 1:slices
        
        for j = 1:NR
            
            for k = 1:NFA
                
                for w = 1:NE
                    
                    kspace(:,:,i,j,k,w) = fft2c_mri(squeeze(images(:,:,i,j,k,w)));
                    
                end
                
            end
            
        end
        
    end
    
    % samples, views, views2, slices, echoes (frames), experiments, flip-angles
    kspace = flip(permute(kspace,[1,2,7,3,6,4,5]),1);
    
else
    
    % Images = (X, Y, Z, NR, NFA, NE)
    [~, ~, ~, NR, NFA, NE] = size(images);
    images = circshift(images,1,2);
    images = circshift(images,1,3);
    
    for j = 1:NR
        
        for k = 1:NFA
            
            for w = 1:NE
                
                kspace(:,:,:,j,k,w) = fft3c_mri(squeeze(images(:,:,:,j,k,w)));
                
            end
            
        end
        
    end
    
    % samples, views, views2, slices, echoes (frames), experiments, flip-angles
    kspace = flip(permute(kspace,[1,2,3,7,6,4,5]),1);
    
end





end