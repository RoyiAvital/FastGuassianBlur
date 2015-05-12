# Fast Guassian Blur

## General
Evaluation of few methods to apply Gaussian Blur on an Image.  
The project is written in MATLAB and the evaluation is by Run Time and Approximation Error.  
The runtime is estimation of the overall complexity of the method and not optimization by coding.  
Namely, this project is after the most efficient method for applying Gaussian Blur not teh fastest MATLAB implementation.  
The complxiety of the claasic method depneds on the Image Size and the Guassian Kernel STD.  
Some of the approximations complexity is independent of the Gaussian Kernel Standard Deviation (STD).

## Assumptions
 1. The input image is within the range [0, 1], namely working on Floating Point.
 2. The Gaussian Blur is actually a one parameter function - the STD.
 3. Boundaries are either replication or symmetry.

## Methods
This section describes the current implemented methods.

### Truncated Gaussian Blur Kernel
The result is a convolution with a Gaussian Blur Kernel which is truncated.

### Box Filter Approximation
According to the [Central Limit Threoem][1] a Gaussian Kernel can be approximated by convoloving Box Kernel over and over.  
Box Blur by a Box Kernel can efficinetly implemnted using Integral Images ([Summed Area Table][2]).  
Implementation using Integral Images makes this method complexity independent of the Gaussian Kernel STD.  

### IIR Filter Approximation
The Gaussin Blur filter, based on the Gaussian Kernel has a specicif Frequency Response.  
By an IIR Filter aaproximation of the Frequency Response a very efficinet implementation can achieved.  
The approximation is done by a Polynomial and teh filtration is done in the Spatial Domain.  
The filter is defined by a function which sets the filter coefficients as a function of the Gaussian Kernel STD.  
If the filter (As implemented here) order is independent of the STD parameter, the complexity is constant.  

## Running The Code
Download all the MATLAB files.  
Run `GaussianBlurApproximationAnalysis` and see the results on MATLAB main screen.  
Play with te parameters as you wish.

## RoadMap
 1. Implement the following methods:
  - [StackBlur][6].
  - [Efficient and Accurate Gaussian Image Filtering Using Running Sums][7]
 2. Create MEX implementations.

## To Do List
 1. Make the second method of the IIR Filter work.
 2. Create a system to compare the methos over a range of STD and image size.
 3. Include all the required references (Most are shown in the files).

## Refrences
 1. [FilterM][3] - Efficient implementation of MATLAB [`filter`][4] by [Jan Simon][5].

  [1]: http://en.wikipedia.org/wiki/Central_limit_theorem
  [2]: http://en.wikipedia.org/wiki/Summed_area_table
  [3]: http://www.mathworks.com/matlabcentral/fileexchange/32261-filterm
  [4]: http://www.mathworks.com/help/matlab/ref/filter.html
  [5]: http://www.mathworks.com/matlabcentral/profile/authors/869888-jan-simon
  [6]: http://www.quasimondo.com/StackBlurForCanvas/StackBlurDemo.html
  [7]: http://arxiv.org/abs/1107.4958
