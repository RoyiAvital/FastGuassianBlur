function [ mBlurredImage ] = ApplyGaussianBlur( mInputImage, gaussianKernelStd, stdToRadiusFactor )
% ----------------------------------------------------------------------------------------------- %
% [ mBlurredImage ] = ApplyGaussianBlur( mInputImage, gaussianKernelStd, stdToRadiusFactor )
%   Applies Gaussian Blur on an image
% Input:
%   - mInputImage       -   Input Image.
%                           Structure: Image Matrix (Single Channel)
%                           Type: 'Single' / 'Double'.
%                           Range: [0, 1].
%   - gaussianKernelStd -   Gaussian Kernel Standard Deviation.
%                           The STD of Gaussian Kernel used to blur the image.
%                           Structure: Scalar
%                           Type: 'Single' / 'Double'.
%                           Range: (0, inf).
%   - stdToRadiusFactor -   Standrd Deviation to Radius Factor.
%                           Used to calclate the radius of the truncated
%                           Gaussian Kernel.
%                           Structure: Scalar
%                           Type: 'Single' / 'Double'.
%                           Range: (0, inf).
% Output:
%   - mOutputImage      -   Output Image.
%                           Structure: Image Matrix (Single Channel)
%                           Type: 'Single' / 'Double'.
%                           Range: [0, 1].
% Remarks:
%   1.  This function is imitation of Photoshop's Gaussian Blur function.
%   2.  Each of the channels is processed independently.
%   3.  References:
%       -   http://imagejdocu.tudor.lu/doku.php?id=gui:process:filters
%   4.  Prefixes:
%       -   'm' - Matrix.
%       -   'v' - Vector.
% TODO:
%   1.  
%   Release Notes:
%   -   1.0.001     18/03/2015  Royi Avital
%       *   Supporting only single channel images.
%   -   1.0.000     15/04/2014  Royi Avital
%       *   First release version.
% ----------------------------------------------------------------------------------------------- %

gaussianBlurRadius  = ceil(stdToRadiusFactor * gaussianKernelStd); % Imitating Photoshop - See Reference

vGaussianKernel = exp(-([-gaussianBlurRadius:gaussianBlurRadius] .^ 2) / (2 * gaussianKernelStd * gaussianKernelStd));
vGaussianKernel = vGaussianKernel / sum(vGaussianKernel);

mInputImagePadded   = padarray(mInputImage, [gaussianBlurRadius, gaussianBlurRadius], 'replicate', 'both');

mBlurredImage = conv2(vGaussianKernel, vGaussianKernel.', mInputImagePadded, 'valid');


end

