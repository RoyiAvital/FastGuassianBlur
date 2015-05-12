function [ mBlurredImage ] = ApplyGaussianBlurIirFilter( mInputImage, gaussianKernelStd )
% ----------------------------------------------------------------------------------------------- %
% [ mBlurredImage ] = ApplyGaussianBlurIirFilter( mInputImage, gaussianKernelStd )
%   Applying Gaussian Blur Filter using IIR approximation.
% Input:
%   - mInputImage           -   Input Image.
%                               The input image to apply the blur upon.
%                               Structure: Matrix (Single Channel Image).
%                               Type: 'Single' / 'Double'.
%                               Range: [0, 1].
%   - gaussianKernelStd     -   Gaussian Kernel Standard Deviation.
%                               The standard deviation of the Gaussian
%                               Kernel to approximate.
%                               Structure: Scalar.
%                               Type: 'Single' / 'Double'.
%                               Range: (0, inf).
% Output:
%   - mBlurredImage         -   Output Blurred Image.
%                               The blurred version of the input image.
%                               Structure: Matrix (Single Channel Image).
%                               Type: 'Single' / 'Double'.
%                               Range: [0, 1].
% Remarks:
%   1.  References:
%           -   "Recursive Gabor Filtering".
%           -   "Recursive Implementation of the Gaussian Filter".
%           -   "Boundary Conditions for Young - van Vliet Recursive Filtering".
%   2.  Prefixes:
%       -   'm' - Matrix.
%       -   'v' - Vector.
%   3.  Suitable for Gaussian Kernels with STD of 1 and above.
% TODO:
%   1.  Check why Method 002 yields big erros relative to Method 001.
%   Release Notes:
%   -   1.3.000     25/04/2015  Royi Avital
%       *   Using 1D Function.
%   -   1.2.005     18/04/2015  Royi Avital
%       *   Using proper inital conditions to avoid padding.
%   -   1.0.000     14/03/2015  Royi Avital
%       *   First release version.
% ----------------------------------------------------------------------------------------------- %

IIR_COEF_CALC_METHOD_001 = 1;
IIR_COEF_CALC_METHOD_002 = 2;

iirCoefCalcMethod = IIR_COEF_CALC_METHOD_001;

[vNumCoeff, vDenCoeff] = CalcIirFilterCoef(gaussianKernelStd, iirCoefCalcMethod);

% View the Poles and Zeros of the Filter
% gaussianKernelStd = 128;
% iirCoefCalcMethod = COEF_CALC_METHOD_002;
% 
% 
% [vNumCoeff, vDenCoeff] = CalcIirFilterCoef(gaussianKernelStd, iirCoefCalcMethod);
% 
% figure();
% [z, p, k] = tf2zpk(vNumCoeff, vDenCoeff);
% zplane(z, p);
% grid;
% xlim([0.9, 1.1]);
% ylim([-0.05, 0.05]);

mZi = CalcMziMatrix(vDenCoeff);

