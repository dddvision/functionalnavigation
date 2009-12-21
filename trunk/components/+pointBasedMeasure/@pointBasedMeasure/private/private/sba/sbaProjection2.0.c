#include <stdio.h> 
#include <math.h>

/* Sample C code for the projection and Jacobian functions for Euclidean BA,
 * to be loaded from a shared (i.e., dynamic) library by sba's matlab MEX interface
 */

/* Compilation instructions:
 *
 * Un*x/GCC:    gcc -fPIC -O3 -shared -o projac.so projac.c
 * Win32/MSVC:  cl /nologo /O2 projac.c /link /dll /out:projac.dll
 */

#if defined(_MSC_VER) /* DLL directives for MSVC */
#define API_MOD    __declspec(dllexport)
#define CALL_CONV  __cdecl
#else /* define empty */
#define API_MOD 
#define CALL_CONV
#endif /* _MSC_VER */

API_MOD void CALL_CONV affinekap1kap2p1p2Ignored(double *rt, double *xyz, double *xij, double **adata) { 
double x, y, z, q1, q2, q3, q4, tr1, tr2, k1, k2, k3;

double t1, t2, t3, t4, t8, t10, t11, t12;

x = xyz[0];
y = xyz[1];
z = xyz[2];
q1 = rt[0];
q2 = rt[1];
q3 = rt[2];
q4 = rt[3];
tr1 = rt[4];
tr2 = rt[5];
k1 = rt[6];
k2 = rt[7];
k3 = rt[8];

      t1 = q1*q1;      t2 = q2*q2;      t3 = q3*q3;      t4 = q4*q4;      t8 = 1/(t1+t2+t3+t4);      t10 = q1*q4;      t11 = q2*q3;      t12 = t10+t11;      xij[0] = (k1*(t1+t2-t3-t4)*t8+2.0*k2*t12*t8)*x+k1*(2.0*(t11-t10)*t8*y+2.0*(q1*q3+q2*q4)*t8*z+tr1)+k2*((t1-t2+t3-t4)*t8*y+2.0*(q3*q4-q1*q2)*t8*z+tr2);      xij[1] = 2.0*k3*t12*t8*x+k3*(y*t1-y*t2+y*t3-y*t4+2.0*z*q3*q4-2.0*z*q1*q2+tr2*t1+tr2*t2+tr2*t3+tr2*t4)*t8;
}

