%rpi = raspi('10.164.109.175','pi','raspberry');
mypi = rpi;
%showPins(mypi);
configurePin(mypi,18,'DigitalOutput');
configurePin(mypi,24,'DigitalOutput');
configurePin(mypi,23,'DigitalOutput');
configurePin(mypi,25,'DigitalOutput');

timeLimit1 = 0.85;
timeLimit2 = 1;
timeLimit3 = 5;
tmp_label = " ";

writeDigitalPin(mypi,23,0);
writeDigitalPin(mypi,25,0);

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

load('gkc_net4.mat')
labels = trainedNet.Layers(end).Classes;
NumLabels = numel(labels);
BackGroundIdx = find(labels == 'background');

probBuffer = single(zeros([NumLabels,classificationRate/2]));
YBuffer = single(NumLabels * ones(1, classificationRate/2));

countThreshold = ceil(classificationRate*0.2);
probThreshold = single(0.7);

adr = audioDeviceReader('SampleRate',fs,'SamplesPerFrame',samplesPerCapture,'OutputDataType','single');
audioBuffer = dsp.AsyncBuffer(fs);

timeScope = timescope("SampleRate",fs, ...
    "YLimits",[-1 1], ...
    "Position",[400 380 600 250], ...
    "Name","Speech Command Recognition Using Deep Learning", ...
    "TimeSpanSource","Property", ...
    "TimeSpan",1, ...
    "BufferLength",fs, ...
    "YLabel","Amplitude", ...
    "ShowGrid",true);

timeLimit = 20;
fprintf("begin");
tic
for i = 1:200

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

    if labels(speechCommandIdx) == tmp_label
        continue;
    end

    disp(labels(speechCommandIdx));

    if char(labels(speechCommandIdx)) == "go"
        tic
        while  toc < timeLimit3
            writeDigitalPin(mypi,18,1);
            writeDigitalPin(mypi,24,1);
        end

        writeDigitalPin(mypi,18,0);
        writeDigitalPin(mypi,24,0);
    end

    if char(labels(speechCommandIdx)) == "off"
        tic
        writeDigitalPin(mypi,18,0);
        writeDigitalPin(mypi,24,0);
        while  toc < timeLimit3
            writeDigitalPin(mypi,23,1);
            writeDigitalPin(mypi,25,1);
        end

        writeDigitalPin(mypi,23,0);
        writeDigitalPin(mypi,25,0);
    end

    if char(labels(speechCommandIdx)) == "right"
        tic

        while  toc < timeLimit1
            writeDigitalPin(mypi,18,1);
        end

        while  toc < timeLimit2
            writeDigitalPin(mypi,24,1);
        end

        while  toc < timeLimit3
            writeDigitalPin(mypi,18,1);
            writeDigitalPin(mypi,24,1);
        end

        writeDigitalPin(mypi,18,0);
        writeDigitalPin(mypi,24,0);

    end

    if char(labels(speechCommandIdx)) == "left"
        tic

        while  toc < timeLimit1
            writeDigitalPin(mypi,24,1);
        end

        while  toc < timeLimit2
            writeDigitalPin(mypi,18,1);
        end

        while  toc < timeLimit3
            writeDigitalPin(mypi,18,1);
            writeDigitalPin(mypi,24,1);
        end

        writeDigitalPin(mypi,18,0);
        writeDigitalPin(mypi,24,0);
    end

    if (char(labels(speechCommandIdx)) == "stop") || (char(labels(speechCommandIdx)) =="background")
        writeDigitalPin(mypi,18,0);
        writeDigitalPin(mypi,24,0);
    end
    if char(labels(speechCommandIdx)) == "one"
        error_x=0;
        time_x=0;
        for m =1:5
            img = snapshot(cam);
        end
        disp("begin blue");
        for n = 1:10
            img = snapshot(cam);
            img = getcolor(img,"blue");
            img_grey = rgb2gray(img);
            [y,x]=find(img_grey~=255);
            if size(x,1)>40 && size(y,1)>40
                xx = round(mean(x));
                error_x=xx-160;
                time_x=abs(error_x)/280;
                if time_x>=0.1
                    if error_x>0
                        turnright(mypi,time_x);
                        disp("right")
                        break;
                    end
                    if error_x<0
                        turnleft(mypi,time_x);
                        disp("left")
                        break;
                    end
                end
            end
        end
    end

    if char(labels(speechCommandIdx)) == "three"
        error_x=0;
        time_x=0;
        for m =1:5
            img = snapshot(cam);
        end
        disp("begin green");
        for n = 1:5
            img = snapshot(cam);
            img = getcolor(img,"green");
            img_grey = rgb2gray(img);
            [y,x]=find(img_grey~=255);
            if size(x,1)>40 && size(y,1)>40
                xx = round(mean(x));
                error_x=xx-160;
                time_x=abs(error_x)/280;
                if time_x>=0.1
                    if error_x>0
                        turnright(mypi,time_x);
                        disp("right")
                        break;
                    end
                    if error_x<0
                        turnleft(mypi,time_x);
                        disp("left")
                        break;
                    end
                end
            end
        end
    end

    if char(labels(speechCommandIdx)) == "two"
        error_x=0;
        time_x=0;
        for m =1:5
            img = snapshot(cam);
        end
        disp("begin red");
        for n = 1:10
            img = snapshot(cam);
            img = getcolor(img,"red");
            img_grey = rgb2gray(img);
            [y,x]=find(img_grey~=255);
            if size(x,1)>40 && size(y,1)>40
                xx = round(mean(x));
                error_x=xx-160;
                time_x=abs(error_x)/280;
                if time_x>=0.1
                    if error_x>0
                        turnright(mypi,time_x);
                        disp("right")
                        break;
                    end
                    if error_x<0
                        turnleft(mypi,time_x);
                        disp("left")
                        break;
                    end
                end
            end
        end
    end

    tmp_label = labels(speechCommandIdx);

end

%system(rpi,'sudo shutdown -h now');
