close all
clear all
clc
 
I=imread('..\6.Pic\outcom.bmp');
 
[H ,W ,D]=size(I);
 
R=double(I(:,:,1));
G=double(I(:,:,2));
B=double(I(:,:,3));
 
 
Y0= double(zeros(H,W));
Y1= double(zeros(H,W));
Cb0 =double(zeros(H,W));
Cr0 = double(zeros(H,W));
 
R0= double(zeros(H,W));
G0 =double(zeros(H,W));
B0 = double(zeros(H,W));
 
%RGB to YCbCr444
 for i = 1:H
     for j = 1:W
         Y0(i, j) = 0.299*R(i, j) + 0.587*G(i, j) + 0.114*B(i, j);
         Cb0(i, j) = -0.172*R(i, j) - 0.339*G(i, j) + 0.511*B(i, j) + 128;
         Cr0(i, j) = 0.511*R(i, j) - 0.428*G(i, j) - 0.083*B(i, j) + 128;
     end
 end 
 
 for i = 1:H
     for j = 1:W
         Y1(i,j) = Y0(i,j) + 50;
     end
 end

 for i = 1:H
     for j = 1:W
         RGB(i, j,1) =Y1(i,j)+1.371*(Cr0(i,j)-128);
         RGB(i, j,2) =Y1(i,j)-0.689*(Cr0(i,j)-128)-0.336*(Cb0(i,j)-128);
         RGB(i, j,3) =Y1(i,j)+1.732*(Cb0(i,j)-128);
     end
 end
 
YCbCr(:,:,1)=Y0;
YCbCr(:,:,2)=Cb0;
YCbCr(:,:,3)=Cr0;
 
YCbCr=uint8(YCbCr);
 
RGB=uint8(RGB);
 
%figure(1),
%imshow(YCbCr),title('YCbCr');
 
figure(1),
imshow(I),title('origine');
figure(2),
imshow(RGB),title('after');



