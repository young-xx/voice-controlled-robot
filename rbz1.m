function rbz1(mypi,SL,SR)
    if SL==0&&SR==0
        writeDigitalPin(mypi,23,1);
        writeDigitalPin(mypi,18,0);
        writeDigitalPin(mypi,25,1);
        writeDigitalPin(mypi,24,0);
        system(mypi, 'sleep 0.1');
        writeDigitalPin(mypi,23,0);
        writeDigitalPin(mypi,18,0);
        writeDigitalPin(mypi,25,1);
        writeDigitalPin(mypi,24,0);
        system(mypi, 'sleep 0.2');
        writeDigitalPin(mypi,23,0);
        writeDigitalPin(mypi,18,0);
        writeDigitalPin(mypi,25,0);
        writeDigitalPin(mypi,24,0);
        system(mypi, 'sleep 0.5');
    elseif SL == 0&&SR ==1
        writeDigitalPin(mypi,23,1);
        writeDigitalPin(mypi,18,0);
        writeDigitalPin(mypi,25,1);
        writeDigitalPin(mypi,24,0);
        system(mypi, 'sleep 0.1');
        writeDigitalPin(mypi,23,0);
        writeDigitalPin(mypi,18,1);
        writeDigitalPin(mypi,25,1);
        writeDigitalPin(mypi,24,0);
        system(mypi, 'sleep 0.2');
        writeDigitalPin(mypi,23,0);
        writeDigitalPin(mypi,18,0);
        writeDigitalPin(mypi,25,0);
        writeDigitalPin(mypi,24,0);
        system(mypi, 'sleep 0.5');
    elseif SL == 1&&SR ==0
         writeDigitalPin(mypi,23,1);
        writeDigitalPin(mypi,18,0);
        writeDigitalPin(mypi,25,1);
        writeDigitalPin(mypi,24,0);
        system(mypi, 'sleep 0.1');
        writeDigitalPin(mypi,23,1);
        writeDigitalPin(mypi,18,0);
        writeDigitalPin(mypi,25,0);
        writeDigitalPin(mypi,24,1);
        system(mypi, 'sleep 0.2');
        writeDigitalPin(mypi,23,0);
        writeDigitalPin(mypi,18,0);
        writeDigitalPin(mypi,25,0);
        writeDigitalPin(mypi,24,0);
        system(mypi, 'sleep 0.5');
    end
end