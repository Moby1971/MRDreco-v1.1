function export_dicom_MRD(app,directory,image,parameters,tag)


% create folder if not exist, and clear
folder_name = [directory,[filesep,'DICOM-',tag]];
if (~exist(folder_name, 'dir')); mkdir(folder_name); end
delete([folder_name,filesep,'*']);

% Phase orientation
if isfield(app.seqpar, 'PHASE_ORIENTATION')
    if app.seqpar.PHASE_ORIENTATION == 1
        app.TextMessage('INFO: phase orientation = 1');
        image = permute(rot90(permute(image,[2 1 3 4 5 6]),1),[2 1 3 4 5 6]);
    end
end

[dimx,dimy,dimz,NR,NFA,NE] = size(image);


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
                dcm_header = generate_dicomheader_MRD(app,parameters,fname,filecounter,i,j,k,z,dimx,dimy,dimz,dcmid);
                
                % The image
                image1 = rot90(squeeze(cast(round(image(:,:,z,i,j,k)),'uint16')));
                
                % Write the dicom file
                dicomwrite(image1, fname, dcm_header);
                
                % Update progress bar
                app.ExportProgressGauge.Value = round(100*filecounter/totalnumberofimages);
                drawnow;
                
            end
            
        end
        
    end
    
end

app.ExportProgressGauge.Value = 100;


end