function turnright(mypi,time)
tic

while  toc < time
    writeDigitalPin(mypi,18,1);

end
while  toc < time+0.3
    writeDigitalPin(mypi,24,1);
end
writeDigitalPin(mypi,24,0);
writeDigitalPin(mypi,18,0);
end