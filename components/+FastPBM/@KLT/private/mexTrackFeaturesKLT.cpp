// Copyright 2006 David D. Diel, MIT License
#include "mex.h"
#include "hidi.h"

static const double MAX_ITERATIONS = 10;
static const double DELTA_THRESH = 0.01;

/**
 * KLT based tracker for a single independent feature
 */
class TrackerKLT
{
private:
  double *Iap;
  double *gxap;
  double *gyap;
  double *Ibp;
  double *gxbp;
  double *gybp;
  int halfwin;
  int win;
  int win2;

  /* bounds checking */
  static bool OutOfBounds(const int xf, const int yf, const int M, const int N, const int radius)
  {
    return((xf-radius)<0||(yf-radius)<0||(xf+radius)>(M-2)||(yf+radius)>(N-2));
  }

public:
  /**
   * Constructor
   *
   * @param[in] halfWindowSize half tracking window size
   */
  TrackerKLT(int halfWindowSize)
  {
    halfwin = halfWindowSize;
    win = 2*halfwin+1;
    win2 = win*win;

    /* allocate memory for all patches */
    Iap = new double[win2];
    gxap = new double[win2];
    gyap = new double[win2];
    Ibp = new double[win2];
    gxbp = new double[win2];
    gybp = new double[win2];
    return;
  }

  /**
   * Destructor that frees memory for feature windows
   */
  ~TrackerKLT(void)
  {
    delete[] Iap;
    delete[] gxap;
    delete[] gyap;
    delete[] Ibp;
    delete[] gxbp;
    delete[] gybp;
    return;
  }

