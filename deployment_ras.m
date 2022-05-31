fs = 16000;
classificationRate = 10;
samplesPerCapture = fs/classificationRate;

segmentDuration = 1;
segmentSamples = round(segmentDuration*fs);

frameDuration = 0.025;
frameSamples = round(frameDuration*fs);

hopDuration = 0.010;
hopSamples = round(hopDuration*fs);

numSpectrumPerSpectrogram = floor((segmentSamples-frameSamples)/hopSamples) + 1;

afe = audioFeatureExtractor( ...
    'SampleRate',fs, ...
    'FFTLength',512, ...
    'Window',hann(frameSamples,'periodic'), ...
    'OverlapLength',frameSamples - hopSamples, ...
    'barkSpectrum',true);

numBands = 50;
setExtractorParams(afe,'barkSpectrum','NumBands',numBands,'WindowNormalization',false);

numElementsPerSpectrogram = numSpectrumPerSpectrogram*numBands;

load('gkc_net4.mat') %该网络为NetTraining.m训练得到的神经网络
labels = trainedNet.Layers(end).Classes;
NumLabels = numel(labels);
BackGroundIdx = find(labels == 'background'); 

probBuffer = single(zeros([NumLabels,classificationRate/2]));
YBuffer = single(NumLabels * ones(1, classificationRate/2)); 

countThreshold = ceil(classificationRate*0.2);
probThreshold = single(0.7);

adr = audioDeviceReader('SampleRate',fs,'SamplesPerFrame',samplesPerCapture,'OutputDataType','single');
audioBuffer = dsp.AsyncBuffer(fs);

%matrixViewer = dsp.MatrixViewer("ColorBarLabel","Power per band (dB/Band)",...
%    "XLabel","Frames",...
%    "YLabel","Bark Bands", ...
%    "Position",[400 100 600 250], ...
%    "ColorLimits",[-4 2.6445], ...
%    "AxisOrigin","Lower left corner", ...
%    "Name","Speech Command Recognition using Deep Learning");

timeScope = timescope("SampleRate",fs, ...
    "YLimits",[-1 1], ...
    "Position",[400 380 600 250], ...
    "Name","Speech Command Recognition Using Deep Learning", ...
    "TimeSpanSource","Property", ...
    "TimeSpan",1, ...
    "BufferLength",fs, ...
    "YLabel","Amplitude", ...
    "ShowGrid",true);
show(timeScope);

timeLimit = 10;

tic
while isVisible(timeScope) && toc < timeLimit
    % Capture audio
    x = adr();
    write(audioBuffer,x);
    y = read(audioBuffer,fs,fs-samplesPerCapture);
    
    % Compute auditory features
    features = extract(afe,y);
    auditoryFeatures = log10(features + 1e-6);
    
    % Perform prediction
    probs = predict(trainedNet, auditoryFeatures);      
    [~, YPredicted] = max(probs);
    
    % Perform statistical post processing
    YBuffer = [YBuffer(2:end),YPredicted];
    probBuffer = [probBuffer(:,2:end),probs(:)];

    [YModeIdx, count] = mode(YBuffer);
    maxProb = max(probBuffer(YModeIdx,:));

    if YModeIdx == single(BackGroundIdx) || single(count) < countThreshold || maxProb < probThreshold
        speechCommandIdx = BackGroundIdx;
    else
        speechCommandIdx = YModeIdx;
    end
    
    % Update plots
    %matrixViewer(auditoryFeatures');
    timeScope(x);

    if (speechCommandIdx == BackGroundIdx)
        timeScope.Title = ' ';
    else
        timeScope.Title = char(labels(speechCommandIdx));
    end
    drawnow limitrate 
end   

%hide(matrixViewer)
hide(timeScope)

generateMATLABFunction(afe,'extractSpeechFeatures')
hostIPAddress = coder.Constant('10.164.67.248');
cfg = coder.config('exe');
cfg.TargetLang = 'C++';
dlcfg = coder.DeepLearningConfig('arm-compute');
dlcfg.ArmArchitecture = 'armv7';
dlcfg.ArmComputeVersion = '19.05';
cfg.DeepLearningConfig = dlcfg;
r = raspi('10.164.109.175','pi','raspberry');
hw = coder.hardware('Raspberry Pi');
cfg.Hardware = hw;
buildDir = '~/remoteBuildDir';
cfg.Hardware.BuildDir = buildDir;
cfg.GenerateExampleMain = 'GenerateCodeAndCompile';
codegen -config cfg HelperSpeechCommandRecognitionRasPi -args {hostIPAddress} -report -v

applicationName = 'HelperSpeechCommandRecognitionRasPi';

applicationDirPaths = raspi.utils.getRemoteBuildDirectory('applicationName',applicationName);
targetDirPath = applicationDirPaths{1}.directory;

exeName = strcat(applicationName,'.elf');
command = ['cd ' targetDirPath '; ./' exeName ' &> 1 &'];

system(r,command);

targetIPAddress = '10.164.109.175';
UDPSend = dsp.UDPSender('RemoteIPPort',26000,'RemoteIPAddress',targetIPAddress); 

sizeOfFloatInBytes = 4;
maxUDPMessageLength = floor(65507/sizeOfFloatInBytes);
samplesPerPacket = 1 + numElementsPerSpectrogram; 
numPackets = floor(maxUDPMessageLength/samplesPerPacket);
bufferSize = numPackets*samplesPerPacket*sizeOfFloatInBytes;

UDPReceive = dsp.UDPReceiver("LocalIPPort",21000, ...  
    "MessageDataType","single", ...
    "MaximumMessageLength",samplesPerPacket, ...
    "ReceiveBufferSize",bufferSize);

UDPSend(zeros(samplesPerCapture,1,"single"));

show(timeScope)

timeLimit = 20;

tic
while isVisible(timeScope) && toc < timeLimit
    % Capture audio and send that to RasPi
    x = adr();
    UDPSend(x);
    
    % Receive data packet from RasPi
    udpRec = UDPReceive();
    
    if ~isempty(udpRec)
        % Extract predicted index, the last sample of received UDP packet
        speechCommandIdx = udpRec(end); 
        
        % Extract auditory spectrogram
        spec = reshape(udpRec(1:numElementsPerSpectrogram), [numBands, numSpectrumPerSpectrogram]);
        
        % Display time domain signal and auditory spectrogram    
        timeScope(x)
        
        if speechCommandIdx == BackGroundIdx
            timeScope.Title = ' ';
        else
            timeScope.Title = char(labels(speechCommandIdx));
        end
        
        drawnow limitrate 
    end
end

hide(timeScope)
stopExecutable(codertarget.raspi.raspberrypi,exeName)

release(UDPSend)
release(UDPReceive)



