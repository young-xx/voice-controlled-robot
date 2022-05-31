function [getcolor]=getcolor(picture,color)

flag_hsv = rgb2hsv(picture); % 将图像的rgb色彩空间转化至hsv色彩空间
flag_new = 255*ones(size(picture));% 创建一个白色图像，将特定颜色提取到此处
flag_new_hsv = rgb2hsv(flag_new);% 将该图像转至hsv色彩空间

%提取特定颜色部分
if color =="blue"
    [row, col] = ind2sub(size(flag_hsv),find((flag_hsv(:,:,1)>0.55 & flag_hsv(:,:,1)< 0.69)&flag_hsv(:,:,2)>0.17 & flag_hsv(:,:,3)>0.18));
elseif color == "yellow"
    [row, col] = ind2sub(size(flag_hsv),find(flag_hsv(:,:,1)>0.11 & flag_hsv(:,:,1)< 0.15 & flag_hsv(:,:,2)>0.16 & flag_hsv(:,:,3)>0.18));
elseif color == "red"
    [row, col] = ind2sub(size(flag_hsv),find((flag_hsv(:,:,1)>0.00 & flag_hsv(:,:,1)< 0.03) |( flag_hsv(:,:,1)>0.95 & flag_hsv(:,:,1)<1)&flag_hsv(:,:,2)>0.16 & flag_hsv(:,:,3)>0.18));
elseif color == "green"
    [row, col] = ind2sub(size(flag_hsv),find(flag_hsv(:,:,1)>0.15 & flag_hsv(:,:,1)< 0.48 & flag_hsv(:,:,2)>0.16 & flag_hsv(:,:,3)>0.18));
end
% 将图像中的特定颜色像素复制到刚才新建的白色图像中
for i = 1 : length(row)
    flag_new_hsv(row(i),col(i),:) = flag_hsv(row(i),col(i),:);
end
getcolor = im2uint8(hsv2rgb(flag_new_hsv));


end