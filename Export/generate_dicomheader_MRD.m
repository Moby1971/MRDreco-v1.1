function dicom_header = generate_dicomheader_MRD(parameters,fname,filecounter,i,j,k,z,dimx,dimy,dimz,dcmid)

%
% GENERATES DICOM HEADER FOR EXPORT
%
% parameters = parameters from MRD file
% i = current repetition
% j = current flip angle
% k = current echo time 
% z = current slice
% dimx = x dimension (readout, samples)
% dimy = y dimension (phase encoding, views)
% dimz = z dimension (views 2)
%
%


acq_dur = parameters.nr_frames * parameters.timeperframe;   % acquisition time in seconds

pixelx = parameters.FOV/dimx;
pixely = parameters.aratio*parameters.FOV/dimy;
pixelz = parameters.NO_SLICES*parameters.SLICE_THICKNESS/dimz;

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
dcmhead.FileSize = dimy*dimz*2;
dcmhead.Format = 'DICOM';
dcmhead.FormatVersion = 3;
dcmhead.Width = dimx;
dcmhead.Height = dimy;
dcmhead.BitDepth = 15;
dcmhead.ColorType = 'grayscale';
dcmhead.FileMetaInformationGroupLength = 178;
dcmhead.FileMetaInformationVersion = uint8([0, 1])';
dcmhead.MediaStorageSOPClassUID = '1.2.840.10008.5.1.4.1.1.4';
dcmhead.TransferSyntaxUID = '1.2.840.10008.1.2.1';
dcmhead.ImplementationClassUID = '1.2.826.0.9717382.3.0.3.6.0';
dcmhead.ImplementationVersionName = 'OFFIS_DCMTK_360';
dcmhead.SpecificCharacterSet = 'ISO_IR 100';
dcmhead.ImageType = 'DERIVED\4D-MRI\';
dcmhead.SOPClassUID = '1.2.840.10008.5.1.4.1.1.4';
dcmhead.StudyDate = date;
dcmhead.SeriesDate = date;
dcmhead.AcquisitionDate = date;
dcmhead.StudyTime = time;
dcmhead.SeriesTime = time;
dcmhead.AcquisitionTime = time;
dcmhead.ContentTime = time;
dcmhead.Modality = 'MR';
dcmhead.Manufacturer = 'MR Solutions Ltd';
dcmhead.InstitutionName = 'Amsterdam UMC';
dcmhead.InstitutionAddress = 'Amsterdam, Netherlands';
dcmhead.ReferringPhysicianName.FamilyName = 'Amsterdam UMC preclinical MRI';
dcmhead.ReferringPhysicianName.GivenName = '';
dcmhead.ReferringPhysicianName.MiddleName = '';
dcmhead.ReferringPhysicianName.NamePrefix = '';
dcmhead.ReferringPhysicianName.NameSuffix = '';
dcmhead.StationName = 'MRI Scanner';
dcmhead.StudyDescription = 'XD-data';
dcmhead.SeriesDescription = '';
dcmhead.InstitutionalDepartmentName = 'Amsterdam UMC preclinical MRI';
dcmhead.PhysicianOfRecord.FamilyName = 'Amsterdam UMC preclinical MRI';
dcmhead.PhysicianOfRecord.GivenName = '';
dcmhead.PhysicianOfRecord.MiddleName = '';
dcmhead.PhysicianOfRecord.NamePrefix = '';
dcmhead.PhysicianOfRecord.NameSuffix = '';
dcmhead.PerformingPhysicianName.FamilyName = 'Amsterdam UMC preclinical MRI';
dcmhead.PerformingPhysicianName.GivenName = '';
dcmhead.PerformingPhysicianName.MiddleName = '';
dcmhead.PerformingPhysicianName.NamePrefix = '';
dcmhead.PerformingPhysicianName.NameSuffix = '';
dcmhead.PhysicianReadingStudy.FamilyName = 'Amsterdam UMC preclinical MRI';
dcmhead.PhysicianReadingStudy.GivenName = '';
dcmhead.PhysicianReadingStudy.MiddleName = '';
dcmhead.PhysicianReadingStudy.NamePrefix = '';
dcmhead.PhysicianReadingStudy.NameSuffix = '';
dcmhead.OperatorName.FamilyName = 'manager';
dcmhead.AdmittingDiagnosesDescription = '';
dcmhead.ManufacturerModelName = 'MRS7024';
dcmhead.ReferencedSOPClassUID = '';
dcmhead.ReferencedSOPInstanceUID = '';
dcmhead.ReferencedFrameNumber = [];  
dcmhead.DerivationDescription = '';
dcmhead.FrameType = '';
dcmhead.PatientName.FamilyName = 'Amsterdam UMC preclinical MRI';
dcmhead.PatientID = '01';
dcmhead.PatientBirthDate = date;
dcmhead.PatientBirthTime = '';
dcmhead.PatientSex = 'F';
dcmhead.OtherPatientID = '';
dcmhead.OtherPatientName.FamilyName = 'Amsterdam UMC preclinical MRI';
dcmhead.OtherPatientName.GivenName = '';
dcmhead.OtherPatientName.MiddleName = '';
dcmhead.OtherPatientName.NamePrefix = '';
dcmhead.OtherPatientName.NameSuffix = '';
dcmhead.PatientAge = '1';
dcmhead.PatientSize = [];
dcmhead.PatientWeight = 0.0300;
dcmhead.Occupation = '';
dcmhead.AdditionalPatientHistory = '';
dcmhead.PatientComments = '';
dcmhead.BodyPartExamined = '';
dcmhead.SequenceName = parameters.PPL;
dcmhead.SliceThickness = parameters.SLICE_THICKNESS;
dcmhead.KVP = 0;
dcmhead.RepetitionTime = parameters.tr;     
dcmhead.EchoTime = parameters.te*k;                 % ECHO TIME         
dcmhead.InversionTime = 0;
dcmhead.NumberOfAverages = parameters.NO_AVERAGES;     
dcmhead.ImagedNucleus = '1H';
dcmhead.MagneticFieldStrength = parameters.field_strength;
dcmhead.SpacingBetweenSlices = parameters.SLICE_SEPARATION/parameters.SLICE_INTERLEAVE;
dcmhead.EchoTrainLength = parameters.NO_ECHOES;
dcmhead.DeviceSerialNumber = '0034';
dcmhead.PlateID = '';
dcmhead.SoftwareVersion = '1.0.0.0';
dcmhead.ProtocolName = '';
dcmhead.SpatialResolution = [];
dcmhead.TriggerTime = 0;    
dcmhead.DistanceSourceToDetector = [];
dcmhead.DistanceSourceToPatient = [];
dcmhead.FieldofViewDimensions = [parameters.FOV parameters.aratio*parameters.FOV parameters.SLICE_THICKNESS];
dcmhead.ExposureTime = [];
dcmhead.XrayTubeCurrent = [];
dcmhead.Exposure = [];
dcmhead.ExposureInuAs = [];
dcmhead.FilterType = '';
dcmhead.GeneratorPower = [];
dcmhead.CollimatorGridName = '';
dcmhead.FocalSpot = [];
dcmhead.DateOfLastCalibration = '';
dcmhead.TimeOfLastCalibration = '';
dcmhead.PlateType = '';
dcmhead.PhosphorType = '';
dcmhead.AcquisitionMatrix = uint16([dimx 0 0 dimy])';
dcmhead.FlipAngle = parameters.flipanglearray(j);           % FLIP ANGLES
dcmhead.AcquisitionDeviceProcessingDescription = '';
dcmhead.CassetteOrientation = 'PORTRAIT';
dcmhead.CassetteSize = '25CMX25CM';
dcmhead.ExposuresOnPlate = 0;
dcmhead.RelativeXrayExposure = [];
dcmhead.AcquisitionComments = '';
dcmhead.PatientPosition = 'HFS';
dcmhead.Sensitivity = [];
dcmhead.FieldOfViewOrigin = [];
dcmhead.FieldOfViewRotation = [];
dcmhead.AcquisitionDuration = acq_dur;
dcmhead.StudyInstanceUID = dcmid(1:18);
dcmhead.SeriesInstanceUID = [dcmid(1:18),'.',num2str(parameters.filename)];
dcmhead.StudyID = '01';
dcmhead.SeriesNumber = parameters.filename;
dcmhead.AcquisitionNumber = 1;
dcmhead.InstanceNumber = filecounter;          
dcmhead.ImagePositionPatient = [-parameters.FOV/2 -(parameters.aratio*parameters.FOV/2) (z-round(parameters.NO_SLICES/2))*(parameters.SLICE_SEPARATION/parameters.SLICE_INTERLEAVE)]';
dcmhead.ImageOrientationPatient = [1.0, 0.0, 0.0, 0.0, 1.0, 0.0]';
dcmhead.FrameOfReferenceUID = '';
dcmhead.TemporalPositionIdentifier = i;
dcmhead.NumberOfTemporalPositions = parameters.nr_frames;
dcmhead.TemporalResolution = parameters.timeperframe;
dcmhead.ImagesInAcquisition = parameters.NO_SLICES;
dcmhead.SliceLocation = (z-round(parameters.NO_SLICES/2))*(parameters.SLICE_SEPARATION/parameters.SLICE_INTERLEAVE);
dcmhead.ImageComments = '';
dcmhead.TemporalPositionIndex = uint32([]);
dcmhead.SamplesPerPixel = 1;
dcmhead.PhotometricInterpretation = 'MONOCHROME2';
dcmhead.PlanarConfiguration = 0;
dcmhead.Rows = dimy;
dcmhead.Columns = dimx;
dcmhead.PixelSpacing = [pixely pixelx]';
dcmhead.PixelAspectRatio = parameters.aratio;
dcmhead.BitsAllocated = 16;
dcmhead.BitsStored = 15;
dcmhead.HighBit = 14;
dcmhead.PixelRepresentation = 0;
dcmhead.PixelPaddingValue = 0;
dcmhead.RescaleIntercept = 0;
dcmhead.RescaleSlope = 1;
dcmhead.HeartRate = 0;
dcmhead.NumberOfSlices = parameters.NO_SLICES;
dcmhead.CardiacNumberOfImages = 1;
dcmhead.MRAcquisitionType = parameters.dimensionality;
dcmhead.ScanOptions = 'CG';
dcmhead.BodyPartExamined = '';


dicom_header = dcmhead;


end


