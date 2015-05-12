% Box Blur Demo
clear();
close('all');
disp(' ');
disp(' ');

%% General Parameters and Initialization

set(0, 'DefaultFigureWindowStyle', 'normal');

titleFontSize   = 14;
axisFotnSize    = 12;
stringFontSize  = 12;

thinLineWidth   = 2;
normalLineWidth = 3;
thickLineWidth  = 4;

randomNumberStream = RandStream('mlfg6331_64', 'NormalTransform', 'Ziggurat');
subStreamNumber = 57162;
set(randomNumberStream, 'Substream', subStreamNumber);
RandStream.setGlobalStream(randomNumberStream);


% Constants

FALSE   = 0;
TRUE    = 1;

OFF = 0;
ON  = 1;

DISABLED = 0;
ENADBLED = 1;

NUMBER_FORMAT_SPEC = '%3.5f';

% Run Time Parameters

useSyntheticImage   = OFF;
displayResults      = ON;
useSinglePrecision  = OFF;
runTimeAnalysis     = ON;
errorAnalysis       = ON;

numIterations = 2;

%% Generation / Loading of the Input Image

mInputImageFilePath = '1.png';

syntheticImageNumRows = 800;
syntheticImageNumCols = 800;

% Creating the 
if(useSyntheticImage == ON)
    mInputImage = rand([syntheticImageNumRows, syntheticImageNumCols]);
else
    mInputImage = imread(mInputImageFilePath);
    mInputImage = double(mInputImage) / 255;
    mInputImage = mean(mInputImage, 3);
end

if(useSinglePrecision == ON)
    mInputImage = single(mInputImage);
end

%% Generating Reference Image
% The reference image is created by applying Gaussian Kernel with very long
% support to approximate convolution by ideal Gaussian Kernel.

gaussianKernelStd               = 16;
gaussianKernelStdToRadiusCoef   = 7;


% Truncated Gaussian Kernel (Reference)
vRunTime = zeros(numIterations, 1);

hTotalRunTimer = tic();
for ii = 1:numIterations
    hSingleRunTimer = tic();
    mBlurredImage1 = ApplyGaussianBlur(mInputImage, gaussianKernelStd, gaussianKernelStdToRadiusCoef);
    vRunTime(ii) = toc(hSingleRunTimer);
end
totalRunTime = toc(hTotalRunTimer);

blurredImage1TotalRunTime   = totalRunTime;
blurredImage1AverageRunTime = totalRunTime / numIterations;
blurredImage1MedianRunTime  = median(vRunTime);




%% Box Blur Approximation
% By convoloving Box Kernel over and over the Gaussian Kernel is
% approximated by the "Central Limit Theroem".

% Numer of iteration to approximate Gaussian Kernel.
% The higher the number, the more accurate the approximation (And runtime).
boxBlurNumIterations = 5;

vRunTime = zeros(numIterations, 1);

hTotalRunTimer = tic();
for ii = 1:numIterations
    hSingleRunTimer = tic();
    mBlurredImage2 = ApplyGaussianBlurBoxBlur(mInputImage, gaussianKernelStd, boxBlurNumIterations);
    vRunTime(ii) = toc(hSingleRunTimer);
end
totalRunTime = toc(hTotalRunTimer);

blurredImage2TotalRunTime   = totalRunTime;
blurredImage2AverageRunTime = totalRunTime / numIterations;
blurredImage2MedianRunTime  = median(vRunTime);


%% IIR Filter Approximation
vRunTime = zeros(numIterations, 1);

hTotalRunTimer = tic();
for ii = 1:numIterations
    hSingleRunTimer = tic();
    mBlurredImage3 = ApplyGaussianBlurIirFilter(mInputImage, gaussianKernelStd);
    vRunTime(ii) = toc(hSingleRunTimer);
end
totalRunTime = toc(hTotalRunTimer);

blurredImage3TotalRunTime   = totalRunTime;
blurredImage3AverageRunTime = totalRunTime / numIterations;
blurredImage3MedianRunTime  = median(vRunTime);

%% Display Results

if(displayResults == ON)
    hFigure = figure();
    hAxes   = axes();
    hImageObject = imshow([mBlurredImage1, mBlurredImage2], [0, 1]);
    set(get(hAxes, 'Title'), 'String', ['Left - Truncated Gaussian Blur, Right - Box Filter Approximation'], ...
        'FontSize', titleFontSize);
    
    hFigure = figure();
    hAxes   = axes();
    hImageObject = imshow([mBlurredImage1, mBlurredImage3], [0, 1]);
    set(get(hAxes, 'Title'), 'String', ['Left - Truncated Gaussian Blur, Right - IIR Filter Approximation'], ...
        'FontSize', titleFontSize);
end

%% Analysis

% Run Time Analysis
if(runTimeAnalysis == ON)
    disp('Run Time Analysis');
    
    disp(' ');
    
    disp(['Truncated Gaussian Kernel Approximation  - Total of Run Time     - ', num2str(blurredImage1TotalRunTime), ' [Sec]']);
    disp(['Truncated Gaussian Kernel Approximation  - Average of Run Time   - ', num2str(blurredImage1AverageRunTime), ' [Sec]']);
    disp(['Truncated Gaussian Kernel Approximation  - Median of Run Time    - ', num2str(blurredImage1MedianRunTime), ' [Sec]']);
    
    disp(' ');
    
    disp(['Box Blur Filter Approximation            - Total of Run Time     - ', num2str(blurredImage2TotalRunTime), ' [Sec]']);
    disp(['Box Blur Filter Approximation            - Average of Run Time   - ', num2str(blurredImage3AverageRunTime), ' [Sec]']);
    disp(['Box Blur Filter Approximation            - Median of Run Time    - ', num2str(blurredImage2MedianRunTime), ' [Sec]']);
    
    disp(' ');
    
    disp(['IIR Filter Approximation                 - Total of Run Time     - ', num2str(blurredImage3TotalRunTime), ' [Sec]']);
    disp(['IIR Filter Approximation                 - Average of Run Time   - ', num2str(blurredImage3AverageRunTime), ' [Sec]']);
    disp(['IIR Filter Approximation                 - Median of Run Time    - ', num2str(blurredImage3MedianRunTime), ' [Sec]']);
    
    disp(' ');
end

% Error Analysis
if(errorAnalysis == ON)
    disp('Approximation Error Analysis');
    
    disp(' ');
    
    mDiffImage1Image2 = mBlurredImage1 - mBlurredImage2;
    mDiffImage1Image3 = mBlurredImage1 - mBlurredImage3;
    
    maxErrorMethod1 = max(abs(mDiffImage1Image2(:)));
    maxErrorMethod2 = max(abs(mDiffImage1Image3(:)));
    
    disp(['Max Absolute Error - Box Blur Approximation      - ', num2str(maxErrorMethod1, NUMBER_FORMAT_SPEC)]);
    disp(['Max Absolute Error - IIR Filter Approximation    - ', num2str(maxErrorMethod2, NUMBER_FORMAT_SPEC)]);
    
    disp(' ');
    
    meanAbsErrorMethod1 = mean(abs(mDiffImage1Image2(:)));
    meanAbsErrorMethod2 = mean(abs(mDiffImage1Image3(:)));
    
    disp(['Mean Absolute Error - Box Blur Approximation     - ', num2str(meanAbsErrorMethod1, NUMBER_FORMAT_SPEC)]);
    disp(['Mean Absolute Error - IIR Filter Approximation   - ', num2str(meanAbsErrorMethod2, NUMBER_FORMAT_SPEC)]);
end

%% Restore Defaults
set(0, 'DefaultFigureWindowStyle', 'normal');

