clc
clear


images = load_images('images2');

%Translations = [250 14; 227 6; 350 22; 241 11];

%Translations = [250 14; 227 -66; 350 22; 241 11];

Translations = [250 14; -327 -66; 350 22; 241 11];


[ Layered_FinalImg_Y, Layered_FinalImg_RGB, Layered_FinalImg_Mask] = create_layered_images( images, Translations );



figure(1)
imshow(Layered_FinalImg_RGB(:,:,:,1))

figure(2)
imshow(Layered_FinalImg_Y(:,:,3))

figure(3)
imshow(Layered_FinalImg_Y(:,:,4))

figure(4)
imshow(Layered_FinalImg_Mask(:,:,5))
