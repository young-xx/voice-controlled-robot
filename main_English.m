%rpi = raspi('192.168.1.110','pi','raspberry');
mypi = raspi();
EN_num = ["one","two","three","four","five"];
configurePin(mypi,18,'DigitalOutput');
configurePin(mypi,24,'DigitalOutput');
configurePin(mypi,23,'DigitalOutput');
configurePin(mypi,25,'DigitalOutput');
configurePin(mypi,21,'DigitalInput');
configurePin(mypi,12,'DigitalInput');
configurePin(mypi,20,'DigitalInput');
configurePin(mypi,16,'DigitalInput');
cam = webcam(mypi);
timeLimit1 = 1;
timeLimit2 = 1;
timeLimit3 = 1;
tmp_label = " ";

%writeDigitalPin(mypi,23,0);
%writeDigitalPin(mypi,25,0);
Fs = 16000;
global url_use

if isempty(url_use)==1
    api_id = 'KhcIeegjzPZ6TnM3NoLHHPaB'; % Replace the api key
    secret_key = 'n4OxXPM3uG5MqZg0tze3qOGZCARO0WLF'; % Replace the secret key
    url_0 = ['https://openapi.baidu.com/oauth/2.0/token?grant_type=client_credentials&client_id=',api_id,'&client_secret=',secret_key];
    url_cont = webread(url_0);
    url_use = url_cont.access_token;
end
recObj = audiorecorder(Fs,16,1,1);
url= 'http://vop.baidu.com/server_api';


for i = 1:5
    fprintf("begin");
    % Capture audio

    recordblocking(recObj,3);
    Voice = getaudiodata(recObj);

    y = Voice(:,1);
    [P,Q] = rat(1);
    y = resample(y,P,Q);
    wavFilename = 'WavFile.wav';
    audiowrite(wavFilename,y,Fs);

    [base64string,base64string_len] = base64file('WavFile.wav');
    options = weboptions('RequestMethod', 'post','HeaderFields',{ 'Content-Type','application/json'});
    options.Timeout =20;
    m = struct;
    m.format = 'wav';
    m.dev_pid = 1737;
    m.token = url_use;
    m.len = base64string_len;
    m.rate = 16000;
    m.speech = base64string;
    m.cuid = 'test';
    m.channel = 1;
    Content = webwrite(url,m,options);
    if isfield(Content,'result')
        txt = Content.result{:}
    else
        txt = ''
    end
    S = regexp(txt, '\s+', 'split');
    direction1 = char(S(1));
    direction2 = char(S(2));

    if direction1 == "go" && direction2 == "ahead"
        meter = 1;
        tic
        while  toc < meter + 0.3
            writeDigitalPin(mypi,18,1);
            writeDigitalPin(mypi,24,1);
            SL=readDigitalPin(mypi,16);
            SR=readDigitalPin(mypi,21);
            if SL==0||SR==0
                rbz1(mypi,SL,SR);
            end
        end
        writeDigitalPin(mypi,18,0);
        writeDigitalPin(mypi,24,0);
    end

    if direction1 == "go" && direction2 == "back"
        meter = 1;
        tic
        writeDigitalPin(mypi,18,0);
        writeDigitalPin(mypi,24,0);
        while  toc < meter+0.3
            writeDigitalPin(mypi,23,1);
            writeDigitalPin(mypi,25,1);
        end
        writeDigitalPin(mypi,23,0);
        writeDigitalPin(mypi,25,0);
    end

    if direction1 == "turn" && direction2 == "right"

        writeDigitalPin(mypi,18,1);
        writeDigitalPin(mypi,23,0);
        writeDigitalPin(mypi,24,0);
        writeDigitalPin(mypi,25,1);
        pause(timeLimit1);
        writeDigitalPin(mypi,18,0);
        writeDigitalPin(mypi,24,0);
        writeDigitalPin(mypi,23,0);
        writeDigitalPin(mypi,25,0);
    end

    if direction1 == "turn" && direction2 == "left"
        writeDigitalPin(mypi,18,0);
        writeDigitalPin(mypi,23,1);
        writeDigitalPin(mypi,24,1);
        writeDigitalPin(mypi,25,0);
        pause(timeLimit1);
        writeDigitalPin(mypi,18,0);
        writeDigitalPin(mypi,24,0);
        writeDigitalPin(mypi,23,0);
        writeDigitalPin(mypi,25,0);
    end

    if direction1 == "parking"
        writeDigitalPin(mypi,18,1);
        writeDigitalPin(mypi,23,0);
        writeDigitalPin(mypi,24,1);
        writeDigitalPin(mypi,25,0);
        system(mypi, 'sleep 0.2');

        if readDigitalPin(mypi,20)==1
            writeDigitalPin(mypi,18,0);
            writeDigitalPin(mypi,23,0);
            writeDigitalPin(mypi,24,0);
            writeDigitalPin(mypi,25,1);
            system(mypi, 'sleep 0.4');
            writeDigitalPin(mypi,18,0);
            writeDigitalPin(mypi,23,1);
            writeDigitalPin(mypi,24,0);
            writeDigitalPin(mypi,25,0);
            system(mypi, 'sleep 0.4');
        end
        if readDigitalPin(mypi,12)==1
            writeDigitalPin(mypi,18,0);
            writeDigitalPin(mypi,23,1);
            writeDigitalPin(mypi,24,0);
            writeDigitalPin(mypi,25,0);
            system(mypi, 'sleep 0.4');
            writeDigitalPin(mypi,18,0);
            writeDigitalPin(mypi,23,0);
            writeDigitalPin(mypi,24,0);
            writeDigitalPin(mypi,25,1);
            system(mypi, 'sleep 0.4');
        end
        writeDigitalPin(mypi,18,1);
        writeDigitalPin(mypi,23,0);
        writeDigitalPin(mypi,24,0);
        writeDigitalPin(mypi,25,1);
        system(mypi, 'sleep 1.2');
        writeDigitalPin(mypi,18,0);
        writeDigitalPin(mypi,23,1);
        writeDigitalPin(mypi,24,0);
        writeDigitalPin(mypi,25,1);
        system(mypi, 'sleep 1.2');
        writeDigitalPin(mypi,18,0);
        writeDigitalPin(mypi,23,0);
        writeDigitalPin(mypi,24,0);
        writeDigitalPin(mypi,25,0);
    end

    if direction1 == "blue"
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

    if direction1 == "green"
        error_x=0;
        time_x=0;
        for m =1:5
            img = snapshot(cam);
        end
        disp("begin green");
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

    if direction1 == "red"
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

    fprintf("end \n");
end
function [base64string,base64string_len] = base64file(file)
fid = fopen(file,'rb');
bytes = fread(fid);
fclose(fid);
base64string_len = size(bytes,1);
encoder = org.apache.commons.codec.binary.Base64;
base64string = char(encoder.encode(bytes))';
end
%system(rpi,'sudo shutdown -h now');