API_MOD void CALL_CONV affinekap1kap2p1p2IgnoredJac(double *rt, double *xyz, double *Aij, double *Bij, double **adata) { 
double x, y, z, q1, q2, q3, q4, tr1, tr2, k1, k2, k3;

double t1, t2, t3, t4, t5, t6, t7, t8, t10, t11, t12, t13, t16, t19, t25, t30, t34, t42, t43, t44, t51, t52, t53, t54, t56, t57, t58, t59, t63, t64, t65, t67, t68, t69, t76, t83, t84, t86, t87, t91, t93, t100, t107, t109, t120, t127, t129, t146, t173, t174;

x = xyz[0];
y = xyz[1];
z = xyz[2];
q1 = rt[0];
q2 = rt[1];
q3 = rt[2];
q4 = rt[3];
tr1 = rt[4];
tr2 = rt[5];
k1 = rt[6];
k2 = rt[7];
k3 = rt[8];

      t1 = q1*q1;      t2 = q2*q2;      t3 = q3*q3;      t4 = q4*q4;      t5 = t1+t2-t3-t4;      t6 = k1*t5;      t7 = t1+t2+t3+t4;      t8 = 1/t7;      t10 = q1*q4;      t11 = q2*q3;      t12 = t10+t11;      t13 = 2.0*k2*t12;      t16 = t11-t10;      t19 = t1-t2+t3-t4;      t25 = q1*q3+q2*q4;      t30 = q3*q4-q1*q2;      t34 = 2.0*k3*t12;      t42 = t7*t7;      t43 = 1/t42;      t44 = t43*q1;      t51 = q4*t8;      t52 = t51*y;      t53 = 2.0*t16*t43;      t54 = y*q1;      t56 = q3*t8;      t57 = t56*z;      t58 = 2.0*t25*t43;      t59 = z*q1;      t63 = q1*t8;      t64 = t63*y;      t65 = t19*t43;      t67 = q2*t8;      t68 = t67*z;      t69 = 2.0*t30*t43;      t76 = t43*q2;      t83 = t56*y;      t84 = y*q2;      t86 = t51*z;      t87 = z*q2;      t91 = t67*y;      t93 = t63*z;      t100 = t43*q3;      t107 = y*q3;      t109 = z*q3;      t120 = t43*q4;      t127 = y*q4;      t129 = z*q4;      t146 = 2.0*t12*t8*x;      t173 = y*t1-y*t2+y*t3-y*t4+2.0*t109*q4-2.0*t59*q2+tr2*t1+tr2*t2+tr2*t3+tr2*t4;      t174 = k3*t173;      Bij[0] = t6*t8+t13*t8;      Bij[1] = 2.0*k1*t16*t8+k2*t19*t8;      Bij[2] = 2.0*k1*t25*t8+2.0*k2*t30*t8;      Bij[3] = t34*t8;      Bij[4] = k3*t19*t8;      Bij[5] = 2.0*k3*t30*t8;      Aij[0] = 2.0*(k1*q1*t8-t6*t44+k2*q4*t8-t13*t44)*x+2.0*k1*(-t52-t53*t54+t57-t58*t59)+2.0*k2*(t64-t65*t54-t68-t69*t59);      Aij[1] = 2.0*(k1*q2*t8-t6*t76+k2*q3*t8-t13*t76)*x+2.0*k1*(t83-t53*t84+t86-t58*t87)+2.0*k2*(-t91-t65*t84-t93-t69*t87);      Aij[2] = 2.0*(-k1*q3*t8-t6*t100+k2*q2*t8-t13*t100)*x+2.0*k1*(t91-t53*t107+t93-t58*t109)+2.0*k2*(t83-t65*t107+t86-t69*t109);      Aij[3] = 2.0*(-k1*q4*t8-t6*t120+k2*q1*t8-t13*t120)*x+2.0*k1*(-t64-t53*t127+t68-t58*t129)+2.0*k2*(-t52-t65*t127+t57-t69*t129);      Aij[4] = k1;      Aij[5] = k2;      Aij[6] = t5*t8*x+2.0*t16*t8*y+2.0*t25*t8*z+tr1;      Aij[7] = t146+t19*t8*y+2.0*t30*t8*z+tr2;      Aij[8] = 0.0;      Aij[9] = 2.0*(k3*q4*t8-t34*t44)*x+2.0*k3*(t54-t87+tr2*q1)*t8-2.0*t174*t44;      Aij[10] = 2.0*(k3*q3*t8-t34*t76)*x+2.0*k3*(-t84-t59+tr2*q2)*t8-2.0*t174*t76;      Aij[11] = 2.0*(k3*q2*t8-t34*t100)*x+2.0*k3*(t107+t129+tr2*q3)*t8-2.0*t174*t100;      Aij[12] = 2.0*(k3*q1*t8-t34*t120)*x+2.0*k3*(-t127+t109+tr2*q4)*t8-2.0*t174*t120;      Aij[13] = 0.0;      Aij[14] = k3;      Aij[15] = 0.0;      Aij[16] = 0.0;      Aij[17] = t146+t173*t8;
}

API_MOD void CALL_CONV affinek1k2k3kap1kap2p1p2Ignored(double *rt, double *xyz, double *xij, double **adata) { 

double x, y, z, q1, q2, q3, q4, tr1, tr2;

double t1, t2, t3, t4, t7, t16;

x = xyz[0];
y = xyz[1];
z = xyz[2];
q1 = rt[0];
q2 = rt[1];
q3 = rt[2];
q4 = rt[3];
tr1 = rt[4];
tr2 = rt[5];

      t1 = q1*q1;      t2 = q2*q2;      t3 = q3*q3;      t4 = q4*q4;      t7 = 1/(t1+t2+t3+t4);      t16 = z*q1;      xij[0] = (t1+t2-t3-t4)*t7*x+(2.0*y*q2*q3-2.0*y*q1*q4+2.0*t16*q3+2.0*z*q2*q4+tr1*t1+tr1*t2+tr1*t3+tr1*t4)*t7;      xij[1] = 2.0*(q1*q4+q2*q3)*t7*x+(y*t1-y*t2+y*t3-y*t4+2.0*z*q3*q4-2.0*t16*q2+tr2*t1+tr2*t2+tr2*t3+tr2*t4)*t7;
}

