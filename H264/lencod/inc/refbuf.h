
/*!
 ************************************************************************
 * \file refbuf.h
 *
 * \brief
 *    Declarations of the reference frame buffer types and functions
 ************************************************************************
 */
#ifndef _REBUF_H_
#define _REBUF_H_


#include "global.h"


pel_t UMVPelY_14 (pel_t **Pic, int y, int x);
pel_t FastPelY_14 (pel_t **Pic, int y, int x);

pel_t UMVPelY_11 (pel_t *Pic, int y, int x);
pel_t FastPelY_11 (pel_t *Pic, int y, int x);
pel_t *FastLine16Y_11 (pel_t *Pic, int y, int x);
pel_t *UMVLine16Y_11 (pel_t *Pic, int y, int x);

void PutPel_14 (pel_t **Pic, int y, int x, pel_t val);
void PutPel_11 (pel_t *Pic, int y, int x, pel_t val);

#endif