mBlurredImage = Apply1DGaussianBlurIirFilter(mInputImage, vNumCoeff, vDenCoeff, mZi);
mBlurredImage = Apply1DGaussianBlurIirFilter(mBlurredImage.', vNumCoeff, vDenCoeff, mZi);
mBlurredImage = mBlurredImage.';


end


function [ vNumCoeff, vDenCoeff ] = CalcIirFilterCoef( gaussianKernelStd, iirCoefCalcMethod )
% ----------------------------------------------------------------------------------------------- %
% [ vNumCoeff, vDenCoeff ] = CalcIirFilterCoef( gaussianKernelStd, iirCoefCalcMethod )
%   Calculates the IIF filter coefficients (Z-Transform) to approximate
%   Gaussian Kernel.
% Input:
%   - gaussianKernelStd     -   Gaussian Kernel Standard Deviation.
%                               The standard deviation of the Gaussian
%                               Kernel to approximate.
%                               Structure: Scalar.
%                               Type: 'Single' / 'Double'.
%                               Range: (0, inf).
%   - iirCoefCalcMethod     -   IIR Filter Coefficients Calculation Method.
%                               The method used to calculate the
%                               Z-Transform coefficients of the IIR filter.
%                               The 2 methods are in the references.
%                               Structure: Scalar.
%                               Type: 'Single' / 'Double'.
%                               Range: {0, 1}.
% Output:
%   - vNumCoeff     -   IIR Filter Numerator Coefficients.
%                       IIR Filter Z-Transform numerator coefficients.
%                       Structure: Vector.
%                       Type: 'Single' / 'Double'.
%                       Range: (-inf, inf).
%   - vDenCoeff     -   IIR Filter Denominator Coefficients.
%                       IIR Filter Z-Transform denominator coefficients.
%                       Structure: Vector.
%                       Type: 'Single' / 'Double'.
%                       Range: (-inf, inf).
% Remarks:
%   1.  References:
%           -   "Recursive Gabor Filtering".
%           -   "Recursive Implementation of the Gaussian Filter"
%   2.  Prefixes:
%       -   'm' - Matrix.
%       -   'v' - Vector.
%   3.  Suitable for Gaussian Kernels with STD of 1 and above.
% TODO:
%   1.  Check method 002 (Yields relatively large erros).
%   Release Notes:
%   -   1.0.000     25/04/2015  Royi Avital
%       *   First release version.
% ----------------------------------------------------------------------------------------------- %

SMALL_STD_THR = 2.5;

IIR_COEF_CALC_METHOD_001 = 1;
IIR_COEF_CALC_METHOD_002 = 2;

switch(iirCoefCalcMethod)
    case(IIR_COEF_CALC_METHOD_001)
        if(gaussianKernelStd > SMALL_STD_THR)
            qFactor = (0.98711 * gaussianKernelStd) - 0.96330;
        else
            qFactor = 3.97156 - (4.14554 * sqrt(1 - (0.26891 * gaussianKernelStd)));
        end
        
        b0Coeff = 1.57825 + (2.44413 * qFactor) + (1.4281 * qFactor * qFactor) + (0.422205 * qFactor * qFactor * qFactor);
        b1Coeff = (2.44413 * qFactor) + (2.85619 * qFactor * qFactor) + (1.26661 * qFactor * qFactor * qFactor);
        b2Coeff = (-1.4281 * qFactor * qFactor) + (-1.26661 * qFactor * qFactor * qFactor);
        b3Coeff = 0.422205 * qFactor * qFactor * qFactor;
        
        vNumCoeff = 1 - ((b1Coeff + b2Coeff + b3Coeff) / b0Coeff);
        vDenCoeff = [b0Coeff, -b1Coeff, -b2Coeff, -b3Coeff] / b0Coeff;
    case(IIR_COEF_CALC_METHOD_002)
        qFactor = 1.31564 * (sqrt(1 + (0.490811 * gaussianKernelStd * gaussianKernelStd)) - 1);
        m0Factor = 1.16680;
        m1Factor = 1.10783;
        m2Factor = 1.140586;
        
        b0Coeff = (m0Factor + qFactor) * ((m1Factor * m1Factor) + (m2Factor * m2Factor) + (2 * m1Factor * qFactor) + (qFactor * qFactor));
        b1Coeff = -qFactor * ((2 * m0Factor * m1Factor) + (m1Factor * m1Factor) + (m2Factor * m2Factor) + (((2 * m0Factor) + (4 * m1Factor)) * qFactor) + (3 * qFactor * qFactor));
        b2Coeff = (qFactor * qFactor) * (m0Factor + (2 * m1Factor) + (3 * qFactor));
        b3Coeff = -(qFactor * qFactor * qFactor);
        
        vDenCoeff = [b0Coeff, b1Coeff, b2Coeff, b3Coeff] / b0Coeff;
        vNumCoeff = sum(vDenCoeff);
end


end


function [ mZi ] = CalcMziMatrix( vDenCoeff )
% ----------------------------------------------------------------------------------------------- %
% [ mZi ] = CalcMziMatrix( vDenCoeff )
%   Calculating the filter state matrix in order to calculate the non
%   casual pass (Second iteration) initial conditions.
% Input:
%   - mInputImage           -   Input Image.
%                               The input image to apply the blur upon.
%                               Matrix, Floating Point (0, 1).
%   - gaussianKernelStd     -   Gaussian Kernel Standard Deviation.
%                               The standard deviation of the Gaussian
%                               Kernel to approximate.
%                               Scalar, Floating Point (0, inf).
% Output:
%   - mBlurredImage         -   Output Blurred Image.
%                               The blurred version of the input umage.
%                               Matrix, Floating Point (0, 1).
% Remarks:
%   1.  References:
%           -   ""Boundary Conditions for Young - van Vliet Recursive Filtering"".
%   2.  Prefixes:
%       -   'm' - Matrix.
%       -   'v' - Vector.
% TODO:
%   1.  aaa.
%   Release Notes:
%   -   1.0.000     25/04/2015  Royi Avital
%       *   First release version.
% ----------------------------------------------------------------------------------------------- %

% Pay attention to what should be the denominator and the actual
% multiplication of the input (Minus Sign).
b1 = -vDenCoeff(2);
b2 = -vDenCoeff(3);
b3 = -vDenCoeff(4);

ziScalingFactor = 1 / ((1 + b1 - b2 + b3) * (1 - b1 - b2 - b3) * (1 + b2 + ((b1 - b3) * b3)));

mZi = zeros(3, 3);
mZi(1) = -(b3 * b1) + 1 - (b3 * b3) - b2;
mZi(2) = b1 + (b3 * b2);
mZi(3) = (b3 * b1) + b2 + (b1 * b1) - (b2 * b2);

mZi(4) = (b3 + b1) * (b2 + (b3 * b1));
mZi(5) = -(b2 - 1) * (b2 + (b3 * b1));
mZi(6) = (b1 * b2) + (b3 * b2 * b2) - (b1 * b3 * b3) - (b3 * b3 * b3) - (b3 * b2) + b3;

mZi(7) = b3 * (b1 + (b3 * b2));
mZi(8) = -((b3 * b1) + (b3 * b3) + b2 - 1) * b3;
mZi(9) = b3 * (b1 + (b3 * b2));

mZi = mZi .* ziScalingFactor;


end

function [ mBlurredImage ] = Apply1DGaussianBlurIirFilter( mInputImage, vNumCoeff, vDenCoeff, mZi )
% ----------------------------------------------------------------------------------------------- %
% [ mBlurredImage ] = Apply1DGaussianBlurIirFilter( mInputImage, vNumCoeff, vDenCoeff, mZi )
%   Applying 1D (Along the columns) Gaussian Blur Filter using IIR approximation.
% Input:
%   - mInputImage   -   Input Image.
%                       The input image to apply the blur upon.
%                       Structure: Matrix (Single Channel Image).
%                       Type: 'Single' / 'Double'.
%                       Range: [0, 1].
%   - vNumCoeff     -   IIR Filter Numerator Coefficients.
%                       IIR Filter Z-Transform numerator coefficients.
%                       Structure: Vector.
%                       Type: 'Single' / 'Double'.
%                       Range: (-inf, inf).
%   - vDenCoeff     -   IIR Filter Denominator Coefficients.
%                       IIR Filter Z-Transform denominator coefficients.
%                       Structure: Vector.
%                       Type: 'Single' / 'Double'.
%                       Range: (-inf, inf).
%   - mZi           -   Filter State Matrix.
%                       The filter state matrix which allows calculation of
%                       the initial condition of the non casual filter.
%                       Structure: Matrix.
%                       Type: 'Single' / 'Double'.
%                       Range: (-inf, inf).
% Output:
%   - mBlurredImage         -   Output Blurred Image.
%                               The blurred version of the input umage.
%                               Matrix, Floating Point (0, 1).
% Remarks:
%   1.  References:
%           -   "Recursive Gabor Filtering".
%           -   "Recursive Implementation of the Gaussian Filter".
%           -   "Boundary Conditions for Young - van Vliet Recursive Filtering".
%   2.  Prefixes:
%       -   'm' - Matrix.
%       -   'v' - Vector.
%   3.  Suitable for Gaussian Kernels with STD of 1 and above.
% TODO:
%   1.  aa
%   Release Notes:
%   -   1.0.000     25/04/2015  Royi Avital
%       *   First release version.
% ----------------------------------------------------------------------------------------------- %

numRows = size(mInputImage, 1);
numCols = size(mInputImage, 2);

vACoeff         = vNumCoeff;
vBCoeff         = -vDenCoeff(2:4);
sumBCoeff       = sum(vBCoeff);

% Auto Regressive Coefficients
b0Coeff = 1;
b1Coeff = vBCoeff(1);
b2Coeff = vBCoeff(2);
b3Coeff = vBCoeff(3);

% Moving Average Coefficients
a0Coeff = vACoeff;

vU1 = 1 * (mInputImage(1, 1:numCols) ./ (1 - sumBCoeff));
vU2 = vU1;
vU3 = vU1;

vZ1 = (b1Coeff * vU1) + (b2Coeff * vU2) + (b3Coeff * vU3);
vZ2 = (b2Coeff * vU1) + (b3Coeff * vU2);
vZ3 = (b3Coeff * vU1);

mZ = [vZ1; vZ2; vZ3];
mBlurredImage   = FilterX(1, vDenCoeff, mInputImage, mZ, false(1));


vUPlus = mInputImage(numRows, 1:numCols) ./ (1 - sumBCoeff);
vVPlus = vUPlus ./ (1 - sumBCoeff);

mVInitialCondition = (mZi * (mBlurredImage(numRows:-1:(numRows - 2), :) - repmat(vUPlus, [3, 1]))) + repmat(vVPlus, [3, 1]);

vV1    = a0Coeff * a0Coeff * mVInitialCondition(1, :);
vV2    = a0Coeff * a0Coeff * mVInitialCondition(2, :);
vV3    = a0Coeff * a0Coeff * mVInitialCondition(3, :);

vZ1 = (b1Coeff * vV1) + (b2Coeff * vV2) + (b3Coeff * vV3);
vZ2 = (b2Coeff * vV1) + (b3Coeff * vV2);
vZ3 = (b3Coeff * vV1);

mZ = [vZ1; vZ2; vZ3];

mBlurredImage(numRows, :) = vV1;
mBlurredImage(1:(numRows - 1), :) = FilterX((vNumCoeff * vNumCoeff), vDenCoeff, mBlurredImage(1:(numRows - 1), :), mZ, true(1));


end