API_MOD void CALL_CONV affinek1k2k3kap1kap2p1p2IgnoredJac(double *rt, double *xyz, double *Aij, double *Bij, double **adata) { 
double x, y, z, q1, q2, q3, q4, tr1, tr2;

double t1, t2, t3, t4, t5, t6, t7, t9, t10, t17, t25, t26, t27, t28, t32, t33, t37, t40, t43, t46, t54, t58, t62, t63, t70, t80, t90, t110;

x = xyz[0];
y = xyz[1];
z = xyz[2];
q1 = rt[0];
q2 = rt[1];
q3 = rt[2];
q4 = rt[3];
tr1 = rt[4];
tr2 = rt[5];

      t1 = q1*q1;      t2 = q2*q2;      t3 = q3*q3;      t4 = q4*q4;      t5 = t1+t2-t3-t4;      t6 = t1+t2+t3+t4;      t7 = 1/t6;      t9 = q2*q3;      t10 = q1*q4;      t17 = t10+t9;      t25 = q1*t7;      t26 = t6*t6;      t27 = 1/t26;      t28 = t5*t27;      t32 = y*q4;      t33 = z*q3;      t37 = y*q2;      t40 = y*q1;      t43 = z*q1;      t46 = z*q2;      t54 = (2.0*t37*q3-2.0*t40*q4+2.0*t43*q3+2.0*t46*q4+tr1*t1+tr1*t2+tr1*t3+tr1*t4)*t27;      t58 = q2*t7;      t62 = y*q3;      t63 = z*q4;      t70 = q3*t7;      t80 = q4*t7;      t90 = 2.0*t17*t27;      t110 = (y*t1-y*t2+y*t3-y*t4+2.0*t33*q4-2.0*t43*q2+tr2*t1+tr2*t2+tr2*t3+tr2*t4)*t27;      Bij[0] = t5*t7;      Bij[1] = 2.0*(t9-t10)*t7;      Bij[2] = 2.0*(q1*q3+q2*q4)*t7;      Bij[3] = 2.0*t17*t7;      Bij[4] = (t1-t2+t3-t4)*t7;      Bij[5] = 2.0*(q3*q4-q1*q2)*t7;      Aij[0] = 2.0*(t25-t28*q1)*x+2.0*(-t32+t33+tr1*q1)*t7-2.0*t54*q1;      Aij[1] = 2.0*(t58-t28*q2)*x+2.0*(t62+t63+tr1*q2)*t7-2.0*t54*q2;      Aij[2] = 2.0*(-t70-t28*q3)*x+2.0*(t37+t43+tr1*q3)*t7-2.0*t54*q3;      Aij[3] = 2.0*(-t80-t28*q4)*x+2.0*(-t40+t46+tr1*q4)*t7-2.0*t54*q4;      Aij[4] = 1.0;      Aij[5] = 0.0;      Aij[6] = 2.0*(t80-t90*q1)*x+2.0*(t40-t46+tr2*q1)*t7-2.0*t110*q1;      Aij[7] = 2.0*(t70-t90*q2)*x+2.0*(-t37-t43+tr2*q2)*t7-2.0*t110*q2;      Aij[8] = 2.0*(t58-t90*q3)*x+2.0*(t62+t63+tr2*q3)*t7-2.0*t110*q3;      Aij[9] = 2.0*(t25-t90*q4)*x+2.0*(-t32+t33+tr2*q4)*t7-2.0*t110*q4;      Aij[10] = 0.0;      Aij[11] = 1.0;
}

API_MOD void CALL_CONV projectivekap1kap2p1p2Ignored(double *rt, double *xyz, double *xij, double **adata) { 
double x, y, z, q1, q2, q3, q4, tr1, tr2, tr3, k1, k2, k3, k4, k5;

double t1, t2, t4, t5, t7, t10, t11, t14, t15, t18, t19, t22, t25, t26, t29, t32, t35, t40, t43, t48, t75, t77, t93, t98;

x = xyz[0];
y = xyz[1];
z = xyz[2];
q1 = rt[0];
q2 = rt[1];
q3 = rt[2];
q4 = rt[3];
tr1 = rt[4];
tr2 = rt[5];
tr3 = rt[6];
k1 = rt[7];
k2 = rt[8];
k3 = rt[9];
k4 = rt[10];
k5 = rt[11];

      t1 = k2*y;      t2 = q4*q4;      t4 = k2*tr2;      t5 = q2*q2;      t7 = q3*q3;      t10 = k4*z;      t11 = q1*q1;      t14 = k1*z;      t15 = q2*q4;      t18 = k1*y;      t19 = q2*q3;      t22 = q1*q4;      t25 = k2*z;      t26 = q3*q4;      t29 = q1*q2;      t32 = q1*q3;      t35 = k4*y;      t40 = -t1*t2+t4*t5+t4*t7+t4*t2+t10*t11-t10*t5+2.0*t14*t15+2.0*t18*t19-2.0*t18*t22+2.0*t25*t26-2.0*t25*t29+2.0*t14*t32+2.0*t35*t29+2.0*t35*t26;      t43 = k4*tr3;      t48 = k1*tr1;      t75 = -t10*t7+t10*t2+t43*t11+t43*t7+t43*t5+t43*t2+t48*t11+t48*t5+t48*t7+t4*t11+t48*t2+t1*t11-t1*t5+t1*t7+(k1*t11+k1*t5-k1*t7-k1*t2+2.0*k2*q1*q4+2.0*k2*q2*q3+2.0*k4*q2*q4-2.0*k4*q1*q3)*x;      t77 = t15-t32;      t93 = 2.0*t77*x+z*t11-z*t5+2.0*y*q1*q2+2.0*y*q3*q4+tr3*t11+tr3*t5-z*t7+z*t2+tr3*t7+tr3*t2;      t98 = 1/(t11+t5+t7+t2);      xij[0] = (t40+t75)/t93;      xij[1] = k3*(2.0*(t22+t19)*t98*x+(t11-t5+t7-t2)*t98*y+2.0*(t26-t29)*t98*z+tr2)/(2.0*t77*t98*x+2.0*(t29+t26)*t98*y+(t11-t5-t7+t2)*t98*z+tr3)+k5;
}

