

clc
close all
clear all

 
 
%% read captured images
imagesDir='data\flowers60\';
exts = {'.jpg','.bmp','.png'};
pristineImages = imageDatastore(imagesDir,'FileExtensions',exts,'LabelSource','foldernames');

numGT=numel(pristineImages.Files); % 采集图片的数量,图片的像素大小必须全部统一一样

% 首先是线性插值实现视点合成，在经过相位检索优化生成新视点的质量
Nviews=2/2;  % 合成视点的倍数，生成的视点数量为：2*Nviews*（numGT-1），因为插值生成新视点的时候是两个相邻视点插值得到numGT个视点有numGT-1个插值区间

for j=1:1:numGT 
    if(j==numGT)
    inputImage1 = im2double(readimage(pristineImages,j-1)); % 取前一张图片
    inputImage2 = im2double(readimage(pristineImages,j));% 取相邻的后一张图片
    else
         inputImage1 = im2double(readimage(pristineImages,j)); % 取前一张图片
    inputImage2 = im2double(readimage(pristineImages,j+1));% 取相邻的后一张图片   
    end
    
    %采用超分的思路，把每个视点的三个通道分别插值重构处理
    %使用 rgb2ycbcr 函数将采集得到的视点图像从 RGB 颜色空间转换为亮度 (Iy) 和色度（Icb 和 Icr）通道。
    Iycbcr1 = rgb2ycbcr(inputImage1);
    Iy1 = Iycbcr1(:,:,1);
    Icb1 = Iycbcr1(:,:,2);
    Icr1 = Iycbcr1(:,:,3);
    
    Iycbcr2 = rgb2ycbcr(inputImage2);
    Iy2 = Iycbcr2(:,:,1);
    Icb2 = Iycbcr2(:,:,2);
    Icr2 = Iycbcr2(:,:,3);
    [n1,n2,n3]=size(inputImage2);
    for nL=1:1:n1
        for nR=1:1:n2
            %对于采集到的每个多视点，使用双三次插值扩增亮度通道和两个色度通道。采集多视点图像的色度通道 Icb_bicubic 和 Icr_bicubic 不需要进一步处理。
            IytwoPixel(1,1)=Iy1(nL,nR);
            IytwoPixel(2,1)=Iy2(nL,nR);
            Iybicubic = imresize(IytwoPixel,[2*Nviews 1],'bicubic'); % 两个像素之间的插值，实现视点单个像素的合成
            IcbtwoPixel(1,1)=Icb1(nL,nR);
            IcbtwoPixel(2,1)=Icb2(nL,nR);
            Icbbicubic  = imresize(IcbtwoPixel,[2*Nviews 1],'bicubic'); % 两个像素之间的插值，实现视点单个像素的合成
            IcrtwoPixel(1,1)=Icr1(nL,nR);
            IcrtwoPixel(2,1)=Icr2(nL,nR);
            Icrbicubic  = imresize(IcrtwoPixel,[2*Nviews 1],'bicubic'); % 两个像素之间的插值，实现视点单个像素的合成            
            for kk=1:1:2*Nviews 
                IyRendered((j-1)*(2*Nviews)+kk,nL,nR)=Iybicubic(kk);
                IcbRendered((j-1)*(2*Nviews)+kk,nL,nR)=Icbbicubic(kk);
                IcrRendered((j-1)*(2*Nviews)+kk,nL,nR)=Icrbicubic(kk);  
            end
        end
    end   
end
 
weightinput=1;

[Numnovel,n1,n2,n3]=size(IcrRendered); % 计算合成视点数量
for num=1:1:Numnovel
    
    %对扩增的亮度分量 Iy_bicubic 应用经过相位检索。输出是合成新视点所需的残差图像。
    %IresidualRendered = activations(net,IyRendered(num,:,:,1),41);
    inputImage= IyRendered(num,:,:);
    [IresidualRendered]=PhaseRetrieval(inputImage);  % 相位检索函数
    %[IresidualRendered]=Weightsfun(IresidualRendered,weightinput);
    IresidualRendered = squeeze(double(IresidualRendered))./1000000;
    %将残差图像与扩增的亮度分量相加，得到合成新视点的 亮度分量。 
    
    Isr = squeeze(IyRendered(num,:,:)) + IresidualRendered;
    %将新视点 亮度分量与扩增的颜色分量串联起来。使用 ycbcr2rgb 函数将图像转换为 RGB 颜色空间。结果为 得到的重构最终彩色新视点。
   %% novel view reconstruction
    novelView = ycbcr2rgb(cat(3,Isr,squeeze(IcbRendered(num,:,:)),squeeze(IcrRendered(num,:,:))));
    figure
    imshow(novelView)
    title('rendered view')
 
    % 保存重构的新视点
    if 100<num
        imwrite(novelView,['renderResults\Flowers\flowers0',num2str(num-1),'.jpg']);
    elseif (10<num)&&(num<101)
        imwrite(novelView,['renderResults\Flowers\flowers00',num2str(num-1),'.jpg']);
    else
        imwrite(novelView,['renderResults\Flowers\flowers000',num2str(num-1),'.jpg']);
    end
    
end
