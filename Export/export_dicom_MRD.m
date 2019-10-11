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
                    

for i=1:NR
    
    for j=1:NFA
        
        for k=1:NE
            
            for z=1:dimz
                
                filecounter = filecounter + 1;
                
                fn = ['00000',num2str(filecounter)];
                fn = fn(size(fn,2)-5:size(fn,2));
                fname = [folder_name,filesep,'DICOM-XD-',fn,'.dcm'];
                
                dcm_header = generate_dicomheader_MRD(parameters,fname,filecounter,i,j,k,z,dimx,dimy,dimz,dcmid);
                
                image = rot90(squeeze(cast(round(im(:,:,z,i,j,k)),'uint16')));
                
                dicomwrite(image, fname, dcm_header);
                
            end
            
        end
        
    end
    
end




end