API_MOD void CALL_CONV projectivekap1kap2p1p2IgnoredJac(double *rt, double *xyz, double *Aij, double *Bij, double **adata) { 
double x, y, z, q1, q2, q3, q4, tr1, tr2, tr3, k1, k2, k3, k4, k5;

double t1, t2, t3, t4, t5, t6, t7, t8, t9, t18, t22, t25, t28, t30, t31, t33, t34, t35, t36, t37, t38, t39, t40, t41, t42, t43, t45, t47, t51, t53, t55, t56, t59, t62, t63, t66, t71, t78, t81, t90, t93, t94, t97, t100, t105, t112, t114, t116, t117, t120, t121, t122, t123, t124, t127, t137, t140, t141, t142, t152, t155, t158, t160, t161, t168, t169, t170, t174, t177, t180, t181, t182, t183, t212, t214, t215, t216, t233, t235, t236, t253, t255, t256, t273, t275, t282, t283, t320, t322, t323, t324, t325, t326, t328, t329, t330, t332, t333, t334, t339, t340, t341, t343, t344, t346, t347, t366, t368, t370, t375, t377, t379;

x = xyz[0];
y = xyz[1];
z = xyz[2];
q1 = rt[0];
q2 = rt[1];
q3 = rt[2];
q4 = rt[3];
tr1 = rt[4];
tr2 = rt[5];
tr3 = rt[6];
k1 = rt[7];
k2 = rt[8];
k3 = rt[9];
k4 = rt[10];
k5 = rt[11];

      t1 = q1*q1;      t2 = k1*t1;      t3 = q2*q2;      t4 = k1*t3;      t5 = q3*q3;      t6 = k1*t5;      t7 = q4*q4;      t8 = k1*t7;      t9 = k2*q1;      t18 = k4*q1;      t22 = x*q2;      t25 = x*q1;      t28 = y*q1;      t30 = 2.0*t28*q2;      t31 = y*q3;      t33 = 2.0*t31*q4;      t34 = z*t1;      t35 = z*t3;      t36 = z*t5;      t37 = z*t7;      t38 = tr3*t1;      t39 = tr3*t3;      t40 = tr3*t5;      t41 = tr3*t7;      t42 = 2.0*t22*q4-2.0*t25*q3+t30+t33+t34-t35-t36+t37+t38+t39+t40+t41;      t43 = 1/t42;      t45 = k2*y;      t47 = k2*tr2;      t51 = k4*z;      t53 = k1*x;      t55 = k4*x;      t56 = q2*q4;      t59 = q1*q3;      t62 = k4*y;      t63 = q1*q2;      t66 = q3*q4;      t71 = k4*tr3;      t78 = -t45*t7+t47*t3+t47*t5+t47*t7+t51*t1-t53*t5+2.0*t55*t56-2.0*t55*t59+2.0*t62*t63+2.0*t62*t66-t51*t5+t51*t7+t71*t1+t71*t5+t71*t3+t71*t7-t51*t3+t53*t1;      t81 = k1*tr1;      t90 = k1*z;      t93 = k1*y;      t94 = q2*q3;      t97 = q1*q4;      t100 = k2*x;      t105 = k2*z;      t112 = t53*t3-t53*t7+t81*t1+t81*t3+t81*t5+t47*t1+t81*t7+t45*t1-t45*t3+t45*t5+2.0*t90*t56+2.0*t93*t94-2.0*t93*t97+2.0*t100*t97+2.0*t100*t94+2.0*t105*t66-2.0*t105*t63+2.0*t90*t59;      t114 = t42*t42;      t116 = (t78+t112)/t114;      t117 = t56-t59;      t120 = k2*t1;      t121 = k2*t3;      t122 = k2*t5;      t123 = k2*t7;      t124 = k1*q2;      t127 = k1*q1;      t137 = t63+t66;      t140 = k4*t5;      t141 = k4*t7;      t142 = k4*t1;      t152 = k4*t3;      t155 = t1-t3-t5+t7;      t158 = t97+t94;      t160 = t1+t3+t5+t7;      t161 = 1/t160;      t168 = 2.0*t117*t161*x+2.0*t137*t161*y+t155*t161*z+tr3;      t169 = 1/t168;      t170 = t161*t169;      t174 = t1-t3+t5-t7;      t177 = t66-t63;      t180 = 2.0*t158*t161*x+t174*t161*y+2.0*t177*t161*z+tr2;      t181 = k3*t180;      t182 = t168*t168;      t183 = 1/t182;      t212 = t71*q1+t53*q1+t81*q1+t45*q1+t47*q1+t51*q1-t93*q4+t100*q4-t105*q2+t90*q3-t55*q3+t62*q2;      t214 = x*q3;      t215 = y*q2;      t216 = z*q1;      t233 = t71*q2+t53*q2+t81*q2-t45*q2+t47*q2+t90*q4+t93*q3+t100*q3-t105*q1+t55*q4+t62*q1-t51*q2;      t235 = x*q4;      t236 = z*q2;      t253 = -t51*q3+t71*q3-t53*q3+t81*q3+t45*q3+t47*q3+t93*q2+t100*q2+t105*q4+t90*q1-t55*q1+t62*q4;      t255 = y*q4;      t256 = z*q3;      t273 = t51*q4+t71*q4-t53*q4+t81*q4-t45*q4+t47*q4+t90*q2-t93*q1+t100*q1+t105*q3+t55*q2+t62*q3;      t275 = z*q4;      t282 = 2.0*t117*x+t34-t35+t30+t33+t38+t39-t36+t37+t40+t41;      t283 = 1/t282;      t320 = 2.0*t158*x+y*t1-y*t3+y*t5-y*t7+tr2*t1+tr2*t3+tr2*t5+tr2*t7+2.0*t256*q4-2.0*t216*q2;      t322 = q4*t161;      t323 = t322*x;      t324 = t160*t160;      t325 = 1/t324;      t326 = 2.0*t158*t325;      t328 = q1*t161;      t329 = t328*y;      t330 = t174*t325;      t332 = q2*t161;      t333 = t332*z;      t334 = 2.0*t177*t325;      t339 = q3*t161;      t340 = t339*x;      t341 = 2.0*t117*t325;      t343 = t332*y;      t344 = 2.0*t137*t325;      t346 = t328*z;      t347 = t155*t325;      t366 = t332*x;      t368 = t339*y;      t370 = t322*z;      t375 = t328*x;      t377 = t322*y;      t379 = t339*z;      Bij[0] = (t2+t4-t6-t8+2.0*t9*q4+2.0*k2*q2*q3+2.0*k4*q2*q4-2.0*t18*q3)*t43-2.0*t116*t117;      Bij[1] = (t120-t121+t122-t123+2.0*t124*q3-2.0*t127*q4+2.0*t18*q2+2.0*k4*q3*q4)*t43-2.0*t116*t137;      Bij[2] = (-t140+t141+t142+2.0*t124*q4+2.0*k2*q3*q4-2.0*t9*q2+2.0*t127*q3-t152)*t43-t116*t155;      Bij[3] = 2.0*k3*t158*t170-2.0*t181*t183*t117*t161;      Bij[4] = k3*t174*t170-2.0*t181*t183*t137*t161;      Bij[5] = 2.0*k3*t177*t170-t181*t183*t155*t161;      Aij[0] = 2.0*t212*t43-2.0*t116*(-t214+t215+t216+tr3*q1);      Aij[1] = 2.0*t233*t43-2.0*t116*(t235+t28-t236+tr3*q2);      Aij[2] = 2.0*t253*t43-2.0*t116*(-t25+t255-t256+tr3*q3);      Aij[3] = 2.0*t273*t43-2.0*t116*(t22+t31+t275+tr3*q4);      Aij[4] = (t2+t4+t6+t8)*t283;      Aij[5] = (t120+t121+t122+t123)*t283;      Aij[6] = (t142+t140+t152+t141)*t43-t116*t160;      Aij[7] = ((t1+t3-t5-t7)*x+tr1*t1+tr1*t3+tr1*t5+tr1*t7+2.0*t236*q4+2.0*t215*q3-2.0*t28*q4+2.0*t216*q3)*t283;      Aij[8] = t320*t283;      Aij[9] = 0.0;      Aij[10] = 1.0;      Aij[11] = 0.0;      Aij[12] = 2.0*k3*(t323-t326*t25+t329-t330*t28-t333-t334*t216)*t169-2.0*t181*t183*(-t340-t341*t25+t343-t344*t28+t346-t347*t216);      Aij[13] = 2.0*k3*(t340-t326*t22-t343-t330*t215-t346-t334*t236)*t169-2.0*t181*t183*(t323-t341*t22+t329-t344*t215-t333-t347*t236);      Aij[14] = 2.0*k3*(t366-t326*t214+t368-t330*t31+t370-t334*t256)*t169-2.0*t181*t183*(-t375-t341*t214+t377-t344*t31-t379-t347*t256);      Aij[15] = 2.0*k3*(t375-t326*t235-t377-t330*t255+t379-t334*t275)*t169-2.0*t181*t183*(t366-t341*t235+t368-t344*t255+t370-t347*t275);      Aij[16] = 0.0;      Aij[17] = k3*t169;      Aij[18] = -t181*t183;      Aij[19] = 0.0;      Aij[20] = 0.0;      Aij[21] = t180*t169;      Aij[22] = 0.0;      Aij[23] = 1.0;
}

