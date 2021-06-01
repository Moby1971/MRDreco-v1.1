function dicom_header = generate_dicomheader_DCM(app,dcmhead,parameters,fn,filecounter,frame,j,k,slice,dimx,dimy,dimz,nr_frames)

%
% GENERATES DICOM HEADER FOR EXPORT
%
% parameters = parameters from MRD file
% dcmhead = dicom info from scanner generated dicom
%
% frame = current frame number
% nr_frames = total number of frames
% dimy = y dimension (phase encoding, views)
% dimx = x dimension (readout, samples)
% 
%

frametime = parameters.acqdur/nr_frames;    % time between frames in ms

if app.seqpar.PHASE_ORIENTATION == 1
    pixely = app.FOVViewField1.Value/dimy;
    pixelx = app.FOVViewField2.Value/dimx;
else
    pixely = app.FOVViewField2.Value/dimy;
    pixelx = app.FOVViewField1.Value/dimx;
end

fn = ['0000',num2str(frame)];
fn = fn(size(fn,2)-4:size(fn,2));
fname = ['DICOM_',fn,'.dcm'];

dt = datetime(parameters.date,'InputFormat','dd-MMM-yyyy HH:mm:ss');
year = num2str(dt.Year);
month = ['0',num2str(dt.Month)]; month = month(end-1:end);
day = ['0',num2str(dt.Day)]; day = day(end-1:end);
date = [year,month,day];

hour = ['0',num2str(dt.Hour)]; hour = hour(end-1:end);
minute = ['0',num2str(dt.Minute)]; minute = minute(end-1:end);
seconds = ['0',num2str(dt.Second)]; seconds = seconds(end-1:end);
time = [hour,minute,seconds];

dcmhead.Filename = fname;
dcmhead.FileModDate = parameters.date;
dcmhead.FileSize = dimy*dimx*2;
dcmhead.Width = dimy;
dcmhead.Height = dimx;
dcmhead.BitDepth = 15;
dcmhead.InstitutionName = 'Amsterdam UMC';
dcmhead.ReferringPhysicianName.FamilyName = 'AMC preclinical MRI';
dcmhead.InstitutionalDepartmentName = 'Amsterdam UMC preclinical MRI';
dcmhead.PhysicianOfRecord.FamilyName = 'Amsterdam UMC preclinical MRI';
dcmhead.PerformingPhysicianName.FamilyName = 'Amsterdam UMC preclinical MRI';
dcmhead.PhysicianReadingStudy.FamilyName = 'Amsterdam UMC preclinical MRI';
dcmhead.OperatorName.FamilyName = 'manager';
dcmhead.ManufacturerModelName = 'MRS7024';
dcmhead.ReferencedFrameNumber = [];  
%dcmhead.PatientName.FamilyName = 'Amsterdam UMC preclinical MRI';
%dcmhead.OtherPatientName.FamilyName = 'Amsterdam UMC preclinical MRI';
dcmhead.NumberOfAverages = parameters.NO_AVERAGES;
dcmhead.InversionTime = 0;
dcmhead.ImagedNucleus = '1H';
dcmhead.MagneticFieldStrength = 7;
dcmhead.TriggerTime = (frame-1)*frametime;    % frame time 
dcmhead.AcquisitionMatrix = uint16([dimx 0 0 dimy])';
dcmhead.AcquisitionDeviceProcessingDescription = '';
dcmhead.AcquisitionDuration = parameters.acqdur;
dcmhead.InstanceNumber = filecounter;          % instance number
dcmhead.TemporalPositionIdentifier = frame;     % frame number
dcmhead.NumberOfTemporalPositions = nr_frames;
dcmhead.ImagesInAcquisition = nr_frames*dimz;
dcmhead.TemporalPositionIndex = uint32([]);
dcmhead.Rows = dimy;
dcmhead.Columns = dimx;
dcmhead.PixelSpacing = [pixely pixelx]';
dcmhead.PixelAspectRatio = [1 pixely/pixelx]';
dcmhead.BitsAllocated = 16;
dcmhead.BitsStored = 15;
dcmhead.HighBit = 14;
dcmhead.PixelRepresentation = 0;
dcmhead.PixelPaddingValue = 0;
dcmhead.RescaleIntercept = 0;
dcmhead.RescaleSlope = 1;
dcmhead.NumberOfSlices = dimz;


dcmhead.SliceThickness = parameters.SLICE_THICKNESS;
dcmhead.EchoTime = parameters.te*k;                 % ECHO TIME         
dcmhead.SpacingBetweenSlices = parameters.SLICE_SEPARATION/parameters.SLICE_INTERLEAVE;
dcmhead.EchoTrainLength = parameters.NO_ECHOES;
dcmhead.FlipAngle = parameters.flipanglearray(j);           % FLIP ANGLES

if isfield(dcmhead, 'SliceLocation')
    startslice = dcmhead.SliceLocation;
    dcmhead.SliceLocation = startslice+(slice-1)*(parameters.SLICE_SEPARATION/parameters.SLICE_INTERLEAVE);
end

dicom_header = dcmhead;

end


