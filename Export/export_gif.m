function export_gif(app,directory,image,window,level,aspect)


% create folder if not exist, and delete folder content
folder_name = [directory,[filesep,'GIF']];
if (~exist(folder_name, 'dir')); mkdir(folder_name); end
delete([folder_name,filesep,'*']);

% Phase orientation
if isfield(app.seqpar, 'PHASE_ORIENTATION')
    if app.seqpar.PHASE_ORIENTATION == 1
        app.TextMessage('INFO: phase orientation = 1');
        image = permute(rot90(permute(image,[2 1 3 4 5 6]),1),[2 1 3 4 5 6]);
    end
end

% size of the data
dimx = size(image,1);
dimy = size(image,2);
dimz = size(image,3);
nr_frames = size(image,4);
NFA = size(image,5);
NE = size(image,6);

% scale from 0 to 255
window = window*255/max(image(:));
level = level*255/max(image(:));
image = image*255/max(image(:));

% window and level
image = (255/window)*(image - level + window/2);
image(image < 0) = 0;
image(image > 255) = 255;

% resize

numrows = 2*dimx;
numcols = 2*round(dimy*aspect);


% export the gif images

for i=1:nr_frames % loop over all repetitions
    
    for z=1:dimz    % loop over all slices
        
        for j=1:NFA      % loop over all flip angles
            
            cine = false;
            if isfield(app.seqpar,'frame_loop_on')
                if (app.seqpar.frame_loop_on == 1)
                    cine = true;
                end
            end
            
            if cine
                
                % File name
                fname = [folder_name,filesep,'movie_d',num2str(i),'_s',num2str(z),'_fa',num2str(j),'.gif'];
                
                % Delay time
                delay_time = 1/NE;
                
                for k=1:NE      % loop over all echo times (cine loop)
                    
                    % The image
                    im = rot90(uint8(round(imresize(squeeze(image(:,:,z,i,j,k)),[numrows numcols]))));
                    
                    % Write the gif file
                    if k==1
                        imwrite(im, fname,'DelayTime',delay_time,'LoopCount',inf);
                    else
                        imwrite(im, fname,'DelayTime',delay_time,'WriteMode','append','DelayTime',delay_time);
                    end
                    
                end
                
            else
                
                % Delay time
                delay_time = 1/nr_frames;
                
                for k=1:NE      % loop over all echo times, multi-echo
                    
                    % File name
                    fname = [folder_name,filesep,'image_s',num2str(z),'_fa',num2str(j),'_te',num2str(k),'.gif'];
                    
                    % The image
                    im = rot90(uint8(round(imresize(squeeze(image(:,:,z,i,j,k)),[numrows numcols]))));
                    
                    % Write the gif file
                    if i==1
                        imwrite(im, fname,'DelayTime',delay_time,'LoopCount',inf);
                    else
                        imwrite(im, fname,'DelayTime',delay_time,'WriteMode','append','DelayTime',delay_time);
                    end
                    
                end
                
            end
            
        end
        
    end
    
end

end

