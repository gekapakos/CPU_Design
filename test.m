% Step 1: Read the JPEG image
rgbImage = imread('lenna.jpeg');

% Step 2: Check if the image is an RGB image
if size(rgbImage, 3) ~= 3
    print('The input image is not an RGB image.');
end

% Step 3: Convert the RGB image to an indexed image with a colormap
[indexedImage, colormap] = rgb2ind(rgbImage, 256);  % 256 is the number of colors in the colormap

% Step 4: Display the indexed image with its colormap
imshow(indexedImage, colormap);

% Step 5: Save the indexed image with its colormap
imwrite(indexedImage, colormap, 'indexed_image.jpeg');
