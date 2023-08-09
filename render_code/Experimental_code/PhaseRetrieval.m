 


function [imgabs]=PhaseRetrieval(image0)


%λ����ȫϢͼ
%��һ��������
%image0 = imread('Hepburn.jpg');
%תΪ�Ҷ�ͼ������Ϊ�Ҷ�ͼ����ԣ�
%image0 = rgb2gray(image0);
image0 = im2double(image0);
[M,N,nn] = size(image0);

%���ԭͼ
% figure;
% subplot(2,2,1);
% imshow(image0);
% title('ԭͼ')

%�������λ����Ϣ
PI = 3.14159;
image1 = image0;
phase = 2i*PI*rand(M,N);
image1 = image1.*exp(phase);  % ��ͼƬ�����λ��Ϣ

%������λ��ͼ
% subplot(2,2,2);
% imshow(image1);
% title('���λ��ͼ');

%�ڶ������������
%��һ���渵��Ҷ�任
image2 = ifft2(ifftshift(image1));

%��������
for t=1:1:100
    %�����о�
    imgangle = angle(image2);   %ȡλ��
    image = exp(1i*imgangle);
    image = fftshift(fft2(image));                  %��ԭ
    imgabs = abs(image)./max(max(abs(image)));
    sim = corrcoef(image0,imgabs);                  %ȡ���ϵ��
    if sim(1,2) >= 0.9995
        %��������������ѭ��
        break;
    else
        %��ʼ����
        %��λ���
        imgangle = angle(image2);
        image2 = exp(1i*imgangle);

        %������Ҷ�任
        image3 = fftshift(fft2(image2));

       %���������
        imgabs = abs(image3)./max(max(abs(image3)));
        imgangle = angle(image3);
        image3 = exp(1i*imgangle);
        image3 = image3.*(image0+rand(1,1)*(image0-imgabs));

        %�渵��Ҷ�任
        image2 = ifft2(ifftshift(image3));        
    end
end

%�����������λ��ȫϢͼ
%ȡλ��
imgangle = angle(image2);                       
image4 = exp(1i*imgangle);

%��ԭ
image4 = fftshift(fft2(image4));                          
imgabs = abs(image4)./max(max(abs(image4)));

%�洢λ��ȫϢͼ
%imgangle = (imgangle+PI)/(2*PI);
% imwrite(imgangle,'Hepburn.jpg')

%���λ��ȫϢͼ
% subplot(2,2,3);
% imshow(imgangle);
% title('λ��ȫϢͼ')
% 
% %�����ԭͼ
% subplot(2,2,4);
% imshow(imgabs);
% title('��ԭͼ')


