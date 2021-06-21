clear all 
clc ;
%[file,path] = uigetfile('*.m');
[file,path] = uigetfile('*.*');
if isequal(file,0)
   disp('User selected Cancel');
else
   disp(['User selected ', fullfile(path,file)]);
end



I = imread(fullfile(path,file));
figure; imshow(I); title('Original Image')

colorImage = imgaussfilt(I,[8 8]);
%colorImage = imgaussfilt(I,0.6);

figure; imshow(colorImage); title('Original Image after blurring')

grayImage = rgb2gray(colorImage);
mserRegions = detectMSERFeatures(grayImage,'RegionAreaRange',[400 8000]);
mserRegionsPixels = vertcat(cell2mat(mserRegions.PixelList));  % extract regions
figure; imshow(colorImage); hold on;
plot(mserRegions, 'showPixelList', true,'showEllipses',false);
title('MSER Regions');
mserMask = false(size(grayImage));
ind = sub2ind(size(mserMask), mserRegionsPixels(:,2), mserRegionsPixels(:,1));
mserMask(ind) = true;
edgeMask = edge(grayImage, 'Sobel');
edgeAndMSERIntersection = edgeMask & mserMask; 
figure; imshowpair(edgeMask, edgeAndMSERIntersection, 'montage'); 
title('Sobel edges and intersection of sobel edges with MSER regions')
figure
BWnobord = imclearborder(edgeAndMSERIntersection,4);
imshow(BWnobord)
title('Cleared Border Image')
figure
se90 = strel('line',3,90);
se0 = strel('line',3,0);
BWsdil = imdilate(edgeAndMSERIntersection,[se90 se0]);
imshow(BWsdil)
title('Dilated Gradient Mask')
figure
BWdfill = imfill(BWsdil,'holes');
imshow(BWdfill);
title('Binary Image with Filled Holes')
st = regionprops(BWdfill, 'BoundingBox', 'Area' );
t = st(1).BoundingBox;
xmin = t(1);
ymin = t(2);
xmax = t(3);
ymax = t(4);
for k = 2 : length(st)
  thisBB = st(k).BoundingBox;
  x1 = thisBB(1);
  y1 = thisBB(2);
  x2 = x1 + thisBB(3);
  y2 = y1 + thisBB(4);
  if x1 < xmin
       xmin = x1;
  end
  if y1 < ymin
      ymin = y1;
  end
  if x2 > xmax
      xmax = x2;
  end
  if y2 > ymax
      ymax = y2;
  end
end
boundary = [xmin,ymin,xmax-xmin,ymax-ymin];
figure
imshow(I);
title('Original Image with Recognized Text Area ');
rectangle('Position',boundary ,'EdgeColor','r','LineWidth',2 )
results = ocr(I,boundary);
msgbox(results.Text,'Extracted Text from Image','success');