API_MOD void CALL_CONV projectivek1k2k3k4k5kap1kap2p1p2Ignored(double *rt, double *xyz, double *xij, double **adata) { 
double x, y, z, q1, q2, q3, q4, tr1, tr2, tr3;

double t1, t2, t3, t4, t17, t20, t41, t42, t61;

x = xyz[0];
y = xyz[1];
z = xyz[2];
q1 = rt[0];
q2 = rt[1];
q3 = rt[2];
q4 = rt[3];
tr1 = rt[4];
tr2 = rt[5];
tr3 = rt[6];

      t1 = q1*q1;      t2 = q2*q2;      t3 = q3*q3;      t4 = q4*q4;      t17 = y*q1;      t20 = z*q1;      t41 = 2.0*(q2*q4-q1*q3)*x+z*t1-z*t2+2.0*t17*q2+2.0*y*q3*q4+tr3*t1+tr3*t2-z*t3+z*t4+tr3*t3+tr3*t4;      t42 = 1/t41;      t61 = 2.0*(q1*q4+q2*q3)*x+y*t1-y*t2+y*t3-y*t4+tr2*t1+tr2*t2+tr2*t3+tr2*t4+2.0*z*q3*q4-2.0*t20*q2;      xij[0] = ((t1+t2-t3-t4)*x+tr1*t1+tr1*t2+tr1*t3+tr1*t4+2.0*z*q2*q4+2.0*y*q2*q3-2.0*t17*q4+2.0*t20*q3)*t42;      xij[1] = t61*t42;
}

