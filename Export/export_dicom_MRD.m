function export_dicom_MRD(app,directory,im,parameters,tag)


% create folder if not exist, and clear
folder_name = [directory,[filesep,'DICOM-',tag]];
if (~exist(folder_name, 'dir')); mkdir(folder_name); end
delete([folder_name,filesep,'*']);

[dimx,dimy,dimz,NR,NFA,NE] = size(im);

% export the dicom images

dcmid = dicomuid;   % unique identifier
dcmid = dcmid(1:50);

filecounter = 0;
app.ExportProgressGauge.Value = 0;
totalnumberofimages = NR*NFA*NE*dimz;                    

for i=1:NR      % loop over all repetitions
    
    for j=1:NFA     % loop over all flip angles
        
        for k=1:NE      % loop over all echo times
            
            for z=1:dimz        % loop over all slices
                
                % Counter
                filecounter = filecounter + 1;
                
                % File name
                fn = ['00000',num2str(filecounter)];
                fn = fn(size(fn,2)-5:size(fn,2));
                fname = [folder_name,filesep,'DICOM-XD-',fn,'.dcm'];
                
                % Dicom header
                dcm_header = generate_dicomheader_MRD(parameters,fname,filecounter,i,j,k,z,dimx,dimy,dimz,dcmid);
                
                % The image
                image = rot90(squeeze(cast(round(im(:,:,z,i,j,k)),'uint16')));
                
                % Write the dicom file
                dicomwrite(image, fname, dcm_header);
                
                % Update progress bar
                app.ExportProgressGauge.Value = round(100*filecounter/totalnumberofimages);
                drawnow;
                
            end
            
        end
        
    end
    
end

app.ExportProgressGauge.Value = 100;


end