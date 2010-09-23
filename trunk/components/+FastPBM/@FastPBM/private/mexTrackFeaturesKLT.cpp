#include <math.h>

#include "mex.h"

#define  NaN             sqrt(-1.0)
#define  MAX_ITERATIONS  10
#define  SMALL_DET       0.00005
#define  DELTA_THRESH    0.1

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
  static bool OutOfBounds(const int x, const int y, const int m, const int n, const int radius)
  {
    return((x-radius)<1||(y-radius)<1||(x+radius)>(m-1)||(y+radius)>(n-1));
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
    win = 2*halfwin;
    win2 = win*win;

    /* allocate memory for all six patches */
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
   * @param[in] xa     sub-pixel location in the first image along contiguous dimension
   * @param[in] ya     sub-pixel location in the first image along non-contiguous dimension
   * @param[in] Ib     second image in the range [0,1]
   * @param[in] gxb    gradient of second image along contiguous dimension
   * @param[in] gyb    gradient of second image along non-contiguous dimension
   * @param[in] xbe    estimate of location in the second image along contiguous dimension
   * @param[in] ybe    estimate of location in the sedond image along non-contiguous dimension
   * @param[in] L      pyramid level on which to interperet coordinates
   * @param[in] thresh matching threshold below which features will not be matched
   * @param[in] m      image size in pixels along contiguous dimension
   * @param[in] n      image size in pixels along non-contiguous dimension
   * @param[out] xb    sub-pixel location in the second image along contiguous dimension
   * @param[out] yb    sub-pixel location in the second image along non-contiguous dimension
   *
   * RETURNS:
   * The outputs are set to NaN in the following cases:
   *   If NaN is encountered while processing inputs
   *   If the feature cannot be found in the second image
   *   If the sum of absolute image differences between feature locations exceeds the specified threshold
   */
  void trackFeature(const double *Ia, const double *gxa, const double *gya, const double xa, const double ya, 
    const double *Ib, const double *gxb, const double *gyb, const double xbe, const double ybe, const double L, 
    const double thresh, const int m, const int n, double *xb, double *yb)
  {
    int mmwin = m-win;
    double scale = pow(2.0, L-1.0);

    int iteration;
    double xo, yo, xr, yr;
    double a00, a01, a10, a11;
    double gx, gy, gt, xx, yy, xy, xt, yt;
    double det, dx, dy, residue;
    double xas, yas, xbes, ybes;
    int xf, yf;
    int p00, p01, p10, p11;
    int i, j, p;

    /* check for NaN inputs */
    if(mxIsNaN(xa)||mxIsNaN(ya)||mxIsNaN(xbe)||mxIsNaN(ybe))
    {
      (*xb) = NaN;
      (*yb) = NaN;
      return;
    }

    /* scale the coordinate system to the appropriate pyramid level */
    xas = xa/scale;
    yas = ya/scale;
    xbes = xbe/scale;
    ybes = ybe/scale;

    /* shift the coordinate system to align with image a */
    xf = (int)floor(xas+0.5);
    yf = (int)floor(yas+0.5);

    /* check bounds */
    if(OutOfBounds(xf, yf, m, n, halfwin))
    {
      (*xb) = NaN;
      (*yb) = NaN;
      return;
    }

    xo = xas-(double)xf; /* coordinate offset */
    yo = yas-(double)yf; /* coordinate offset */

    (*xb) = xbes-xo; /* estimated patch center in image b */
    (*yb) = ybes-yo; /* estimated patch center in image b */

    p00 = (xf-halfwin)+(yf-halfwin)*m; /* patch upper left corner */

    p = 0;
    for(j = 0; j<win; j++)
    {
      for(i = 0; i<win; i++)
      {
        Iap[p] = Ia[p00];
        gxap[p] = gxa[p00];
        gyap[p] = gya[p00];
        p++;
        p00++;
      }
      p00 += mmwin;
    }

    /* iteratively update the delta position */
    iteration = 0;
    do
    {
      /* extract the patches in image b through bilinear interpolation */
      xr = (*xb)-(double)xf;
      yr = (*yb)-(double)yf;

      /* calculate relative weights */
      a00 = (1.0-yr)*(1.0-xr);
      a01 = yr*(1.0-xr);
      a10 = (1.0-yr)*xr;
      a11 = yr*xr;

      /* calculate initial array position offsets */
      p00 = xf-halfwin+(yf-halfwin)*m;
      p01 = p00+m;
      p10 = p00+1;
      p11 = p01+1;

      /* run through and extract new patches */
      p = 0;
      for(j = 0; j<win; j++)
      {
        for(i = 0; i<win; i++)
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
        p00 += mmwin;
        p01 += mmwin;
        p10 += mmwin;
        p11 += mmwin;
      }

      /* compute gradient sums */
      xx = 0;
      yy = 0;
      xy = 0;
      xt = 0;
      yt = 0;
      for(p = 0; p<win2; p++)
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

      /* deal with small determinants */
      if(det<SMALL_DET)
      {
        (*xb) = NaN;
        (*yb) = NaN;
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
      if((xf<1.0)||(yf<1.0)||(xf>(m-1.0))||(yf>(n-1.0)))
      {
        (*xb) = NaN;
        (*yb) = NaN;
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
    p00 = xf-halfwin+(yf-halfwin)*m;
    p01 = p00+m;
    p10 = p00+1;
    p11 = p01+1;

    /* run through and sum absolute intensity differences */
    p = 0;
    residue = 0.0;
    for(j = 0; j<win; j++)
    {
      for(i = 0; i<win; i++)
      {
        residue += fabs(Ib[p00]*a00+Ib[p01]*a01+Ib[p10]*a10+Ib[p11]*a11-Iap[p]);
        p++;
        p00++;
        p01++;
        p10++;
        p11++;
      }
      p00 += mmwin;
      p01 += mmwin;
      p10 += mmwin;
      p11 += mmwin;
    }

    /* check sum of absolute difference residue threshold */
    if((residue/(double)win2)>(1-thresh))
    {
      (*xb) = NaN;
      (*yb) = NaN;
      return;
    }

    /* readjust coordinate system offset */
    (*xb) += xo;
    (*yb) += yo;

    /* readjust coordinate system scale */
    (*xb) *= scale;
    (*yb) *= scale;

    return;
  }
};

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  TrackerKLT *tracker;
  int k, m, n, K;
  int cnt;
  double *Ia, *gxa, *gya, *xa, *ya, *Ib, *gxb, *gyb, *xbe, *ybe, *xb, *yb;
  double L, halfwin, thresh;
  int outdims[2];

  /* check for proper number of inputs */
  if(nrhs!=13)
  {
    mexErrMsgTxt("[xb,yb]=MEXtrackFeatures(Ia,gxa,gya,xa,ya,Ib,gxb,gyb,xbe,ybe,L,win,thresh);");
  }
  else if(nlhs>2)
  {
    mexErrMsgTxt("Too many output arguments");
  }

  /* the inputs must be of the correct type */
  for(cnt = 0; cnt<12; cnt++)
  {
    if(mxIsComplex(prhs[cnt])||!mxIsDouble(prhs[cnt]))
    {
      mexErrMsgTxt("Inputs must real double.");
    }
  }

  /* extract array sizes */
  m = mxGetM(prhs[0]);
  n = mxGetN(prhs[0]);

  /* check all other images for same size */
  if((mxGetM(prhs[1])!=m)||(mxGetN(prhs[1])!=n)||(mxGetM(prhs[2])!=m)||(mxGetN(prhs[2])!=n)||(mxGetM(prhs[5])!=m)
      ||(mxGetN(prhs[6])!=n)||(mxGetM(prhs[6])!=m)||(mxGetN(prhs[6])!=n)||(mxGetM(prhs[7])!=m)||(mxGetN(prhs[7])!=n))
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
  if((mxGetM(prhs[10])!=1)||(mxGetN(prhs[10])!=1)||(mxGetM(prhs[11])!=1)||(mxGetN(prhs[11])!=1)||(mxGetM(prhs[12])!=1)
      ||(mxGetN(prhs[12])!=1))
  {
    mexErrMsgTxt("Last two arguments must be scalar.");
  }

  Ia = (double*)mxGetData(prhs[0]);
  gxa = (double*)mxGetData(prhs[1]);
  gya = (double*)mxGetData(prhs[2]);
  xa = (double*)mxGetData(prhs[3]);
  ya = (double*)mxGetData(prhs[4]);
  Ib = (double*)mxGetData(prhs[5]);
  gxb = (double*)mxGetData(prhs[6]);
  gyb = (double*)mxGetData(prhs[7]);
  xbe = (double*)mxGetData(prhs[8]);
  ybe = (double*)mxGetData(prhs[9]);
  L = *(double*)mxGetData(prhs[10]);
  halfwin = *(double*)mxGetData(prhs[11]);
  thresh = *(double*)mxGetData(prhs[12]);

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
    /* call the function to do the work, and change Matlab indices to C convention */
    tracker->trackFeature(Ia, gxa, gya, xa[k]-1.0, ya[k]-1.0, Ib, gxb, gyb, xbe[k]-1.0, ybe[k]-1.0, L, 
      thresh, m, n, &xb[k], &yb[k]);

    /* change C indices to Matlab convention */
    xb[k] += 1.0;
    yb[k] += 1.0;
  }
  delete tracker;

  return;
}