API_MOD void CALL_CONV projectivek1k2k3k4k5kap1kap2p1p2IgnoredJac(double *rt, double *xyz, double *Aij, double *Bij, double **adata) { 
double x, y, z, q1, q2, q3, q4, tr1, tr2, tr3;

double t1, t2, t3, t4, t5, t6, t9, t12, t14, t15, t17, t18, t19, t20, t21, t22, t23, t24, t25, t26, t27, t33, t35, t37, t38, t40, t41, t43, t44, t45, t46, t47, t48, t49, t50, t51, t52, t53, t54, t57, t58, t61, t62, t63, t68, t71, t77, t78, t79, t80, t81, t83, t85, t86, t87, t88, t89, t90, t91, t102, t106, t108, t111, t115, t117, t124, t131, t134, t136, t138, t141, t142, t166;

x = xyz[0];
y = xyz[1];
z = xyz[2];
q1 = rt[0];
q2 = rt[1];
q3 = rt[2];
q4 = rt[3];
tr1 = rt[4];
tr2 = rt[5];
tr3 = rt[6];

      t1 = q1*q1;      t2 = q2*q2;      t3 = q3*q3;      t4 = q4*q4;      t5 = t1+t2-t3-t4;      t6 = x*q2;      t9 = x*q1;      t12 = y*q1;      t14 = 2.0*t12*q2;      t15 = y*q3;      t17 = 2.0*t15*q4;      t18 = z*t1;      t19 = z*t2;      t20 = z*t3;      t21 = z*t4;      t22 = tr3*t1;      t23 = tr3*t2;      t24 = tr3*t3;      t25 = tr3*t4;      t26 = 2.0*t6*q4-2.0*t9*q3+t14+t17+t18-t19-t20+t21+t22+t23+t24+t25;      t27 = 1/t26;      t33 = y*q2;      t35 = 2.0*t33*q3;      t37 = 2.0*t12*q4;      t38 = z*q1;      t40 = 2.0*t38*q3;      t41 = z*q2;      t43 = 2.0*t41*q4;      t44 = tr1*t1;      t45 = tr1*t2;      t46 = tr1*t3;      t47 = tr1*t4;      t48 = x*t1+x*t2-x*t3-x*t4+t35-t37+t40+t43+t44+t45+t46+t47;      t49 = t26*t26;      t50 = 1/t49;      t51 = t48*t50;      t52 = q2*q4;      t53 = q1*q3;      t54 = t52-t53;      t57 = q2*q3;      t58 = q1*q4;      t61 = q1*q2;      t62 = q3*q4;      t63 = t61+t62;      t68 = t1-t2-t3+t4;      t71 = t58+t57;      t77 = y*t1;      t78 = y*t2;      t79 = y*t3;      t80 = y*t4;      t81 = z*q3;      t83 = 2.0*t81*q4;      t85 = 2.0*t38*q2;      t86 = tr2*t1;      t87 = tr2*t2;      t88 = tr2*t3;      t89 = tr2*t4;      t90 = 2.0*t9*q4+2.0*t6*q3+t77-t78+t79-t80+t83-t85+t86+t87+t88+t89;      t91 = t90*t50;      t102 = y*q4;      t106 = x*q3;      t108 = -t106+t33+t38+tr3*q1;      t111 = z*q4;      t115 = x*q4;      t117 = t115+t12-t41+tr3*q2;      t124 = -t9+t102-t81+tr3*q3;      t131 = t6+t15+t111+tr3*q4;      t134 = t1+t2+t3+t4;      t136 = 2.0*t54*x+t18-t19+t14+t17+t22+t23-t20+t21+t24+t25;      t138 = t134/t136;      t141 = t136*t136;      t142 = 1/t141;      t166 = 2.0*t71*x+t77-t78+t79-t80+t86+t87+t88+t89+t83-t85;      Bij[0] = t5*t27-2.0*t51*t54;      Bij[1] = 2.0*(t57-t58)*t27-2.0*t51*t63;      Bij[2] = 2.0*(t53+t52)*t27-t51*t68;      Bij[3] = 2.0*t71*t27-2.0*t91*t54;      Bij[4] = (t1-t2+t3-t4)*t27-2.0*t91*t63;      Bij[5] = 2.0*(t62-t61)*t27-t91*t68;      Aij[0] = 2.0*(t9-t102+t81+tr1*q1)*t27-2.0*t51*t108;      Aij[1] = 2.0*(t6+t15+t111+tr1*q2)*t27-2.0*t51*t117;      Aij[2] = 2.0*(-t106+t33+t38+tr1*q3)*t27-2.0*t51*t124;      Aij[3] = 2.0*(-t115-t12+t41+tr1*q4)*t27-2.0*t51*t131;      Aij[4] = t138;      Aij[5] = 0.0;      Aij[6] = -(t5*x+t44+t45+t46+t47+t43+t35-t37+t40)*t142*t134;      Aij[7] = 2.0*(t115+t12-t41+tr2*q1)*t27-2.0*t91*t108;      Aij[8] = 2.0*(t106-t33-t38+tr2*q2)*t27-2.0*t91*t117;      Aij[9] = 2.0*(t6+t15+t111+tr2*q3)*t27-2.0*t91*t124;      Aij[10] = 2.0*(t9-t102+t81+tr2*q4)*t27-2.0*t91*t131;      Aij[11] = 0.0;      Aij[12] = t138;      Aij[13] = -t166*t142*t134;
}

