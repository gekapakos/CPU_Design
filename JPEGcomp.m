function [Compressed_Data,Compressed_Image] = JPEGcomp(Original_Image,Quality_Factor)
% meermobini@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%JPEG Image Compression%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-------------------------Outputs:---------------------------
% Compressed_Data: Huffman encoded compressed data and parameters
% Compressed_Image: Compressed JPEG Image
%-------------------------Inputs:-----------------------------
% OriginalImage: True-color image
% Quality_Factor: Desired quality of compressed image vs original image inpercent (1%-100%);
%% Global Variables
I = imread(Original_Image);
QF = Quality_Factor;
[r,c,int] = size(I);
%%%%%%%%%%%%%%%%%%%Quality Factor Scale%%%%%%%%%%%%%%%%%%%%%%
if QF > 95
    qscale = 1;
elseif QF < 50
    qscale = floor(5000/QF);
else
    qscale = 200-2*QF;
end
%%%%%%%%%%%%%%%%%%Quantization Tables%%%%%%%%%%%%%%%%%%%%%%%%
QL=[16,  11,  10,  16,  24,  40,  51,  61,
    12,  12,  14,  19,  26,  58,  60,  55,
    14,  13,  16,  24,  40,  57,  69,  56,
    14,  17,  22,  29,  51,  87,  80,  62,
    18,  22,  37,  56,  68, 109, 103,  77,
    24,  35,  55,  64,  81, 104, 113,  92,
    49,  64,  78,  87, 103, 121, 120, 101,
    72,  92,  95,  98, 112, 100, 103,  99];

QL = (QL*(qscale/100));

QCh=[17,  18,  24,  47,  99,  99,  99,  99,
    18,  21,  26,  66,  99,  99,  99,  99,
    24,  26,  56,  99,  99,  99,  99,  99,
    47,  66,  99,  99,  99,  99,  99,  99,
    99,  99,  99,  99,  99,  99,  99,  99,
    99,  99,  99,  99,  99,  99,  99,  99,
    99,  99,  99,  99,  99,  99,  99,  99,
    99,  99,  99,  99,  99,  99,  99,  99];

QCh = (QCh*(qscale/100));
%% Color Transform (RGB to YIQ system)
% Converting the Red, Blue & Green intensity into the Luminance & Chrominance
NTSC = rgb2ntsc(I);
YCBCR = NTSC*256-128; % Y = I(:,:,1); Cb = I(:,:,2); Cr = I(:,:,3);
%% Down-sampling
% order = 2
DSI = zeros(floor(r/2),floor(c/2),int);
for i = 1:int
    DSI(:,:,i) = YCBCR(1:2:r-1,1:2:c-1,i);
end
%% Forward Discrete Cosine Transform (DCT)
% Applying DCT to each 8X8 block of image
dctfun = @dct2;
CTI = zeros(size(DSI));
for i = 1:int
    CTI(:,:,i) = blkproc(DSI(:,:,i),[8 8],dctfun);
end
%% Quantization (Using Table)
% Dividing each 8X8 block of image into the 8X8 quantization table
qfun = @DIV;
QI(:,:,1) = round(blkproc(CTI(:,:,1),[8 8],qfun,QL));
QI(:,:,2) = round(blkproc(CTI(:,:,2),[8 8],qfun,QCh));
QI(:,:,3) = round(blkproc(CTI(:,:,3),[8 8],qfun,QCh));
%% Huffman Encoding (Compressed Data)
[ro,co,~] = size(QI); S = [ro co];

Y = QI(:,:,1);
I = QI(:,:,2);
Q = QI(:,:,3);

symbols_Y = unique(Y);
symbols_I = unique(I);
symbols_Q = unique(Q);

for i = 1:length(symbols_Y)
    prob_Y(i) = sum(Y(:)==symbols_Y(i))/numel(Y);
end
for i = 1:length(symbols_I)
    prob_I(i) = sum(I(:)==symbols_I(i))/numel(I);
end
for i = 1:length(symbols_Q)
    prob_Q(i) = sum(Q(:)==symbols_Q(i))/numel(Q);
end

dict_Y = huffmandict(symbols_Y,prob_Y');
dict_I = huffmandict(symbols_I,prob_I');
dict_Q = huffmandict(symbols_Q,prob_Q');

HY = huffmanenco(Y(:),dict_Y);
HI = huffmanenco(I(:),dict_I);
HQ = huffmanenco(Q(:),dict_Q);
%%%%%%%%%%%%%%%%%%%%%Compressed Data%%%%%%%%%%%%%%%%%%%%%%%
Compressed_Data.Y = HY;
Compressed_Data.I = HI;
Compressed_Data.Q = HQ;
Compressed_Data.dictY = dict_Y;
Compressed_Data.dictI = dict_I;
Compressed_Data.dictQ = dict_Q;
Compressed_Data.ImageSize = S;
%% Decoding
dY = huffmandeco(HY,dict_Y); dY = reshape(dY,[ro co]);
dI = huffmandeco(HI,dict_I); dI = reshape(dI,[ro co]);
dQ = huffmandeco(HQ,dict_Q); dQ = reshape(dQ,[ro co]);
DI(:,:,1) = dY;
DI(:,:,2) = dI;
DI(:,:,3) = dQ;
%% De-quantization
% Multiplying each 8X8 block of image into the 8X8 quantization table
dqfun = @MUL;
DDI(:,:,1) = blkproc(DI(:,:,1),[8 8],dqfun,QL);
DDI(:,:,2) = blkproc(DI(:,:,2),[8 8],dqfun,QCh);
DDI(:,:,3) = blkproc(DI(:,:,3),[8 8],dqfun,QCh);
%% Inverse Discrete Cosine Transform (IDCT)
% Applying Inverse-DCT to each 8X8 block of image
idctfun = @idct2;
ICTI = zeros(size(DDI));
for i = 1:int
    ICTI(:,:,i) = blkproc(DDI(:,:,i),[8 8],idctfun);
end
%% Up sampling
% order = 2
[R,C,~] = size(ICTI);
USI = zeros(2*R,2*C,int);
for i = 1:int
    USI(1:2:end,1:2:end,i) = ICTI(:,:,i);
    USI(2:2:end,2:2:end,i) = ICTI(:,:,i);
    USI(2:2:end,1:2:end,i) = ICTI(:,:,i);
    USI(1:2:end,2:2:end,i) = ICTI(:,:,i);
end
%% Reconstructing the image
I_new = (USI+128)/256; % Re-scaling
Compressed_Image = ntsc2rgb(I_new); % Converting YIQ to RGB
imshow(Compressed_Image);
end
%%%%%%%%%%%%%%%%%%%%%%%%Quantization Functions%%%%%%%%%%%%%%%%%%%%
function [d] = DIV(num,den)
d = num./den;
end

function [z] = MUL(x,y)
z = x.*y;
end
