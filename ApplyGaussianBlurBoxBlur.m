function [ mBlurredImage ] = ApplyGaussianBlurBoxBlur( mInputImage, gaussianKernelStd, numBlurIterations )
% ----------------------------------------------------------------------------------------------- %
% [ boxBlurKernel ] = CalculateBoxBlurKernel( boxBlurVar, numIterations )
%   Approximates 1D Gaussian Kernel by iterative convolutions of "Extended Box Filter".
% Input:
%   - boxBlurVar        -   BoxFilter Varaiance.
%                           The variance of the output Box Filter.
%                           Scalar, Floating Point (0, inf).
%   - numIterations     -   Number of Iterations.
%                           The number of convolution iterations in order
%                           to produce the output Box Filter.
%                           Scalar, Floating Point [1, inf), Integer.
% Output:
%   - vBoxBlurKernel    -   Output Box Filter.
%                           The Box Filter with 'boxBlurVar' Variance.
%                           Vector, Floating Point, (0, 1).
% Remarks:
%   1.  The output Box Filter has a variance of '' as if it is treated as
%       Discrete Probability Function.
%   2.  References: "Fast Almost Gaussian Filtering"
%   3.  Prefixes:
%       -   'm' - Matrix.
%       -   'v' - Vector.
%   4.  Higher number of `numBlurIterations` yields better results.
%       Yet the Minimum must be 3.
% TODO:
%   1.  F
%   Release Notes:
%   -   1.0.001     19/03/2015  Royi Avital
%       *   Fixed bug for calculatiuon of the radius from the length. When
%           small STD was given, the radius could have been negative.
%   -   1.0.000     14/03/2015  Royi Avital
%       *   First release version.
% ----------------------------------------------------------------------------------------------- %

gaussianKernelVar = gaussianKernelStd * gaussianKernelStd;

boxBlurLengthIdeal = sqrt(((12 * gaussianKernelVar) / numBlurIterations) + 1);

boxBlurLengthLow = floor(boxBlurLengthIdeal);
if(mod(boxBlurLengthLow, 2) == 0)
    boxBlurLengthLow = boxBlurLengthLow - 1;
end

boxBlurLengthHigh = boxBlurLengthLow + 2;

boxBlurRadiusLow    = floor(boxBlurLengthLow / 2);
boxBlurRadiusHigh   = floor(boxBlurLengthHigh / 2);

numIterationsLowFilter = round(((12 * gaussianKernelVar) - (numBlurIterations * (boxBlurLengthLow * boxBlurLengthLow)) - (4 * numBlurIterations * boxBlurLengthLow) - (3 * numBlurIterations)) / (-(4 * boxBlurLengthLow) - 4));
numIterationHighFilter = numBlurIterations - numIterationsLowFilter;

mBlurredImage = mInputImage;

% Convolving the 'vSingleBoxBlurKernel'.
% Starting at 2, since setting it was the first.
for iIter = 1:numIterationsLowFilter
    mBlurredImage = ApplyBoxBlur(mBlurredImage, boxBlurRadiusLow);
end

for iIter = 1:numIterationHighFilter
    mBlurredImage = ApplyBoxBlur(mBlurredImage, boxBlurRadiusHigh);
end


end