API_MOD void CALL_CONV affineNRSFM(double *rt, double *xyz, double *xij, double **adata) {
double x, y, z, q1, q2, q3, q4, tr1, tr2;

double t1, t2, t3, t4, t7, t16;
int isFirstCoeff1 = *(adata[0]);
int nBasis = *(adata[1]);
double tmp;
int k;
double xyzTot[3];

if (isFirstCoeff1) {
  xyzTot[0] = xyz[0];
  xyzTot[1] = xyz[1];
  xyzTot[2] = xyz[2];
} else {
  xyzTot[0] = rt[6]*xyz[0];
  xyzTot[1] = rt[6]*xyz[1];
  xyzTot[2] = rt[6]*xyz[2];
}

for( k = 1; k<nBasis; ++k ) {
  if (isFirstCoeff1)
    tmp = rt[6+k-1];
  else
    tmp = rt[6+k];

  xyzTot[0] += tmp*xyz[3*k];
  xyzTot[1] += tmp*xyz[3*k+1];
  xyzTot[2] += tmp*xyz[3*k+2];
}
affinek1k2k3kap1kap2p1p2Ignored( rt, xyzTot, xij, adata);
}

API_MOD void CALL_CONV affineNRSFMJac(double *rt, double *xyz, double *Aij, double *Bij, double **adata) {
double x, y, z, q1, q2, q3, q4, tr1, tr2;

double t1, t2, t3, t4, t5, t6, t7, t9, t10, t16, t17, t25, t26, t27, t28, t32, t33, t37, t40, t43, t46, t54, t58, t62, t63, t70, t80, t90, t110;
int isFirstCoeff1 = *(adata[0]);
int nBasis = *(adata[1]);
int nL;
double l;
int k, kk, m;
double xx = 0, yy = 0, zz = 0;
double BijClean[6];

if (isFirstCoeff1)
  nL=nBasis-1;
else
  nL=nBasis;

q1 = rt[0];
q2 = rt[1];
q3 = rt[2];
q4 = rt[3];
tr1 = rt[4];
tr2 = rt[5];

// Precompute some stuff
t1 = q1*q1;      t2 = q2*q2;      t3 = q3*q3;      t4 = q4*q4;      t5 = t1+t2-t3-t4;      t6 = t1+t2+t3+t4;      t7 = 1/t6;      t9 = q2*q3;      t10 = q1*q4;      t17 = t10+t9;      t25 = q1*t7;      t26 = t6*t6;      t27 = 1/t26;      t28 = t5*t27;      t58 = q2*t7;      t70 = q3*t7;      t80 = q4*t7;      t90 = 2.0*t17*t27;      

BijClean[0] = t5*t7;      BijClean[1] = 2.0*(t9-t10)*t7;      BijClean[2] = 2.0*(q1*q3+q2*q4)*t7;      BijClean[3] = 2.0*t17*t7;      BijClean[4] = (t1-t2+t3-t4)*t7;      BijClean[5] = 2.0*(q3*q4-q1*q2)*t7;

// Derivative with respect to the point 3nBasis coordinates
for( k = 0; k<nBasis; ++k ) {
  if (isFirstCoeff1) {
    kk = 6+k-1;
    if (k==0)
      l = 1;
    else
      l = rt[kk];
  } else {
    kk = 6+k;
    l = rt[kk];
  }

  for( m=0; m<3; ++m ) {
    Bij[m+3*k] = l*BijClean[m];
    Bij[m+3*k+3*nBasis] = l*BijClean[3+m];
  }
     
  x = xyz[3*k];
  y = xyz[3*k+1];
  z = xyz[3*k+2];
  
  // Compute the resulting 3D point
  xx += l*x;
  yy += l*y;
  zz += l*z;
    
  // Derivative with respect to the shape coefficients
  if (!((isFirstCoeff1) && (k==0))) {
    t16 = z*q1;
    Aij[kk] = (t1+t2-t3-t4)*t7*x+(2.0*y*q2*q3-2.0*y*q1*q4+2.0*t16*q3+2.0*z*q2*q4+tr1*t1+tr1*t2+tr1*t3+tr1*t4)*t7;
    Aij[kk+(6+nL)] = 2.0*(q1*q4+q2*q3)*t7*x+(y*t1-y*t2+y*t3-y*t4+2.0*z*q3*q4-2.0*t16*q2+tr2*t1+tr2*t2+tr2*t3+tr2*t4)*t7;
  }
}

x=xx;
y=yy;
z=zz;

// Derivative with respect to the camera parameters
t32 = y*q4;      t33 = z*q3;      t37 = y*q2;      t40 = y*q1;      t43 = z*q1;      t46 = z*q2;      t54 = (2.0*t37*q3-2.0*t40*q4+2.0*t43*q3+2.0*t46*q4+tr1*t1+tr1*t2+tr1*t3+tr1*t4)*t27; t62 = y*q3;      t63 = z*q4; t110 = (y*t1-y*t2+y*t3-y*t4+2.0*t33*q4-2.0*t43*q2+tr2*t1+tr2*t2+tr2*t3+tr2*t4)*t27;      Aij[0] = 2.0*(t25-t28*q1)*x+2.0*(-t32+t33+tr1*q1)*t7-2.0*t54*q1;      Aij[1] = 2.0*(t58-t28*q2)*x+2.0*(t62+t63+tr1*q2)*t7-2.0*t54*q2;      Aij[2] = 2.0*(-t70-t28*q3)*x+2.0*(t37+t43+tr1*q3)*t7-2.0*t54*q3;      Aij[3] = 2.0*(-t80-t28*q4)*x+2.0*(-t40+t46+tr1*q4)*t7-2.0*t54*q4;      Aij[4] = 1.0;      Aij[5] = 0.0;      Aij[0+(6+nL)] = 2.0*(t80-t90*q1)*x+2.0*(t40-t46+tr2*q1)*t7-2.0*t110*q1;      Aij[1+(6+nL)] = 2.0*(t70-t90*q2)*x+2.0*(-t37-t43+tr2*q2)*t7-2.0*t110*q2;      Aij[2+(6+nL)] = 2.0*(t58-t90*q3)*x+2.0*(t62+t63+tr2*q3)*t7-2.0*t110*q3;      Aij[3+(6+nL)] = 2.0*(t25-t90*q4)*x+2.0*(-t32+t33+tr2*q4)*t7-2.0*t110*q4;      Aij[4+(6+nL)] = 0.0;      Aij[5+(6+nL)] = 1.0;
}