  /**
   * Track a single independent feature
   *
   * @param[in] Ia     first image in the range [0,1]
   * @param[in] gxa    gradient of first image along contiguous dimension
   * @param[in] gya    gradient of first image along non-contiguous dimension
   * @param[in] xa     zero-based sub-pixel location in the first image along contiguous dimension
   * @param[in] ya     zero-based sub-pixel location in the first image along non-contiguous dimension
   * @param[in] Ib     second image in the range [0,1]
   * @param[in] gxb    gradient of second image along contiguous dimension
   * @param[in] gyb    gradient of second image along non-contiguous dimension
   * @param[in] xbe    zero-based estimate of location in the second image along contiguous dimension
   * @param[in] ybe    zero-based estimate of location in the sedond image along non-contiguous dimension
   * @param[in] thresh confidence threshold for feature matching in the range [0,1]
   * @param[in] M      image size in pixels along contiguous dimension
   * @param[in] N      image size in pixels along non-contiguous dimension
   * @param[out] xb    sub-pixel location in the second image along contiguous dimension
   * @param[out] yb    sub-pixel location in the second image along non-contiguous dimension
   *
   * RETURNS:
   * The outputs are set to NAN in the following cases:
   *   If NAN is encountered while processing inputs
   *   If the feature cannot be found in the second image
   *   If the sum of absolute image differences between matched features exceeds the variation within the first feature
   *   If the sum of absolute image differences between matched features exceeds the specified threshold
   */
  void trackFeature(const double *Ia, const double *gxa, const double *gya, const double xa, const double ya, 
    const double *Ib, const double *gxb, const double *gyb, const double xbe, const double ybe, const double thresh, 
    const int M, const int N, double *xb, double *yb)
  {
    double xo, yo, xr, yr;
    double a00, a01, a10, a11;
    double gx, gy, gt, xx, yy, xy, xt, yt;
    double det, dx, dy, interpb, sumab, residue;
    int iteration;
    int xf, yf;
    int p00, p01, p10, p11;
    int i, j, p;
    int strideMinusWin = M-win;

    /* check for NAN inputs */
    if(mxIsNaN(xa)||mxIsNaN(ya)||mxIsNaN(xbe)||mxIsNaN(ybe))
    {
      (*xb) = NAN;
      (*yb) = NAN;
      return;
    }
    
    /* shift the coordinate system to align with imageA */
    xf = (int)floor(xa+0.5);
    yf = (int)floor(ya+0.5);

    /* check bounds */
    if(OutOfBounds(xf, yf, M, N, halfwin+1))
    {
      (*xb) = NAN;
      (*yb) = NAN;
      return;
    }
    
    xo = xa-(double)xf; /* coordinate offset */
    yo = ya-(double)yf; /* coordinate offset */

    (*xb) = xbe-xo; /* estimated patch center in imageB */
    (*yb) = ybe-yo; /* estimated patch center in imageB */

    p00 = (xf-halfwin)+(yf-halfwin)*M; /* patch upper left corner */

    p = 0;
    for(j = 0; j<win; ++j)
    {
      for(i = 0; i<win; ++i)
      {
        Iap[p] = Ia[p00];
        gxap[p] = gxa[p00];
        gyap[p] = gya[p00];
        p++;
        p00++;
      }
      p00 += strideMinusWin;
    }
    
    /* iteratively update the delta position */
    iteration = 0;
    do
    {
      /* extract the patches in imageB through bilinear interpolation */
      xr = (*xb)-(double)xf;
      yr = (*yb)-(double)yf;

      /* calculate relative weights */
      a00 = (1.0-yr)*(1.0-xr);
      a01 = yr*(1.0-xr);
      a10 = (1.0-yr)*xr;
      a11 = yr*xr;

      /* calculate initial array position offsets */
      p00 = xf-halfwin+(yf-halfwin)*M;
      p01 = p00+M;
      p10 = p00+1;
      p11 = p01+1;

      /* run through and extract new patches */
      p = 0;
      for(j = 0; j<win; ++j)
      {
        for(i = 0; i<win; ++i)
        {
          Ibp[p] = Ib[p00]*a00+Ib[p01]*a01+Ib[p10]*a10+Ib[p11]*a11;
          gxbp[p] = gxb[p00]*a00+gxb[p01]*a01+gxb[p10]*a10+gxb[p11]*a11;
          gybp[p] = gyb[p00]*a00+gyb[p01]*a01+gyb[p10]*a10+gyb[p11]*a11;
          p++;
          p00++;
          p01++;
          p10++;
          p11++;
        }
        p00 += strideMinusWin;
        p01 += strideMinusWin;
        p10 += strideMinusWin;
        p11 += strideMinusWin;
      }

      /* compute gradient sums */
      xx = 0;
      yy = 0;
      xy = 0;
      xt = 0;
      yt = 0;
      for(p = 0; p<win2; ++p)
      {
        gx = (gxap[p]+gxbp[p])/2.0;
        gy = (gyap[p]+gybp[p])/2.0;
        gt = Ibp[p]-Iap[p];
        xx += gx*gx;
        yy += gy*gy;
        xy += gx*gy;
        xt += gx*gt;
        yt += gy*gt;
      }

      /* calculate the flow equation determinant */
      det = xx*yy-xy*xy;

      /* deal with small determinants or NAN */
      if((fabs(det)<EPS)||mxIsNaN(det))
      {
        (*xb) = NAN;
        (*yb) = NAN;
        return;
      }

      /* solve the flow equation */
      dx = (xy*yt-xt*yy)/det;
      dy = (xt*xy-xx*yt)/det;

      (*xb) += dx;
      (*yb) += dy;

      xf = (int)floor(*xb);
      yf = (int)floor(*yb);

      /* check bounds */
      if(OutOfBounds(xf, yf, M, N, halfwin+1))
      {
        (*xb) = NAN;
        (*yb) = NAN;
        return;
      }

      iteration++;
    }
    while((fabs(dx)>=DELTA_THRESH||fabs(dy)>=DELTA_THRESH)&&(iteration<MAX_ITERATIONS));
    
    /* final check */
    xr = (*xb)-(double)xf;
    yr = (*yb)-(double)yf;

    /* calculate relative weights */
    a00 = (1.0-yr)*(1.0-xr);
    a01 = yr*(1.0-xr);
    a10 = (1.0-yr)*xr;
    a11 = yr*xr;

    /* calculate initial array position offsets */
    p00 = xf-halfwin+(yf-halfwin)*M;
    p01 = p00+M;
    p10 = p00+1;
    p11 = p01+1;

    /* run through and sum absolute intensity differences */
    p = 0;
    residue = 0.0;
    sumab = 0.0;
    for(j = 0; j<win; ++j)
    {
      for(i = 0; i<win; ++i)
      {
        interpb = Ib[p00]*a00+Ib[p01]*a01+Ib[p10]*a10+Ib[p11]*a11;
        sumab += interpb+Iap[p]; 
        residue += fabs(interpb-Iap[p]);
        p++;
        p00++;
        p01++;
        p10++;
        p11++;
      }
      p00 += strideMinusWin;
      p01 += strideMinusWin;
      p10 += strideMinusWin;
      p11 += strideMinusWin;
    }
        
    /* check sum of absolute difference residue threshold */
    if(residue>(sumab*(1.0-thresh)))
    {
      (*xb) = NAN;
      (*yb) = NAN;
      return;
    }

    /* readjust coordinate system offset */
    (*xb) += xo;
    (*yb) += yo;

    return;
  }
};

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  TrackerKLT *tracker;
  int M, N;
  int k, K;
  int cnt;
  double *imageA, *gxA, *gyA, *xA, *yA, *imageB, *gxB, *gyB, *xB, *yB, *xb, *yb;
  double halfwin, thresh;
  int outdims[2];

  /* check for proper number of inputs */
  if(nrhs!=12)
  {
    mexErrMsgTxt("[xB, yB] = mexTrackFeaturesKLT(imageA, gxA, gyA, xA, yA, imageB, gxB, gyB, xB, yB, halfwin, thresh)");
  }
  else if(nlhs>2)
  {
    mexErrMsgTxt("Too many output arguments.");
  }

  /* the inputs must be of the correct type */
  for(cnt = 0; cnt<nrhs; cnt++)
  {
    if(mxIsComplex(prhs[cnt])||!mxIsDouble(prhs[cnt]))
    {
      mexErrMsgTxt("All inputs must real double.");
    }
  }

  /* extract array sizes */
  M = mxGetM(prhs[0]);
  N = mxGetN(prhs[0]);

  /* check all other images for same size */
  if((mxGetM(prhs[1])!=M)||(mxGetN(prhs[1])!=N)||(mxGetM(prhs[2])!=M)||(mxGetN(prhs[2])!=N)||(mxGetM(prhs[5])!=M)
      ||(mxGetN(prhs[6])!=N)||(mxGetM(prhs[6])!=M)||(mxGetN(prhs[6])!=N)||(mxGetM(prhs[7])!=M)||(mxGetN(prhs[7])!=N))
  {
    mexErrMsgTxt("All input images must be of the same size.");
  }

  /* check list lengths */
  k = mxGetM(prhs[3]);
  K = mxGetN(prhs[3]);

  if((mxGetM(prhs[4])!=k)||(mxGetN(prhs[4])!=K)||(mxGetM(prhs[8])!=k)||(mxGetN(prhs[8])!=K)||(mxGetM(prhs[9])!=k)
      ||(mxGetN(prhs[9])!=K))
  {
    mexErrMsgTxt("Coordinate lists must be the same size.");
  }

  /* check last few arguments */
  if((mxGetM(prhs[10])!=1)||(mxGetN(prhs[10])!=1)||(mxGetM(prhs[11])!=1)||(mxGetN(prhs[11])!=1))
  {
    mexErrMsgTxt("Last two arguments must be scalar.");
  }

  imageA = (double*)mxGetData(prhs[0]);
  gxA = (double*)mxGetData(prhs[1]);
  gyA = (double*)mxGetData(prhs[2]);
  xA = (double*)mxGetData(prhs[3]);
  yA = (double*)mxGetData(prhs[4]);
  imageB = (double*)mxGetData(prhs[5]);
  gxB = (double*)mxGetData(prhs[6]);
  gyB = (double*)mxGetData(prhs[7]);
  xB = (double*)mxGetData(prhs[8]);
  yB = (double*)mxGetData(prhs[9]);
  halfwin = *(double*)mxGetData(prhs[10]);
  thresh = *(double*)mxGetData(prhs[11]);

  /* allocate memory for return arguments and assign pointers */
  outdims[0] = k;
  outdims[1] = K;
  plhs[0] = mxCreateNumericArray(2, outdims, mxDOUBLE_CLASS, mxREAL);
  plhs[1] = mxCreateNumericArray(2, outdims, mxDOUBLE_CLASS, mxREAL);
  xb = (double*)mxGetData(plhs[0]);
  yb = (double*)mxGetData(plhs[1]);

  /* deal with empty list case */
  if((k==0)||(K==0))
  {
    return;
  }

  /* use the largest list dimension as its length */
  if(k>K)
  {
    K = k;
  }

  tracker = new TrackerKLT((int)floor(halfwin+0.5));
  for(k = 0; k<K; k++)
  {
    /* call the function to do the work */
    tracker->trackFeature(imageA, gxA, gyA, xA[k], yA[k], imageB, gxB, gyB, xB[k], yB[k], thresh, M, N, &xb[k], &yb[k]);
  }
  delete tracker;
  
  return;
}
