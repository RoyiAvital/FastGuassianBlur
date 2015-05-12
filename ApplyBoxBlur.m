function [ mOutputImage ] = ApplyBoxBlur( mInputImage, boxRadius )
% ----------------------------------------------------------------------------------------------- %
% [ mBlurredImage ] = ApplyBoxBlur( mInputImage, boxBlurKernelRadius )
%   Applies Box Blur using Integral Images.
% Input:
%   - mInputImage   -   Input Image.
%                       Structure: Image Matrix (Single Channel)
%                       Type: 'Single' / 'Double'.
%                       Range: [0, 1].
%   - boxRadius     -   Box Radius.
%                       The radius of the box neighborhood for the
%                       summation process.
%                       Structure: Scalar.
%                       Type: 'Single' / 'Double'.
%                       Range: {1, 2, ..., }.
% Output:
%   - mOutputImage  -   Output Image.
%                       Structure: Image Matrix (Single Channel)
%                       Type: 'Single' / 'Double'.
%                       Range: [0, 1].
% Remarks:
%   1.  References: "..."
%   2.  Prefixes:
%       -   'm' - Matrix.
%       -   'v' - Vector.
% TODO:
%   1.  F
%   Release Notes:
%   -   1.0.000     14/03/2015  Royi Avital
%       *   First release version.
% ----------------------------------------------------------------------------------------------- %

numRows = size(mInputImage, 1);
numCols = size(mInputImage, 2);

boxBlurKernelLength     = (2 * boxRadius) + 1;
boxBlurKernelNumPixels  = boxBlurKernelLength * boxBlurKernelLength;

normalizationFactor = 1 / boxBlurKernelNumPixels;

% Another Row / Column is needed as "Initial State" of the Integral.
% The added Row / Column at the end isn't required.
mInputImagePad = padarray(mInputImage, [(boxRadius + 1), (boxRadius + 1)], 'both', 'replicate');
mInputImagePad(:, 1) = 0;
mInputImagePad(1, :) = 0;

% Integrating to create the Integral Image
mIntegralImage = cumsum(mInputImagePad, 1);
mIntegralImage = cumsum(mIntegralImage, 2);

% Defining the indices
vRows       = 1:numRows;
vCols       = 1:numCols;
vValidRows  = boxBlurKernelLength + vRows;
vValidCols  = boxBlurKernelLength + vCols;

mOutputImage = mIntegralImage(vValidRows, vValidCols) - ...
    mIntegralImage(vValidRows, vCols) - ...
    mIntegralImage(vRows, vValidCols) + ...
    mIntegralImage(vRows, vCols);

% Normalization to calculate the mean o fthe box
mOutputImage = mOutputImage * normalizationFactor;


end

