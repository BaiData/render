

clc
close all
clear all

 
 
%% read captured images
imagesDir='data\flowers60\';
exts = {'.jpg','.bmp','.png'};
pristineImages = imageDatastore(imagesDir,'FileExtensions',exts,'LabelSource','foldernames');

numGT=numel(pristineImages.Files); % �ɼ�ͼƬ������,ͼƬ�����ش�С����ȫ��ͳһһ��

% ���������Բ�ֵʵ���ӵ�ϳɣ��ھ�����λ�����Ż��������ӵ������
Nviews=2/2;  % �ϳ��ӵ�ı��������ɵ��ӵ�����Ϊ��2*Nviews*��numGT-1������Ϊ��ֵ�������ӵ��ʱ�������������ӵ��ֵ�õ�numGT���ӵ���numGT-1����ֵ����

for j=1:1:numGT 
    if(j==numGT)
    inputImage1 = im2double(readimage(pristineImages,j-1)); % ȡǰһ��ͼƬ
    inputImage2 = im2double(readimage(pristineImages,j));% ȡ���ڵĺ�һ��ͼƬ
    else
         inputImage1 = im2double(readimage(pristineImages,j)); % ȡǰһ��ͼƬ
    inputImage2 = im2double(readimage(pristineImages,j+1));% ȡ���ڵĺ�һ��ͼƬ   
    end
    
    %���ó��ֵ�˼·����ÿ���ӵ������ͨ���ֱ��ֵ�ع�����
    %ʹ�� rgb2ycbcr �������ɼ��õ����ӵ�ͼ��� RGB ��ɫ�ռ�ת��Ϊ���� (Iy) ��ɫ�ȣ�Icb �� Icr��ͨ����
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
            %���ڲɼ�����ÿ�����ӵ㣬ʹ��˫���β�ֵ��������ͨ��������ɫ��ͨ�����ɼ����ӵ�ͼ���ɫ��ͨ�� Icb_bicubic �� Icr_bicubic ����Ҫ��һ������
            IytwoPixel(1,1)=Iy1(nL,nR);
            IytwoPixel(2,1)=Iy2(nL,nR);
            Iybicubic = imresize(IytwoPixel,[2*Nviews 1],'bicubic'); % ��������֮��Ĳ�ֵ��ʵ���ӵ㵥�����صĺϳ�
            IcbtwoPixel(1,1)=Icb1(nL,nR);
            IcbtwoPixel(2,1)=Icb2(nL,nR);
            Icbbicubic  = imresize(IcbtwoPixel,[2*Nviews 1],'bicubic'); % ��������֮��Ĳ�ֵ��ʵ���ӵ㵥�����صĺϳ�
            IcrtwoPixel(1,1)=Icr1(nL,nR);
            IcrtwoPixel(2,1)=Icr2(nL,nR);
            Icrbicubic  = imresize(IcrtwoPixel,[2*Nviews 1],'bicubic'); % ��������֮��Ĳ�ֵ��ʵ���ӵ㵥�����صĺϳ�            
            for kk=1:1:2*Nviews 
                IyRendered((j-1)*(2*Nviews)+kk,nL,nR)=Iybicubic(kk);
                IcbRendered((j-1)*(2*Nviews)+kk,nL,nR)=Icbbicubic(kk);
                IcrRendered((j-1)*(2*Nviews)+kk,nL,nR)=Icrbicubic(kk);  
            end
        end
    end   
end
 
weightinput=1;

[Numnovel,n1,n2,n3]=size(IcrRendered); % ����ϳ��ӵ�����
for num=1:1:Numnovel
    
    %�����������ȷ��� Iy_bicubic Ӧ�þ�����λ����������Ǻϳ����ӵ�����Ĳв�ͼ��
    %IresidualRendered = activations(net,IyRendered(num,:,:,1),41);
    inputImage= IyRendered(num,:,:);
    [IresidualRendered]=PhaseRetrieval(inputImage);  % ��λ��������
    %[IresidualRendered]=Weightsfun(IresidualRendered,weightinput);
    IresidualRendered = squeeze(double(IresidualRendered))./1000000;
    %���в�ͼ�������������ȷ�����ӣ��õ��ϳ����ӵ�� ���ȷ����� 
    
    Isr = squeeze(IyRendered(num,:,:)) + IresidualRendered;
    %�����ӵ� ���ȷ�������������ɫ��������������ʹ�� ycbcr2rgb ������ͼ��ת��Ϊ RGB ��ɫ�ռ䡣���Ϊ �õ����ع����ղ�ɫ���ӵ㡣
   %% novel view reconstruction
    novelView = ycbcr2rgb(cat(3,Isr,squeeze(IcbRendered(num,:,:)),squeeze(IcrRendered(num,:,:))));
    figure
    imshow(novelView)
    title('rendered view')
 
    % �����ع������ӵ�
    if 100<num
        imwrite(novelView,['renderResults\Flowers\flowers0',num2str(num-1),'.jpg']);
    elseif (10<num)&&(num<101)
        imwrite(novelView,['renderResults\Flowers\flowers00',num2str(num-1),'.jpg']);
    else
        imwrite(novelView,['renderResults\Flowers\flowers000',num2str(num-1),'.jpg']);
    end
    
end
