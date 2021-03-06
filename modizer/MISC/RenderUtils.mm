/*
 *  RenderUtils.mm
 *  modizer
 *
 *  Created by Yohann Magnien on 23/08/10.
 *  Copyright 2010 __YoyoFR / Yohann Magnien__. All rights reserved.
 *
 */
#define MIDIFX_OFS 10

#include "RenderUtils.h"


#define MAX_VISIBLE_CHAN 32

namespace
{
    
    struct LineVertex
    {	
        LineVertex() {}
        LineVertex(uint16_t _x, uint16_t _y, uint8_t _r, uint8_t _g, uint8_t _b, uint8_t _a)
		: x(_x), y(_y), r(_r), g(_g), b(_b), a(_a)
        {}
        uint16_t x, y;
        uint8_t r, g, b, a;
    };
	
    struct vertexData {
		GLfloat x;             // OpenGL X Coordinate
		GLfloat y;             // OpenGL Y Coordinate
		GLfloat z;             // OpenGL Z Coordinate
		GLfloat s;             // Texture S Coordinate
		GLfloat t;             // Texture T Coordinate
		GLfloat r,g,b,a;
    };
    
    
}


void RenderUtils::SetUpOrtho(float rotation,uint width,uint height)
{
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glRotatef(rotation, 0, 0, 1);
	glOrthof(0, width, 0, height, 0, 200);
	
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

}

void RenderUtils::DrawOscillo(short int *snd_data,int numval,uint ww,uint hh,uint bg,uint type_oscillo,uint pos,int deviceType) {
	LineVertex *pts,*ptsB;
	int mulfactor;
	int dval,valL,valR,ovalL,ovalR,ospl,ospr,spl,spr,colR1,colL1,colR2,colL2,ypos;
	int count;
	
	if (numval>=128) {
		
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		
		
		
		
		pts=(LineVertex*)malloc(sizeof(LineVertex)*128*6);
		ptsB=(LineVertex*)malloc(sizeof(LineVertex)*4);
		count=0;
		
		
		
		glEnableClientState(GL_VERTEX_ARRAY);
		glEnableClientState(GL_COLOR_ARRAY);
        
		if (type_oscillo==1) {
			int wd=(ww/2-10)/64;
			if (pos) {
				ypos=hh/4;
				mulfactor=hh*1/4;
			} else {
				ypos=hh/2;
				mulfactor=hh*1/4;
			}
			
			if (bg) {
				if (pos) ypos=40;
				else ypos=hh/2;
				ptsB[0] = LineVertex((ww/2+(64*wd))/2, ypos-32,		0,0,16,192);
				ptsB[1] = LineVertex((ww/2-(64*wd))/2, ypos-32,		0,0,16,192);
				ptsB[2] = LineVertex((ww/2+(64*wd))/2, ypos+32,		0,0,16,192);
				ptsB[3] = LineVertex((ww/2-(64*wd))/2, ypos+32,		0,0,16,192);
				glVertexPointer(2, GL_SHORT, sizeof(LineVertex), &ptsB[0].x);
				glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(LineVertex), &ptsB[0].r);
				/* Render The Quad */
				glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
				
				ptsB[0] = LineVertex(ww/2+(ww/2+(64*wd))/2, ypos-32,		0,0,16,192);
				ptsB[1] = LineVertex(ww/2+(ww/2-(64*wd))/2, ypos-32,		0,0,16,192);
				ptsB[2] = LineVertex(ww/2+(ww/2+(64*wd))/2, ypos+32,		0,0,16,192);
				ptsB[3] = LineVertex(ww/2+(ww/2-(64*wd))/2, ypos+32,		0,0,16,192);
				glVertexPointer(2, GL_SHORT, sizeof(LineVertex), &ptsB[0].x);
				glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(LineVertex), &ptsB[0].r);
				/* Render The Quad */
				glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
			}
			valL=snd_data[0]*mulfactor>>6;
			valR=snd_data[1]*mulfactor>>6;
			spl=(valL)>>(15-5); if(spl>mulfactor) spl=mulfactor; if (spl<-mulfactor) spl=-mulfactor;
			spr=(valR)>>(15-5); if(spr>mulfactor) spr=mulfactor; if (spr<-mulfactor) spr=-mulfactor;
			colR1=150;
			colL1=150;
			colR2=75;
			colL2=75;
			
			for (int i=1; i<64; i++) {
				ovalL=valL;ovalR=valR;
				valL=snd_data[(i*numval>>6)*2]*mulfactor>>6;
				valR=snd_data[(i*numval>>6)*2+1]*mulfactor>>6;
				ospl=spl;ospr=spr;
				spl=(valL)>>(15-5); if(spl>mulfactor) spl=mulfactor; if (spl<-mulfactor) spl=-mulfactor;
				spr=(valR)>>(15-5); if(spr>mulfactor) spr=mulfactor; if (spr<-mulfactor) spr=-mulfactor;
				pts[count++] = LineVertex((ww/2-(64*wd))/2+i*wd-wd, ypos+ospl,colL2,colL1,colL2,205);
				colL1=(((valL-ovalL)*1024)>>15)+180;
				colL2=(((valL-ovalL)*128)>>15)+32;
				if (colL1<32) colL1=32;if (colL1>255) colL1=255;
				if (colL2<32) colL2=32;if (colL2>255) colL2=255;
				pts[count++] = LineVertex((ww/2-(64*wd))/2+i*wd, ypos+spl,colL2,colL1,colL2,205);			
				
				pts[count++] = LineVertex(ww/2+(ww/2-(64*wd))/2+i*wd-wd, ypos+ospr,colR2,colR1,colR2,205);
				colR1=(((valR-ovalR)*1024)>>15)+180;
				colR2=(((valR-ovalR)*128)>>15)+32;
				if (colR1<32) colR1=32;if (colR1>255) colR1=255;
				if (colR2<32) colR2=32;if (colR2>255) colR2=255;
				pts[count++] = LineVertex(ww/2+(ww/2-(64*wd))/2+i*wd, ypos+spr,colR2,colR1,colR2,205);
			}
			glLineWidth(2.0f);
			glVertexPointer(2, GL_SHORT, sizeof(LineVertex), &pts[0].x);
			glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(LineVertex), &pts[0].r);			
			glDrawArrays(GL_LINES, 0, count);
			
		}
		if (type_oscillo==2) {
			int wd=(ww-10)/128;
			
			valL=snd_data[0]*mulfactor>>6;
			valR=snd_data[1]*mulfactor>>6;
			spl=(valL)>>(15-5); if(spl>mulfactor) spl=mulfactor; if (spl<-mulfactor) spl=-mulfactor;
			spr=(valR)>>(15-5); if(spr>mulfactor) spr=mulfactor; if (spr<-mulfactor) spr=-mulfactor;
			colR1=150;
			colL1=150;
			colR2=75;
			colL2=75;
			
			if (pos) {
				ypos=hh/4;
				mulfactor=hh*1/4;
			} else {
				ypos=hh/2;
				mulfactor=hh*1/4;
			}
			
			if (bg) {
				if (pos) ypos=40;
				else ypos=hh/2;
				ptsB[0] = LineVertex((ww+128*wd)/2, ypos-32,		0,0,16,192);
				ptsB[1] = LineVertex((ww-128*wd)/2, ypos-32,		0,0,16,192);
				ptsB[2] = LineVertex((ww+128*wd)/2, ypos+32,		0,0,16,192);
				ptsB[3] = LineVertex((ww-128*wd)/2, ypos+32,		0,0,16,192);
				glVertexPointer(2, GL_SHORT, sizeof(LineVertex), &ptsB[0].x);
				glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(LineVertex), &ptsB[0].r);
				/* Render The Quad */
				glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
			} 
			for (int i=1; i<128; i++) {
				valL=snd_data[((i*numval)>>7)*2]*mulfactor>>6;
				valR=snd_data[((i*numval)>>7)*2+1]*mulfactor>>6;
				spl=(valL)>>(15-5); if(spl>mulfactor) spl=mulfactor; if (spl<-mulfactor) spl=-mulfactor;
				spr=(valR)>>(15-5); if(spr>mulfactor) spr=mulfactor; if (spr<-mulfactor) spr=-mulfactor;
				dval=valL-valR; if (dval<0) dval=-dval;
				colL1=((dval*512)>>15)+164;
				colL2=((dval*256)>>15)+48;
				if (colL1<48) colL1=48;if (colL1>255) colL1=255;
				if (colL2<48) colL2=48;if (colL2>255) colL2=255;
                
				pts[count++] = LineVertex((ww-128*wd)/2+i*wd, ypos+spl,colL2,colL1,colL2,192);
				pts[count++] = LineVertex((ww-128*wd)/2+i*wd, ypos+spr,colL2,colL1,colL2,192);
                
			}
			glLineWidth(1.0f);
			glVertexPointer(2, GL_SHORT, sizeof(LineVertex), &pts[0].x);
			glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(LineVertex), &pts[0].r);			
			glDrawArrays(GL_LINES, 0, count);
			
			
			count=0;
			valL=snd_data[0]*mulfactor>>6;
			valR=snd_data[1]*mulfactor>>6;
			spl=(valL)>>(15-5); if(spl>mulfactor) spl=mulfactor; if (spl<-mulfactor) spl=-mulfactor;
			spr=(valR)>>(15-5); if(spr>mulfactor) spr=mulfactor; if (spr<-mulfactor) spr=-mulfactor;
			colR1=150;
			colL1=150;
			colR2=75;
			colL2=75;
			for (int i=1; i<128; i++) {
				ovalL=valL;ovalR=valR;
				valL=snd_data[((i*numval)>>7)*2]*mulfactor>>6;
				valR=snd_data[((i*numval)>>7)*2+1]*mulfactor>>6;
				ospl=spl;ospr=spr;
				spl=(valL)>>(15-5); if(spl>mulfactor) spl=mulfactor; if (spl<-mulfactor) spl=-mulfactor;
				spr=(valR)>>(15-5); if(spr>mulfactor) spr=mulfactor; if (spr<-mulfactor) spr=-mulfactor;
				pts[count++] = LineVertex((ww-128*wd)/2+i*wd-wd, ypos+ospl,colL2,colL1,colL2,205);
				colL1=(((ovalL-valL)*1024)>>15)+164;
				colL2=(((ovalL-valL)*256)>>15)+64;
				if (colL1<48) colL1=48;if (colL1>255) colL1=255;
				if (colL2<48) colL2=48;if (colL2>255) colL2=255;
				pts[count++] = LineVertex((ww-128*wd)/2+i*wd, ypos+spl,colL2,colL1,colL2,205);			
                
				pts[count++] = LineVertex((ww-128*wd)/2+i*wd-wd, ypos+ospr,colR2,colR1,colR2,205);
				colR1=(((ovalR-valR)*1024)>>15)+164;
				colR2=(((ovalR-valR)*256)>>15)+64;
				if (colR1<48) colR1=48;if (colR1>255) colR1=255;
				if (colR2<48) colR2=48;if (colR2>255) colR2=255;
				pts[count++] = LineVertex((ww-128*wd)/2+i*wd, ypos+spr,colR2,colR1,colR2,205);
			}
			glLineWidth(2.0f);
			glVertexPointer(2, GL_SHORT, sizeof(LineVertex), &pts[0].x);
			glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(LineVertex), &pts[0].r);			
			glDrawArrays(GL_LINES, 0, count);
			
		}
		
		
		
		glDisableClientState(GL_VERTEX_ARRAY);
		glDisableClientState(GL_COLOR_ARRAY);
		glDisable(GL_BLEND);
		free(pts);
		free(ptsB);
	}
	
}

static int DrawSpectrum_first_call=1;
static int spectrumPeakValueL[SPECTRUM_BANDS];
static int spectrumPeakValueR[SPECTRUM_BANDS];
static int spectrumPeakValueL_index[SPECTRUM_BANDS];
static int spectrumPeakValueR_index[SPECTRUM_BANDS];


void RenderUtils::DrawSpectrum(short int *spectrumDataL,short int *spectrumDataR,uint ww,uint hh,uint bg,uint peaks,uint _pos,int deviceType,int nb_spectrum_bands) {
	LineVertex *pts,*ptsB,*ptsC;
	float x,y;
    int spl,spr,mulfactor,cr,cg,cb;
    int pr,pl;
	int count,band_width,ypos,maxsp,xshift;
	
	band_width=(ww/2-32)/nb_spectrum_bands;
	pts=(LineVertex*)malloc(sizeof(LineVertex)*nb_spectrum_bands*2*2*2);
	ptsB=(LineVertex*)malloc(sizeof(LineVertex)*4);
	if (peaks) ptsC=(LineVertex*)malloc(sizeof(LineVertex)*nb_spectrum_bands*2*2*2);
	
	if (DrawSpectrum_first_call) {
		DrawSpectrum_first_call=0;
		for (int i=0;i<nb_spectrum_bands;i++) {
			spectrumPeakValueL[i]=0;
			spectrumPeakValueL_index[i]=0;
			spectrumPeakValueR[i]=0;
			spectrumPeakValueR_index[i]=0;
		}
	}
	
	
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	
	if (_pos) {
		ypos=hh-hh/3;
		mulfactor=hh/4;
		maxsp=hh/4;
	} else {
		ypos=hh/2-hh/2/2;
		mulfactor=hh/2;
		maxsp=hh/2;
	}
	
	xshift=maxsp/10;
	
	if (bg) {
		
		
		ptsB[0] = LineVertex(xshift+(ww/2+(nb_spectrum_bands*band_width))/2,  ypos-maxsp/2,		0,0,16,192);
		ptsB[1] = LineVertex(xshift+(ww/2-(nb_spectrum_bands*band_width))/2-maxsp/4,  ypos-maxsp/2,		0,0,16,192);
		ptsB[2] = LineVertex(xshift+(ww/2+(nb_spectrum_bands*band_width))/2,  ypos+maxsp,		0,0,16,192);
		ptsB[3] = LineVertex(xshift+(ww/2-(nb_spectrum_bands*band_width))/2-maxsp/4, ypos+maxsp,		0,0,16,192);
		glVertexPointer(2, GL_SHORT, sizeof(LineVertex), &ptsB[0].x);
		glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(LineVertex), &ptsB[0].r);
		/* Render The Quad */
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        
		ptsB[0] = LineVertex(xshift+ww/2+(ww/2+(nb_spectrum_bands*band_width))/2,  ypos-maxsp/2,		0,0,16,192);
		ptsB[1] = LineVertex(xshift+ww/2+(ww/2-(nb_spectrum_bands*band_width))/2-maxsp/4,  ypos-maxsp/2,		0,0,16,192);
		ptsB[2] = LineVertex(xshift+ww/2+(ww/2+(nb_spectrum_bands*band_width))/2,  ypos+maxsp,		0,0,16,192);
		ptsB[3] = LineVertex(xshift+ww/2+(ww/2-(nb_spectrum_bands*band_width))/2-maxsp/4, ypos+maxsp,		0,0,16,192);
		glVertexPointer(2, GL_SHORT, sizeof(LineVertex), &ptsB[0].x);
		glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(LineVertex), &ptsB[0].r);
		/* Render The Quad */
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	}
    //	NSLog(@"%d %d",hh,ypos);
	glDisable(GL_BLEND);
	count=0;
	for (int i=0; i<nb_spectrum_bands; i++)
	{
		spl=((int)spectrumDataL[i]*maxsp)>>13;
		spr=((int)spectrumDataR[i]*maxsp)>>13;
		if (spl>maxsp) spl=maxsp;
		if (spr>maxsp) spr=maxsp;
		
		
		if (spectrumPeakValueL_index[i]) {
			pl=spectrumPeakValueL[i]*sin(spectrumPeakValueL_index[i]*3.14159f/180)*sin(spectrumPeakValueL_index[i]*3.14159f/180);
			spectrumPeakValueL_index[i]-=2;
		} else pl=0;
		if (spectrumPeakValueR_index[i]) {
			pr=spectrumPeakValueR[i]*sin(spectrumPeakValueR_index[i]*3.14159f/180)*sin(spectrumPeakValueR_index[i]*3.14159f/180);
			spectrumPeakValueR_index[i]-=2;
		} else pr=0;
		
		if (pl<spl) {
			spectrumPeakValueL[i]=spl;
			pl=spl;
			spectrumPeakValueL_index[i]=90;
		}
		if (pr<spr) {
			spectrumPeakValueR[i]=spr;
			pr=spr;
			spectrumPeakValueR_index[i]=90;
		}
        if (spl>=1) {
            cg=(spl*2*256)/maxsp; if (cg<0) cg=0; if (cg>255) cg=255;
            cb=(spl*1*256)/maxsp; if (cb<0) cb=0; if (cb>255) cb=255;
            cr=(spl*3*256)/maxsp; if (cr<0) cr=0; if (cr>255) cr=255;
            cr=cr-(cg+cb)/2;if (cr<0) cr=0;
            
            x=xshift+(ww/2-(nb_spectrum_bands*band_width))/2+i*band_width+band_width/2;        
            pts[count++] = LineVertex(x, ypos,	cb/3,cg/3,cr,255);
            pts[count++] = LineVertex(x, ypos+spl,	cb,cr/3,cg,255);
            
            if (spl>=2) {
                pts[count++] = LineVertex(x, ypos,	cb/3/3,cg/3/3,cr/3,255);
                x=x-(int)(spl/4);y=ypos-(int)(spl/2);
                if (x<0) {y-=x*2;x=0;}
                pts[count++] = LineVertex(x, y,	cb/3,cr/3/3,cg/3,255);
            }
        }
		
        if (spr>=1) {
            cg=(spr*2*256)/maxsp; if (cg<0) cg=0; if (cg>255) cg=255;
            cb=(spr*1*256)/maxsp; if (cb<0) cb=0; if (cb>255) cb=255;
            cr=(spr*3*256)/maxsp; if (cr<0) cr=0; if (cr>255) cr=255;
            cr=cr-(cg+cb)/2;if (cr<0) cr=0;
            
            
            x=xshift+ww/2+(ww/2-(nb_spectrum_bands*band_width))/2+i*band_width+band_width/2;
            pts[count++] = LineVertex(x, ypos,	cg/3,cr/3,cb,255);
            pts[count++] = LineVertex(x, ypos+spr,	cg,cb,cr/3,255);
            
            if (spr>=2) {
                pts[count++] = LineVertex(x, ypos,	cg/3/3,cr/3/3,cb/3,255);
                y=ypos-(int)(spr/2);
                x=x-(int)(spr/4);
                if (x<0) {y-=x*2;x=0;}
                
                pts[count++] = LineVertex(x, y,	cg/3,cb/3,cr/3/3,255);
            }
        }
        
		if (peaks) {
			ptsC[i*8+0] = LineVertex(xshift+(ww/2-(nb_spectrum_bands*band_width))/2+i*band_width, ypos+pl,	180,100,240,255);
			ptsC[i*8+1] = LineVertex(xshift+(ww/2-(nb_spectrum_bands*band_width))/2+i*band_width+band_width, ypos+pl,	180,100,240,255);
			ptsC[i*8+2] = LineVertex(xshift+ww/2+(ww/2-(nb_spectrum_bands*band_width))/2+i*band_width, ypos+pr,	225,100,50,255);
			ptsC[i*8+3] = LineVertex(xshift+ww/2+(ww/2-(nb_spectrum_bands*band_width))/2+i*band_width+band_width, ypos+pr,	200,100,50,255);
			
			x=xshift+(ww/2-(nb_spectrum_bands*band_width))/2+i*band_width-pl/4;if (x<0) x=0;
			ptsC[i*8+4] = LineVertex(x, ypos-pl/2,	180/3,100/3,240/3,255);
			x=xshift+(ww/2-(nb_spectrum_bands*band_width))/2+i*band_width+band_width-pl/4;if (x<0) x=0;
			ptsC[i*8+5] = LineVertex(x, ypos-pl/2,	180/3,100/3,240/3,255);
			ptsC[i*8+6] = LineVertex(xshift+ww/2+(ww/2-(nb_spectrum_bands*band_width))/2+i*band_width-pr/4, ypos-pr/2,	225/3,100/3,50/3,255);
			ptsC[i*8+7] = LineVertex(xshift+ww/2+(ww/2-(nb_spectrum_bands*band_width))/2+i*band_width+band_width-pr/4, ypos-pr/2,	200/3,100/3,50/3,255);
		}
	}
	
	
	
	glLineWidth(band_width);
	glVertexPointer(2, GL_SHORT, sizeof(LineVertex), &pts[0].x);
	glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(LineVertex), &pts[0].r);
	glDrawArrays(GL_LINES, 0, count);
	
	if (peaks) {
		glLineWidth(1);
		glVertexPointer(2, GL_SHORT, sizeof(LineVertex), &ptsC[0].x);
		glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(LineVertex), &ptsC[0].r);
		glDrawArrays(GL_LINES, 0, nb_spectrum_bands*4*2);
	}
	
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	
	free(pts);
	free(ptsB);
	if (peaks) free(ptsC);
}

static int DrawBeat_first_call=1;
static int beatValueL_index[SPECTRUM_BANDS];
static int beatValueR_index[SPECTRUM_BANDS];


void RenderUtils::DrawBeat(unsigned char *beatDataL,unsigned char *beatDataR,uint ww,uint hh,uint bg,uint _pos,int deviceType,int nb_spectrum_bands) {
	LineVertex *ptsB;
	float pr,pl,cr,cg,cb;
	int band_width,ypos;
	
	band_width=(ww/2-32)/nb_spectrum_bands;
	ptsB=(LineVertex*)malloc(sizeof(LineVertex)*4);
	
	if (DrawBeat_first_call) {
		DrawBeat_first_call=0;
		for (int i=0;i<nb_spectrum_bands;i++) {
			beatValueL_index[i]=0;
			beatValueR_index[i]=0;
		}
	}
	
	
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	
	if (_pos) {
		ypos=hh-band_width-10;
		
	} else {
		ypos=hh/2;
	}
	
	/*if (bg) {
     
     
     ptsB[0] = LineVertex((ww/2+(nb_spectrum_bands*band_width))/2,  ypos-16,		0,0,16,192);
     ptsB[1] = LineVertex((ww/2-(nb_spectrum_bands*band_width))/2,  ypos-16,		0,0,16,192);
     ptsB[2] = LineVertex((ww/2+(nb_spectrum_bands*band_width))/2,  ypos+16,		0,0,16,192);
     ptsB[3] = LineVertex((ww/2-(nb_spectrum_bands*band_width))/2, ypos+16,		0,0,16,192);
     glVertexPointer(2, GL_SHORT, sizeof(LineVertex), &ptsB[0].x);
     glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(LineVertex), &ptsB[0].r);
     // Render The Quad
     glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
     
     ptsB[0] = LineVertex(ww/2+(ww/2+(nb_spectrum_bands*band_width))/2,  ypos-16,		0,0,16,192);
     ptsB[1] = LineVertex(ww/2+(ww/2-(nb_spectrum_bands*band_width))/2,  ypos-16,		0,0,16,192);
     ptsB[2] = LineVertex(ww/2+(ww/2+(nb_spectrum_bands*band_width))/2,  ypos+16,		0,0,16,192);
     ptsB[3] = LineVertex(ww/2+(ww/2-(nb_spectrum_bands*band_width))/2, ypos+16,		0,0,16,192);
     glVertexPointer(2, GL_SHORT, sizeof(LineVertex), &ptsB[0].x);
     glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(LineVertex), &ptsB[0].r);
     // Render The Quad
     glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
     }*/
	//	NSLog(@"%d %d",hh,ypos);
	glDisable(GL_BLEND);
	for (int i=0; i<nb_spectrum_bands; i++)
	{
		if (beatValueL_index[i]) {
			pl=band_width*sin(beatValueL_index[i]*3.14159/80)*0.7f+band_width*0.2f;
			if (pl>band_width/2-1) pl=band_width/2-1;
			beatValueL_index[i]-=4;
		} else pl=band_width*0.1f;
		if (beatValueR_index[i]) {
			pr=band_width*sin(beatValueR_index[i]*3.14159/80)*0.7f+band_width*0.2f;
			if (pr>band_width/2-1) pr=band_width/2-1;			
			beatValueR_index[i]-=4;
		} else pr=band_width*0.1f;
		
		if (beatDataL[i]) {
			pl=band_width/2;
			beatValueL_index[i]=40;
		}
		if (beatDataR[i]) {
			pr=band_width/2;
			beatValueR_index[i]=40;
		}
		cg=beatValueL_index[i]*2*256/40; if (cg<32) cg=32; if (cg>255) cg=255;
		cb=beatValueL_index[i]*1*256/40; if (cb<24) cb=24; if (cb>255) cb=255;
		cr=beatValueL_index[i]*3*256/40; if (cr<16) cr=16; if (cr>255) cr=255;
		cr=cr-(cg+cb)/2;if (cr<24) cr=24;
		
		ptsB[0] = LineVertex((ww/2-(nb_spectrum_bands*band_width))/2+i*band_width+band_width/2-pl, ypos+pl,cb,cg,cr/3,255);
		ptsB[1] = LineVertex((ww/2-(nb_spectrum_bands*band_width))/2+i*band_width+band_width/2+pl, ypos+pl,cb,cg,cr/3,255);
		
		ptsB[2] = LineVertex((ww/2-(nb_spectrum_bands*band_width))/2+i*band_width+band_width/2-pl, ypos-pl,cb,cg,cr/3,255);
		ptsB[3] = LineVertex((ww/2-(nb_spectrum_bands*band_width))/2+i*band_width+band_width/2+pl, ypos-pl,cb,cg,cr/3,255);
		
		glVertexPointer(2, GL_SHORT, sizeof(LineVertex), &ptsB[0].x);
		glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(LineVertex), &ptsB[0].r);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		
		cg=beatValueR_index[i]*2*256/band_width; if (cg<32) cg=32; if (cg>255) cg=255;
		cb=beatValueR_index[i]*1*256/band_width; if (cb<24) cb=24; if (cb>255) cb=255;
		cr=beatValueR_index[i]*3*256/band_width; if (cr<16) cr=16; if (cr>255) cr=255;
		cr=cr-(cg+cb)/2;if (cr<24) cr=24;
		
		ptsB[0] = LineVertex(ww/2+(ww/2-(nb_spectrum_bands*band_width))/2+i*band_width+band_width/2-pr, ypos+pr,cg,cb,cr/3,255);
		ptsB[1] = LineVertex(ww/2+(ww/2-(nb_spectrum_bands*band_width))/2+i*band_width+band_width/2+pr, ypos+pr,cg,cb,cr/3,255);
		
		ptsB[2] = LineVertex(ww/2+(ww/2-(nb_spectrum_bands*band_width))/2+i*band_width+band_width/2-pr, ypos-pr,cg,cb,cr/3,255);
		ptsB[3] = LineVertex(ww/2+(ww/2-(nb_spectrum_bands*band_width))/2+i*band_width+band_width/2+pr, ypos-pr,cg,cb,cr/3,255);
		
		glVertexPointer(2, GL_SHORT, sizeof(LineVertex), &ptsB[0].x);
		glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(LineVertex), &ptsB[0].r);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	}
	
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	
	free(ptsB);
}

void RenderUtils::DrawFXTouchGrid(uint _ww,uint _hh,int fade_level) {
	LineVertex pts[24];
	//set the opengl state
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);	
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	glVertexPointer(2, GL_SHORT, sizeof(LineVertex), &pts[0].x);
	glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(LineVertex), &pts[0].r);
    
	
	pts[0] = LineVertex(0, 0,		0,0,0,fade_level*3/4);
	pts[1] = LineVertex(_ww, 0,		0,0,0,fade_level*3/4);
	pts[2] = LineVertex(0, _hh,		0,0,0,fade_level*3/4);
	pts[3] = LineVertex(_ww, _hh,	0,0,0,fade_level*3/4);
	/* Render The Quad */
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
	
	pts[0] = LineVertex(_ww*1/4-1, 0,		255,255,255,fade_level);
	pts[1] = LineVertex(_ww*1/4-1, _hh,		55,55,155,fade_level);
	pts[2] = LineVertex(_ww*2/4-1, 0,		55,55,155,fade_level);
	pts[3] = LineVertex(_ww*2/4-1, _hh,		255,255,255,fade_level);
    pts[4] = LineVertex(_ww*3/4-1, 0,		55,55,155,fade_level);
	pts[5] = LineVertex(_ww*3/4-1, _hh,		255,255,255,fade_level);
	pts[6] = LineVertex(_ww*1/4+1, 0,		255,255,255,fade_level/4);
	pts[7] = LineVertex(_ww*1/4+1, _hh,		55,55,155,fade_level/4);
	pts[8] = LineVertex(_ww*2/4+1, 0,		55,55,155,fade_level/4);
	pts[9] = LineVertex(_ww*2/4+1, _hh,		255,255,255,fade_level/4);
	pts[10] = LineVertex(_ww*3/4+1, 0,		55,55,155,fade_level/4);
	pts[11] = LineVertex(_ww*3/4+1, _hh,		255,255,255,fade_level/4);
	
	pts[12] = LineVertex(0,	_hh*1/4-1, 	55,55,155,fade_level);
	pts[13] = LineVertex(_ww,	_hh*1/4-1, 	255,255,255,fade_level);
	pts[14] = LineVertex(0,	_hh*2/4-1, 	255,255,255,fade_level);
	pts[15] = LineVertex(_ww,	_hh*2/4-1, 	55,55,155,fade_level);
	pts[16] = LineVertex(0,	_hh*3/4-1, 	255,255,255,fade_level);
	pts[17] = LineVertex(_ww,	_hh*3/4-1, 	55,55,155,fade_level);
	pts[18] = LineVertex(0,	_hh*1/4+1, 	55,55,155,fade_level/4);
	pts[19] = LineVertex(_ww,	_hh*1/4+1, 	255,255,255,fade_level/4);
	pts[20] = LineVertex(0,	_hh*2/4+1, 	255,255,255,fade_level/4);
	pts[21] = LineVertex(_ww,	_hh*2/4+1, 	55,55,155,fade_level/4);
	pts[22] = LineVertex(0,	_hh*3/4+1, 	255,255,255,fade_level/4);
	pts[23] = LineVertex(_ww,	_hh*3/4+1, 	55,55,155,fade_level/4);
	
	glLineWidth(1.0f);
	glDrawArrays(GL_LINES, 0, 24);
    
    
	pts[0] = LineVertex(_ww*1/4, 0,		255,255,255,fade_level/2);
	pts[1] = LineVertex(_ww*1/4, _hh,		55,55,155,fade_level/2);
	pts[2] = LineVertex(_ww*2/4, 0,		55,55,155,fade_level/2);
	pts[3] = LineVertex(_ww*2/4, _hh,		255,255,255,fade_level/2);
    pts[4] = LineVertex(_ww*3/4, 0,		55,55,155,fade_level/2);
	pts[5] = LineVertex(_ww*3/4, _hh,		255,255,255,fade_level/2);
    
	pts[6] = LineVertex(0,	_hh*1/4, 	55,55,155,fade_level/2);
	pts[7] = LineVertex(_ww,	_hh*1/4, 	255,255,255,fade_level/2);
	pts[8] = LineVertex(0,	_hh*2/4, 	255,255,255,fade_level/2);
	pts[9] = LineVertex(_ww,	_hh*2/4, 	55,55,155,fade_level/2);
	pts[10] = LineVertex(0,	_hh*3/4, 	255,255,255,fade_level/2);
	pts[11] = LineVertex(_ww,	_hh*3/4, 	55,55,155,fade_level/2);
	
	
	
	
	glLineWidth(2.0f);
	glDrawArrays(GL_LINES, 0, 12);
	
	glDisable(GL_BLEND);	
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_VERTEX_ARRAY);
}

void RenderUtils::DrawChanLayout(uint _ww,uint _hh,int display_note_mode,int chanNb,int pixOfs) {
	int count=0;
	int col_size,col_ofs;
	LineVertex pts[10*MAX_VISIBLE_CHAN+10],ptsD[4*2];
	//set the opengl state
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
    
    glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glLineWidth(1.0f);
    
	
	switch (display_note_mode){
		case 0:col_size=12*6;col_ofs=25;break;
		case 1:col_size=6*6;col_ofs=27;break;
	}
	
	
    //then draw channels frame
	
	for (int i=0; i<chanNb; i++) {
		if (col_size*i+col_ofs-2.0f>_ww) break;
		pts[count++] = LineVertex(pixOfs+col_size*i+col_ofs-2.0f, (i&1?_hh:0),	140,160,255,255);
		pts[count++] = LineVertex(pixOfs+col_size*i+col_ofs-2.0f,	(i&1?0:_hh),	60,100,255,255);
		pts[count++] = LineVertex(pixOfs+col_size*i+col_ofs-1, (i&1?_hh:0),	140/3,160/3,255/3,255);
		pts[count++] = LineVertex(pixOfs+col_size*i+col_ofs-1, (i&1?0:_hh),	60/3,100/3,255/3,255);
		pts[count++] = LineVertex(pixOfs+col_size*i+col_ofs, (i&1?_hh:0),		140/3,160/3,255/3,255);
		pts[count++] = LineVertex(pixOfs+col_size*i+col_ofs, (i&1?0:_hh),		60/3,100/3,255/3,255);
		pts[count++] = LineVertex(pixOfs+col_size*i+col_ofs+1, (i&1?_hh:0),	140/3,160/3,255/3,255);
		pts[count++] = LineVertex(pixOfs+col_size*i+col_ofs+1, (i&1?0:_hh),	60/3,100/3,255/3,255);
        
		pts[count++] = LineVertex(pixOfs+col_size*i+col_ofs+2.0f, (i&1?_hh:0),	140/6,160/6,255/6,255);
		pts[count++] = LineVertex(pixOfs+col_size*i+col_ofs+2.0f, (i&1?0:_hh),	60/6,100/6,255/6,255);
	}
	pts[count++] = LineVertex(1, _hh-20+2,			140,160,255,255);
	pts[count++] = LineVertex(_ww-1, _hh-20+2,		60,100,255,255);
	pts[count++] = LineVertex(1, _hh-20+1,		140/3,160/3,255/3,255);
	pts[count++] = LineVertex(_ww-1, _hh-20+1,	60/3,100/3,255/3,255);
	pts[count++] = LineVertex(1, _hh-20,		140/3,160/3,255/3,255);
	pts[count++] = LineVertex(_ww-1, _hh-20,		60/3,100/3,255/3,255);
	pts[count++] = LineVertex(1, _hh-20-1,		140/3,160/3,255/3,255);
	pts[count++] = LineVertex(_ww-1, _hh-20-1,	60/3,100/3,255/3,255);
	pts[count++] = LineVertex(1, _hh-20-2,		140/6,160/6,255/6,255);
	pts[count++] = LineVertex(_ww-1, _hh-20-2,	60/6,100/6,255/6,255);
	
    
	glVertexPointer(2, GL_SHORT, sizeof(LineVertex), &pts[0].x);
    
	glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(LineVertex), &pts[0].r);
	
	glDrawArrays(GL_LINES, 0, count);
	
    
	//3D border effect
	ptsD[0] = LineVertex(0, 1,		80,80,80,255);
	ptsD[1] = LineVertex(_ww, 1,	140,140,140,255);
	ptsD[2] = LineVertex(0, _hh-1,	20,20,20,255);
	ptsD[3] = LineVertex(_ww, _hh-1,80,80,80,255);
	ptsD[4] = LineVertex(_ww-1, 0,	140,140,140,255);
	ptsD[5] = LineVertex(_ww-1, _hh,80,80,80,255);
	ptsD[6] = LineVertex(1, 0,		80,80,80,255);
	ptsD[7] = LineVertex(1, _hh,	20,20,20,255);
	glLineWidth(2.0f);
	glVertexPointer(2, GL_SHORT, sizeof(LineVertex), &ptsD[0].x);
	glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(LineVertex), &ptsD[0].r);
	glDrawArrays(GL_LINES, 0, 8);
	
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisable(GL_BLEND);
    
}

void RenderUtils::DrawChanLayoutAfter(uint _ww,uint _hh,int display_note_mode) {
	LineVertex ptsB[1*2],ptsC[3*2];
	int ii;
	//set the opengl state
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnable(GL_BLEND);
	
	//current playing line
	ii=(_hh-30+11)/12;
	ptsB[0] = LineVertex(0, _hh-30-12*(ii/2)+3,		230,76,153,120);
	ptsB[1] = LineVertex(_ww-1, _hh-30-12*(ii/2)+3,		230,76,153,120);
	glLineWidth(15.0f);
	glVertexPointer(2, GL_SHORT, sizeof(LineVertex), &ptsB[0].x);
	glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(LineVertex), &ptsB[0].r);
	glDrawArrays(GL_LINES, 0, 2);
	
	ptsC[0] = LineVertex(0, _hh-30-12*(ii/2)+3-8.0f,	230,76,153,50);
	ptsC[1] = LineVertex(_ww-1, _hh-30-12*(ii/2)+3-8.0f, 230,76,153,50);
	ptsC[2] = LineVertex(0, _hh-30-12*(ii/2)+3+8.0f,	230,76,153,200);
	ptsC[3] = LineVertex(_ww-1, _hh-30-12*(ii/2)+3+8.0f, 230,76,153,200);
	glLineWidth(2.0f);
	glVertexPointer(2, GL_SHORT, sizeof(LineVertex), &ptsC[0].x);
	glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(LineVertex), &ptsC[0].r);
	glDrawArrays(GL_LINES, 0, 4);
	
    glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisable(GL_BLEND);
	
}

/* Reduces A Normal Vector (3 Coordinates)       */
/* To A Unit Normal Vector With A Length Of One. */
void RenderUtils::ReduceToUnit(GLfloat vector[3]) {
    /* Holds Unit Length */
    GLfloat length;
	
    /* Calculates The Length Of The Vector */
    length=(GLfloat)sqrt((vector[0]*vector[0])+(vector[1]*vector[1])+(vector[2]*vector[2]));
	
    /* Prevents Divide By 0 Error By Providing */
    if (length==0.0f)
    {
        /* An Acceptable Value For Vectors To Close To 0. */
        length=1.0f;
    }
	
    vector[0]/=length;  /* Dividing Each Element By */
    vector[1]/=length;  /* The Length Results In A  */
    vector[2]/=length;  /* Unit Normal Vector.      */
}

/* Calculates Normal For A Quad Using 3 Points */
void RenderUtils::calcNormal(GLfloat v[3][3], GLfloat out[3]) {
    /* Vector 1 (x,y,z) & Vector 2 (x,y,z) */
    GLfloat v1[3], v2[3];
    /* Define X Coord */
    static const int x=0;
    /* Define Y Coord */
    static const int y=1;
    /* Define Z Coord */
    static const int z=2;
	
    /* Finds The Vector Between 2 Points By Subtracting */
    /* The x,y,z Coordinates From One Point To Another. */
	
    /* Calculate The Vector From Point 1 To Point 0 */
    v1[x]=v[0][x]-v[1][x];      /* Vector 1.x=Vertex[0].x-Vertex[1].x */
    v1[y]=v[0][y]-v[1][y];      /* Vector 1.y=Vertex[0].y-Vertex[1].y */
    v1[z]=v[0][z]-v[1][z];      /* Vector 1.z=Vertex[0].y-Vertex[1].z */
	
    /* Calculate The Vector From Point 2 To Point 1 */
    v2[x]=v[1][x]-v[2][x];      /* Vector 2.x=Vertex[0].x-Vertex[1].x */
    v2[y]=v[1][y]-v[2][y];      /* Vector 2.y=Vertex[0].y-Vertex[1].y */
    v2[z]=v[1][z]-v[2][z];      /* Vector 2.z=Vertex[0].z-Vertex[1].z */
	
    /* Compute The Cross Product To Give Us A Surface Normal */
    out[x]=v1[y]*v2[z]-v1[z]*v2[y];     /* Cross Product For Y - Z */
    out[y]=v1[z]*v2[x]-v1[x]*v2[z];     /* Cross Product For X - Z */
    out[z]=v1[x]*v2[y]-v1[y]*v2[x];     /* Cross Product For X - Y */
	
    ReduceToUnit(out);          /* Normalize The Vectors */
}

#define SPECTRUM_DEPTH 12
#define SPECTRUM_ZSIZE 32
#define SPECTRUM_Y 12.0f
#define SPECTR_XSIZE_FACTOR 0.95f
#define SPECTRUM_DECREASE_FACTOR 0.9f
#define SPECTRUM_DECREASE_FACTOR2 0.98f
#define SPECTR_XSIZE 38.0f
static float oldSpectrumDataL[SPECTRUM_DEPTH*4][SPECTRUM_BANDS];
static float oldSpectrumDataR[SPECTRUM_DEPTH*4][SPECTRUM_BANDS];
static GLfloat vertices[4][3];  /* Holds Float Info For 4 Sets Of Vertices */
static GLfloat normals[4][3];  /* Holds Float Info For 4 Sets Of Vertices */
static GLfloat vertColor[4][4];  /* Holds Float Info For 4 Sets Of Vertices */

float ambientLight[2][4] = {
    {0.1f, 0.1f, 0.2f, 1.0f},
    {0.2f, 0.1f, 0.1f, 1.0f}
};	// �wiat�o otoczenia
float diffuseLight[2][4] = { 
    {0.5f, 0.5f, 0.9f, 1.0f },
    {0.9f, 0.5f, 0.5f, 1.0f }
};	// �wiat�o rozproszone
float specularLight[2][4] = { 
    {1.0f, 1.0f, 1.0f, 1.0f },
    {1.0f, 1.0f, 1.0f, 1.0f }
};	// �wiat�o odbicia
float position[] = { 0, 1, 8, 1 };


void RenderUtils::DrawSpectrum3D(short int *spectrumDataL,short int *spectrumDataR,uint ww,uint hh,float angle,int mode,int deviceType,int nb_spectrum_bands) {
	GLfloat y,z,z2,spL,spR;
    GLfloat cr,cg,cb,tr,tb,tg;  
    
	//////////////////////////////
	glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
	const float aspectRatio = (float)ww/(float)hh;
	const float _hw = 0.1f;
	const float _hh = _hw/aspectRatio;	
	glFrustumf(-_hw, _hw, -_hh, _hh, 1.0f, (SPECTRUM_DEPTH-1)*SPECTRUM_ZSIZE*2+120.0f);
	
    glPushMatrix();                     /* Push The Modelview Matrix */
	
    glTranslatef(0.0, 0.0, -120.0);      /* Translate 50 Units Into The Screen */
	if ((mode==3)||(mode==6)) glRotatef(angle/30.0f, 0, 0, 1);
	if ((mode==2)||(mode==5)) glRotatef(90.0f, 0, 0, 1);
	
	
    //	glEnable(GL_BLEND);
    //	glBlendFunc(GL_ONE, GL_ONE);
	
    /* Begin Drawing Quads, setup vertex array pointer */
    glVertexPointer(3, GL_FLOAT, 0, vertices);
	glColorPointer(4, GL_FLOAT, 0, vertColor);
    /* Enable Vertex Pointer */
    glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	
	for (int i=0;i<nb_spectrum_bands;i++) {
		oldSpectrumDataL[SPECTRUM_DEPTH-1][i]=((float)spectrumDataL[i]/128.0f<24?(float)spectrumDataL[i]/128.0f:24);
		oldSpectrumDataR[SPECTRUM_DEPTH-1][i]=((float)spectrumDataR[i]/128.0f<24?(float)spectrumDataR[i]/128.0f:24);
	}
	vertColor[0][3]=vertColor[1][3]=vertColor[2][3]=vertColor[3][3]=1;
	for (int j=1;j<SPECTRUM_DEPTH;j++) {
		for (int i=0; i<nb_spectrum_bands; i++) {
			oldSpectrumDataL[j-1][i]=oldSpectrumDataL[j][i]*SPECTRUM_DECREASE_FACTOR;
			oldSpectrumDataR[j-1][i]=oldSpectrumDataR[j][i]*SPECTRUM_DECREASE_FACTOR;
			
			z=-(j-1)*(SPECTRUM_ZSIZE);
			
			if (mode<=3) z2=z-(SPECTRUM_ZSIZE+j)*0.9f;
			else z2=z*0.9f;
			
			
			if (z>0) z=0;
			if (z2>0) z2=0;
			
			y=SPECTRUM_Y;
			spL=oldSpectrumDataL[j][i];
			spR=oldSpectrumDataR[j][i];
			
			tg=spL*2/8;
			tb=spL*1/8;
			tr=spL*3/8;
			tr=tr-(tg+tb)/2;
			cr=tb/3;
			cg=tg/3;
			cb=tr;
			
			
			
			vertColor[0][0]=cr;vertColor[0][1]=cg;vertColor[0][2]=cb;
			vertices[0][0]=(GLfloat)(i-nb_spectrum_bands/2)*SPECTR_XSIZE/(GLfloat)nb_spectrum_bands;
			vertices[0][1]=y+0;   /* Set y Value Of First Vertex */
			vertices[0][2]=z+0.0f;   /* Set z Value Of First Vertex */
			vertColor[1][0]=cr;vertColor[1][1]=cg;vertColor[1][2]=cb;
			vertices[1][0]=((GLfloat)(i-nb_spectrum_bands/2)*SPECTR_XSIZE+SPECTR_XSIZE*SPECTR_XSIZE_FACTOR)/(GLfloat)nb_spectrum_bands;
			vertices[1][1]=y+0;   /* Set y Value Of Second Vertex */
			vertices[1][2]=z+0.0f;   /* Set z Value Of Second Vertex */
			
			
			spL*=0.5f;
			cr=tb;
			cg=tr/3;
			cb=tg;
			
			vertColor[2][0]=cr;vertColor[2][1]=cg;vertColor[2][2]=cb;
			vertices[2][0]=(GLfloat)(i-nb_spectrum_bands/2)*SPECTR_XSIZE/(GLfloat)nb_spectrum_bands;
			vertices[2][1]=y-spL;
			vertices[2][2]=z+0.0f;   /* Set z Value Of Second Vertex */
			vertColor[3][0]=cr;vertColor[3][1]=cg;vertColor[3][2]=cb;
			vertices[3][0]=((GLfloat)(i-nb_spectrum_bands/2)*SPECTR_XSIZE+SPECTR_XSIZE*SPECTR_XSIZE_FACTOR)/(GLfloat)nb_spectrum_bands;
			vertices[3][1]=y-spL;
			vertices[3][2]=z+0.0f;   /* Set z Value Of First Vertex */
			/* Render The Quad */
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
			
			cr*=0.5f;
			cg*=0.5f;
			cb*=0.5f;
			vertColor[0][0]=cr;vertColor[0][1]=cg;vertColor[0][2]=cb;
			vertices[0][0]=(GLfloat)(i-nb_spectrum_bands/2)*SPECTR_XSIZE/(GLfloat)nb_spectrum_bands;
			vertices[0][1]=y-spL;
			vertices[0][2]=z+0.0f;   /* Set z Value Of First Vertex */
			vertColor[1][0]=cr;vertColor[1][1]=cg;vertColor[1][2]=cb;
			vertices[1][0]=((GLfloat)(i-nb_spectrum_bands/2)*SPECTR_XSIZE+SPECTR_XSIZE*SPECTR_XSIZE_FACTOR)/(GLfloat)nb_spectrum_bands;
			vertices[1][1]=y-spL;
			vertices[1][2]=z+0.0f;   /* Set z Value Of Second Vertex */
			vertColor[2][0]=cr;vertColor[2][1]=cg;vertColor[2][2]=cb;
			vertices[2][0]=(GLfloat)(i-nb_spectrum_bands/2)*SPECTR_XSIZE/(GLfloat)nb_spectrum_bands;
			vertices[2][1]=y-spL;
			vertices[2][2]=z2;   /* Set z Value Of Second Vertex */
			vertColor[3][0]=cr;vertColor[3][1]=cg;vertColor[3][2]=cb;
			vertices[3][0]=((GLfloat)(i-nb_spectrum_bands/2)*SPECTR_XSIZE+SPECTR_XSIZE*SPECTR_XSIZE_FACTOR)/(GLfloat)nb_spectrum_bands;
			vertices[3][1]=y-spL;
			vertices[3][2]=z2;   /* Set z Value Of First Vertex */
			/* Render The Quad */
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
			
			cr*=0.5f;
			cg*=0.5f;
			cb*=0.5f;
			vertColor[0][0]=cr;vertColor[0][1]=cg;vertColor[0][2]=cb;
			vertices[0][0]=((GLfloat)(i-nb_spectrum_bands/2)*SPECTR_XSIZE+SPECTR_XSIZE*SPECTR_XSIZE_FACTOR)/(GLfloat)nb_spectrum_bands;
			vertices[0][1]=y+0;
			vertices[0][2]=z+0.0f;   /* Set z Value Of First Vertex */
			vertColor[1][0]=cr;vertColor[1][1]=cg;vertColor[1][2]=cb;
			vertices[1][0]=((GLfloat)(i-nb_spectrum_bands/2)*SPECTR_XSIZE+SPECTR_XSIZE*SPECTR_XSIZE_FACTOR)/(GLfloat)nb_spectrum_bands;
			vertices[1][1]=y-spL;
			vertices[1][2]=z+0.0f;   /* Set z Value Of Second Vertex */
			vertColor[2][0]=cr;vertColor[2][1]=cg;vertColor[2][2]=cb;
			vertices[2][0]=((GLfloat)(i-nb_spectrum_bands/2)*SPECTR_XSIZE+SPECTR_XSIZE*SPECTR_XSIZE_FACTOR)/(GLfloat)nb_spectrum_bands;
			vertices[2][1]=y+0;
			vertices[2][2]=z2;   /* Set z Value Of Second Vertex */
			vertColor[3][0]=cr;vertColor[3][1]=cg;vertColor[3][2]=cb;
			vertices[3][0]=((GLfloat)(i-nb_spectrum_bands/2)*SPECTR_XSIZE+SPECTR_XSIZE*SPECTR_XSIZE_FACTOR)/(GLfloat)nb_spectrum_bands;
			vertices[3][1]=y-spL;
			vertices[3][2]=z2;   /* Set z Value Of First Vertex */
			/* Render The Quad */
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
			
			vertColor[0][0]=cr;vertColor[0][1]=cg;vertColor[0][2]=cb;
			vertices[0][0]=((GLfloat)(i-nb_spectrum_bands/2)*SPECTR_XSIZE)/(GLfloat)nb_spectrum_bands;
			vertices[0][1]=y+0;
			vertices[0][2]=z+0.0f;   /* Set z Value Of First Vertex */
			vertColor[1][0]=cr;vertColor[1][1]=cg;vertColor[1][2]=cb;
			vertices[1][0]=((GLfloat)(i-nb_spectrum_bands/2)*SPECTR_XSIZE)/(GLfloat)nb_spectrum_bands;
			vertices[1][1]=y-spL;
			vertices[1][2]=z+0.0f;   /* Set z Value Of Second Vertex */
			vertColor[2][0]=cr;vertColor[2][1]=cg;vertColor[2][2]=cb;
			vertices[2][0]=((GLfloat)(i-nb_spectrum_bands/2)*SPECTR_XSIZE)/(GLfloat)nb_spectrum_bands;
			vertices[2][1]=y+0;
			vertices[2][2]=z2;   /* Set z Value Of Second Vertex */
			vertColor[3][0]=cr;vertColor[3][1]=cg;vertColor[3][2]=cb;
			vertices[3][0]=((GLfloat)(i-nb_spectrum_bands/2)*SPECTR_XSIZE)/(GLfloat)nb_spectrum_bands;
			vertices[3][1]=y-spL;
			vertices[3][2]=z2;   /* Set z Value Of First Vertex */
			/* Render The Quad */
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
			
			tg=spR*2/8;
			tb=spR*1/8;
			tr=spR*3/8;
			tr=tr-(tg+tb)/2;
			cr=tg/3;
			cg=tr/3;
			cb=tb;
			
			y=-SPECTRUM_Y;
			
			vertColor[0][0]=cr;vertColor[0][1]=cg;vertColor[0][2]=cb;
			vertices[0][0]=(GLfloat)(i-nb_spectrum_bands/2)*SPECTR_XSIZE/(GLfloat)nb_spectrum_bands;
			vertices[0][1]=y+0;   /* Set y Value Of First Vertex */
			vertices[0][2]=z+0.0f;   /* Set z Value Of First Vertex */
			vertColor[1][0]=cr;vertColor[1][1]=cg;vertColor[1][2]=cb;
			vertices[1][0]=((GLfloat)(i-nb_spectrum_bands/2)*SPECTR_XSIZE+SPECTR_XSIZE*SPECTR_XSIZE_FACTOR)/(GLfloat)nb_spectrum_bands;
			vertices[1][1]=y+0;   /* Set y Value Of Second Vertex */
			vertices[1][2]=z+0.0f;   /* Set z Value Of Second Vertex */
			
			spR*=0.5f;
			cr=tg;
			cg=tb;
			cb=tb/3;
			
			vertColor[2][0]=cr;vertColor[2][1]=cg;vertColor[2][2]=cb;
			vertices[2][0]=(GLfloat)(i-nb_spectrum_bands/2)*SPECTR_XSIZE/(GLfloat)nb_spectrum_bands;
			vertices[2][1]=y+spR;
			vertices[2][2]=z+0.0f;   /* Set z Value Of Second Vertex */
			vertColor[3][0]=cr;vertColor[3][1]=cg;vertColor[3][2]=cb;
			vertices[3][0]=((GLfloat)(i-nb_spectrum_bands/2)*SPECTR_XSIZE+SPECTR_XSIZE*SPECTR_XSIZE_FACTOR)/(GLfloat)nb_spectrum_bands;
			vertices[3][1]=y+spR;
			vertices[3][2]=z+0.0f;   /* Set z Value Of First Vertex */
			/* Render The Quad */
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
			
			cr*=0.5f;
			cg*=0.5f;
			cb*=0.5f;
			vertColor[0][0]=cr;vertColor[0][1]=cg;vertColor[0][2]=cb;
			vertices[0][0]=(GLfloat)(i-nb_spectrum_bands/2)*SPECTR_XSIZE/(GLfloat)nb_spectrum_bands;
			vertices[0][1]=y+spR;
			vertices[0][2]=z+0.0f;   /* Set z Value Of First Vertex */
			vertColor[1][0]=cr;vertColor[1][1]=cg;vertColor[1][2]=cb;
			vertices[1][0]=((GLfloat)(i-nb_spectrum_bands/2)*SPECTR_XSIZE+SPECTR_XSIZE*SPECTR_XSIZE_FACTOR)/(GLfloat)nb_spectrum_bands;
			vertices[1][1]=y+spR;
			vertices[1][2]=z+0.0f;   /* Set z Value Of Second Vertex */
			vertColor[2][0]=cr;vertColor[2][1]=cg;vertColor[2][2]=cb;
			vertices[2][0]=(GLfloat)(i-nb_spectrum_bands/2)*SPECTR_XSIZE/(GLfloat)nb_spectrum_bands;
			vertices[2][1]=y+spR;
			vertices[2][2]=z2;   /* Set z Value Of Second Vertex */
			vertColor[3][0]=cr;vertColor[3][1]=cg;vertColor[3][2]=cb;
			vertices[3][0]=((GLfloat)(i-nb_spectrum_bands/2)*SPECTR_XSIZE+SPECTR_XSIZE*SPECTR_XSIZE_FACTOR)/(GLfloat)nb_spectrum_bands;
			vertices[3][1]=y+spR;
			vertices[3][2]=z2;   /* Set z Value Of First Vertex */
			/* Render The Quad */
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
			
			cr*=0.5f;
			cg*=0.5f;
			cb*=0.5f;
			vertColor[0][0]=cr;vertColor[0][1]=cg;vertColor[0][2]=cb;
			vertices[0][0]=((GLfloat)(i-nb_spectrum_bands/2)*SPECTR_XSIZE+SPECTR_XSIZE*SPECTR_XSIZE_FACTOR)/(GLfloat)nb_spectrum_bands;
			vertices[0][1]=y+0;
			vertices[0][2]=z+0.0f;   /* Set z Value Of First Vertex */
			vertColor[1][0]=cr;vertColor[1][1]=cg;vertColor[1][2]=cb;
			vertices[1][0]=((GLfloat)(i-nb_spectrum_bands/2)*SPECTR_XSIZE+SPECTR_XSIZE*SPECTR_XSIZE_FACTOR)/(GLfloat)nb_spectrum_bands;
			vertices[1][1]=y+spR;
			vertices[1][2]=z+0.0f;   /* Set z Value Of Second Vertex */
			vertColor[2][0]=cr;vertColor[2][1]=cg;vertColor[2][2]=cb;
			vertices[2][0]=((GLfloat)(i-nb_spectrum_bands/2)*SPECTR_XSIZE+SPECTR_XSIZE*SPECTR_XSIZE_FACTOR)/(GLfloat)nb_spectrum_bands;
			vertices[2][1]=y+0;
			vertices[2][2]=z2;   /* Set z Value Of Second Vertex */
			vertColor[3][0]=cr;vertColor[3][1]=cg;vertColor[3][2]=cb;
			vertices[3][0]=((GLfloat)(i-nb_spectrum_bands/2)*SPECTR_XSIZE+SPECTR_XSIZE*SPECTR_XSIZE_FACTOR)/(GLfloat)nb_spectrum_bands;
			vertices[3][1]=y+spR;
			vertices[3][2]=z2;   /* Set z Value Of First Vertex */
			/* Render The Quad */
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
			
			vertColor[0][0]=cr;vertColor[0][1]=cg;vertColor[0][2]=cb;
			vertices[0][0]=((GLfloat)(i-nb_spectrum_bands/2)*SPECTR_XSIZE)/(GLfloat)nb_spectrum_bands;
			vertices[0][1]=y+0;
			vertices[0][2]=z+0.0f;   /* Set z Value Of First Vertex */
			vertColor[1][0]=cr;vertColor[1][1]=cg;vertColor[1][2]=cb;
			vertices[1][0]=((GLfloat)(i-nb_spectrum_bands/2)*SPECTR_XSIZE)/(GLfloat)nb_spectrum_bands;
			vertices[1][1]=y+spR;
			vertices[1][2]=z+0.0f;   /* Set z Value Of Second Vertex */
			vertColor[2][0]=cr;vertColor[2][1]=cg;vertColor[2][2]=cb;
			vertices[2][0]=((GLfloat)(i-nb_spectrum_bands/2)*SPECTR_XSIZE)/(GLfloat)nb_spectrum_bands;
			vertices[2][1]=y+0;
			vertices[2][2]=z2;   /* Set z Value Of Second Vertex */
			vertColor[3][0]=cr;vertColor[3][1]=cg;vertColor[3][2]=cb;
			vertices[3][0]=((GLfloat)(i-nb_spectrum_bands/2)*SPECTR_XSIZE)/(GLfloat)nb_spectrum_bands;
			vertices[3][1]=y+spR;
			vertices[3][2]=z2;   /* Set z Value Of First Vertex */
			/* Render The Quad */
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
			
		}
	}
	/* Disable Vertex Pointer */
    glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	
    //    glDisable(GL_BLEND);
	
    /* Pop The Matrix */
    glPopMatrix();
}

static int sphSize=0;
static int sphMode=0;
static GLfloat sphVert[(SPECTRUM_BANDS/2)*(SPECTRUM_BANDS/2)*4*5][3];  /* Holds Float Info For 4 Sets Of Vertices */
static GLfloat sphNorm[(SPECTRUM_BANDS/2)*(SPECTRUM_BANDS/2)*5][3];  /* Holds Float Info For 4 Sets Of Vertices */


void RenderUtils::DrawSpectrum3DSphere(short int *spectrumDataL,short int *spectrumDataR,uint ww,uint hh,float angle,int mode,int deviceType,int nb_spectrum_bands) {
	GLfloat x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4,spL,spR,ra1,rb1,ra2,rb2,r0;
    GLfloat xn,yn,zn,v1x,v1y,v1z,v2x,v2y,v2z,nn;
    int idxNorm,idxVert;
    short int *data;
	//////////////////////////////
	glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
	const float aspectRatio = (float)ww/(float)hh;
	const float _hw = 0.1f;
	const float _hh = _hw/aspectRatio;	
	glFrustumf(-_hw, _hw, -_hh, _hh, 1.0f, 200.0f);
    
//    glTranslatef(0.0, 0.0, 120.0);      /* Translate 50 Units Into The Screen */    
    
    glEnable(GL_COLOR_MATERIAL);
    glEnable( GL_LIGHTING );
    glEnable(GL_LIGHT0);

	
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glPushMatrix();                     /* Push The Modelview Matrix */
    
    glTranslatef(0.0, 0.0, -120.0);      /* Translate 50 Units Into The Screen */
    
//    glShadeModel(GL_FLAT);
    glLightfv(GL_LIGHT0, GL_POSITION, position );    
    glLightf(GL_LIGHT0, GL_SPOT_CUTOFF, 90);
    
    glRotatef(6*(sin(0.11*angle*M_PI/180)+0.3*sin(0.19*angle*M_PI/180)+0.7*sin(0.37*angle*M_PI/180)), 0, 0, 1);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_NORMAL_ARRAY);
    
	
    /* Begin Drawing Quads, setup vertex array pointer */
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glNormalPointer(GL_FLOAT, 0, normals);
    /* Enable Vertex Pointer */
    
    float divisor=1;
    if (mode==1) divisor=1;
    if (mode==2) divisor=3;
    
    if ((sphSize!=nb_spectrum_bands)||(sphMode!=mode)) { //change of size, recompute sphere
        sphSize=nb_spectrum_bands;
        sphMode=mode;
        idxNorm=idxVert=0;    
        for (int j=0;j<nb_spectrum_bands;j++)
            for (int i=0; i<nb_spectrum_bands; i++) {            
                //compute radius             
                ra1=(float)i*M_PI*2/nb_spectrum_bands;
                rb1=((float)j*M_PI/nb_spectrum_bands-M_PI_2)/divisor;
                ra2=(float)(i+1)*M_PI*2/nb_spectrum_bands;
                rb2=((float)(j+1)*M_PI/nb_spectrum_bands-M_PI_2)/divisor;
                //compute coord
                //TOP
                x1=cos(rb1)*cos(ra1);
                y1=sin(rb1);
                z1=-cos(rb1)*sin(ra1);                
                x2=cos(rb1)*cos(ra2);
                y2=sin(rb1);
                z2=-cos(rb1)*sin(ra2);                
                x3=cos(rb2)*cos(ra1);
                y3=sin(rb2);
                z3=-cos(rb2)*sin(ra1);                
                x4=cos(rb2)*cos(ra2);
                y4=sin(rb2);
                z4=-cos(rb2)*sin(ra2);
                
/*                v1x=x1-x2;
                v1y=y1-y2;
                v1z=z1-z2;
                v2x=x2-0;
                v2y=y2-0;
                v2z=z2-0;            
                xn=v1y*v2z-v1z*v2y;
                yn=v1z*v2x-v1x*v2z;
                zn=v1x*v2y-v1y*v2x;
                nn=sqrt(xn*xn+yn*yn+zn*zn);
                xn/=nn;
                yn/=nn;
                zn/=nn;*/
                sphNorm[idxNorm][0]=x1;
                sphNorm[idxNorm][1]=y1;
                sphNorm[idxNorm++][2]=z1;            
                sphVert[idxVert][0]=x1;
                sphVert[idxVert][1]=y1;
                sphVert[idxVert++][2]=z1; 
                sphVert[idxVert][0]=x2;
                sphVert[idxVert][1]=y2;
                sphVert[idxVert++][2]=z2;
                sphVert[idxVert][0]=x3;
                sphVert[idxVert][1]=y3;
                sphVert[idxVert++][2]=z3;
                sphVert[idxVert][0]=x4;
                sphVert[idxVert][1]=y4;
                sphVert[idxVert++][2]=z4;
                
                //LEFT
                x1=cos(rb1)*cos(ra1);
                y1=sin(rb1);
                z1=-cos(rb1)*sin(ra1);            
                x2=cos(rb2)*cos(ra1);
                y2=sin(rb2);
                z2=-cos(rb2)*sin(ra1);            
                x3=cos(rb1)*cos(ra1);
                y3=sin(rb1);
                z3=-cos(rb1)*sin(ra1);            
                x4=cos(rb2)*cos(ra1);
                y4=sin(rb2);
                z4=-cos(rb2)*sin(ra1);
                
                v1x=x1-x2;
                v1y=y1-y2;
                v1z=z1-z2;
                v2x=x2-0;
                v2y=y2-0;
                v2z=z2-0;            
                xn=v1y*v2z-v1z*v2y;
                yn=v1z*v2x-v1x*v2z;
                zn=v1x*v2y-v1y*v2x;
                nn=sqrt(xn*xn+yn*yn+zn*zn);
                xn/=nn;
                yn/=nn;
                zn/=nn;
                
                sphNorm[idxNorm][0]=xn;
                sphNorm[idxNorm][1]=yn;
                sphNorm[idxNorm++][2]=zn;            
                sphVert[idxVert][0]=x1;
                sphVert[idxVert][1]=y1;
                sphVert[idxVert++][2]=z1; 
                sphVert[idxVert][0]=x2;
                sphVert[idxVert][1]=y2;
                sphVert[idxVert++][2]=z2;
                sphVert[idxVert][0]=x3;
                sphVert[idxVert][1]=y3;
                sphVert[idxVert++][2]=z3;
                sphVert[idxVert][0]=x4;
                sphVert[idxVert][1]=y4;
                sphVert[idxVert++][2]=z4;
                
                //RIGHT
                x1=cos(rb1)*cos(ra2);
                y1=sin(rb1);
                z1=-cos(rb1)*sin(ra2);            
                x2=cos(rb2)*cos(ra2);
                y2=sin(rb2);
                z2=-cos(rb2)*sin(ra2);            
                x3=cos(rb1)*cos(ra2);
                y3=sin(rb1);
                z3=-cos(rb1)*sin(ra2);            
                x4=cos(rb2)*cos(ra2);
                y4=sin(rb2);
                z4=-cos(rb2)*sin(ra2);
                
                v1x=x1-x2;
                v1y=y1-y2;
                v1z=z1-z2;
                v2x=x2-0;
                v2y=y2-0;
                v2z=z2-0;            
                xn=v1y*v2z-v1z*v2y;
                yn=v1z*v2x-v1x*v2z;
                zn=v1x*v2y-v1y*v2x;
                nn=sqrt(xn*xn+yn*yn+zn*zn);
                xn/=-nn;
                yn/=-nn;
                zn/=-nn;
                
                
                sphNorm[idxNorm][0]=xn;
                sphNorm[idxNorm][1]=yn;
                sphNorm[idxNorm++][2]=zn;            
                sphVert[idxVert][0]=x1;
                sphVert[idxVert][1]=y1;
                sphVert[idxVert++][2]=z1; 
                sphVert[idxVert][0]=x2;
                sphVert[idxVert][1]=y2;
                sphVert[idxVert++][2]=z2;
                sphVert[idxVert][0]=x3;
                sphVert[idxVert][1]=y3;
                sphVert[idxVert++][2]=z3;
                sphVert[idxVert][0]=x4;
                sphVert[idxVert][1]=y4;
                sphVert[idxVert++][2]=z4;
                
                //FRONT
                x1=cos(rb1)*cos(ra1);
                y1=sin(rb1);
                z1=-cos(rb1)*sin(ra1);            
                x2=cos(rb1)*cos(ra2);
                y2=sin(rb1);
                z2=-cos(rb1)*sin(ra2);            
                x3=cos(rb1)*cos(ra1);
                y3=sin(rb1);
                z3=-cos(rb1)*sin(ra1);            
                x4=cos(rb1)*cos(ra2);
                y4=sin(rb1);
                z4=-cos(rb1)*sin(ra2);
                
                v1x=x1-x2;
                v1y=y1-y2;
                v1z=z1-z2;
                v2x=x2-0;
                v2y=y2-0;
                v2z=z2-0;            
                xn=v1y*v2z-v1z*v2y;
                yn=v1z*v2x-v1x*v2z;
                zn=v1x*v2y-v1y*v2x;
                nn=sqrt(xn*xn+yn*yn+zn*zn);
                xn/=-nn;
                yn/=-nn;
                zn/=-nn;
                
                sphNorm[idxNorm][0]=xn;
                sphNorm[idxNorm][1]=yn;
                sphNorm[idxNorm++][2]=zn;            
                sphVert[idxVert][0]=x1;
                sphVert[idxVert][1]=y1;
                sphVert[idxVert++][2]=z1; 
                sphVert[idxVert][0]=x2;
                sphVert[idxVert][1]=y2;
                sphVert[idxVert++][2]=z2;
                sphVert[idxVert][0]=x3;
                sphVert[idxVert][1]=y3;
                sphVert[idxVert++][2]=z3;
                sphVert[idxVert][0]=x4;
                sphVert[idxVert][1]=y4;
                sphVert[idxVert++][2]=z4;
                
                //BACK
                x1=cos(rb2)*cos(ra1);
                y1=sin(rb2);
                z1=-cos(rb2)*sin(ra1);            
                x2=cos(rb2)*cos(ra2);
                y2=sin(rb2);
                z2=-cos(rb2)*sin(ra2);            
                x3=cos(rb2)*cos(ra1);
                y3=sin(rb2);
                z3=-cos(rb2)*sin(ra1);            
                x4=cos(rb2)*cos(ra2);
                y4=sin(rb2);
                z4=-cos(rb2)*sin(ra2);
                
                v1x=x1-x2;
                v1y=y1-y2;
                v1z=z1-z2;
                v2x=x2-0;
                v2y=y2-0;
                v2z=z2-0;            
                xn=v1y*v2z-v1z*v2y;
                yn=v1z*v2x-v1x*v2z;
                zn=v1x*v2y-v1y*v2x;
                nn=sqrt(xn*xn+yn*yn+zn*zn);
                xn/=nn;
                yn/=nn;
                zn/=nn;
                
                sphNorm[idxNorm][0]=xn;
                sphNorm[idxNorm][1]=yn;
                sphNorm[idxNorm++][2]=zn;            
                sphVert[idxVert][0]=x1;
                sphVert[idxVert][1]=y1;
                sphVert[idxVert++][2]=z1; 
                sphVert[idxVert][0]=x2;
                sphVert[idxVert][1]=y2;
                sphVert[idxVert++][2]=z2;
                sphVert[idxVert][0]=x3;
                sphVert[idxVert][1]=y3;
                sphVert[idxVert++][2]=z3;
                sphVert[idxVert][0]=x4;
                sphVert[idxVert][1]=y4;
                sphVert[idxVert++][2]=z4;
            }        
        
    }
	
    
	glColor4f(1,1,1,1);    
    for (int k=0;k<2;k++) {
        glPushMatrix();                     /* Push The Modelview Matrix */
        if (k==0) {
            r0=(float)spectrumDataL[0]/1800.0f;
            if (r0<1) r0=1;
            if (r0>1.1) r0=1.1;            
            spectrumDataL[0]=spectrumDataL[1];            
            data=spectrumDataL;
            glTranslatef(-6.0, 0.0, 0.0);
            glRotatef(angle/17.0f, 1, 0, 0);
            glRotatef(angle/7.0f, 0, 1, 0);
            glRotatef(angle/3.0f, 0, 0, 1);
            
            glLightfv(GL_LIGHT0, GL_AMBIENT, ambientLight[0]);
            glLightfv(GL_LIGHT0, GL_DIFFUSE, diffuseLight[0]);
            glLightfv(GL_LIGHT0, GL_SPECULAR, specularLight[0] );        
            
            
            
        } else {
            r0=(float)spectrumDataR[0]/1800.0f;
            if (r0<1) r0=1;
            if (r0>1.1) r0=1.1;            
            spectrumDataR[0]=spectrumDataR[1];            
            data=spectrumDataR;
            glTranslatef(6.0, 0.0, 0.0);
            glRotatef(angle/13.0f, -1, 0, 0);
            glRotatef(angle/7.0f, 0, -1, 0);
            glRotatef(angle/17.0f, 0, 0, 1);
            
            glLightfv(GL_LIGHT0, GL_AMBIENT, ambientLight[1]);
            glLightfv(GL_LIGHT0, GL_DIFFUSE, diffuseLight[1]);
            glLightfv(GL_LIGHT0, GL_SPECULAR, specularLight[1] );        
            
            
            
        }
        idxNorm=idxVert=0;    
        for (int j=0;j<nb_spectrum_bands;j++)
            for (int i=0; i<nb_spectrum_bands; i++) {            
                spL=(float)spectrumDataL[j]/500.0f;
                if (spL>1.5) spL=1.5;
                
                if ((i+j)&1) spL=0;
                
                //UP
                normals[0][0]=sphNorm[idxNorm][0];
                normals[0][1]=sphNorm[idxNorm][1];
                normals[0][2]=sphNorm[idxNorm][2];            
                vertices[0][0]=sphVert[idxVert][0]*(4+spL)*r0;
                vertices[0][1]=sphVert[idxVert][1]*(4+spL)*r0;
                vertices[0][2]=sphVert[idxVert++][2]*(4+spL)*r0; 
                
                normals[1][0]=sphNorm[idxNorm][0];
                normals[1][1]=sphNorm[idxNorm][1];
                normals[1][2]=sphNorm[idxNorm][2];
                vertices[1][0]=sphVert[idxVert][0]*(4+spL)*r0;
                vertices[1][1]=sphVert[idxVert][1]*(4+spL)*r0;
                vertices[1][2]=sphVert[idxVert++][2]*(4+spL)*r0; 
                
                normals[2][0]=sphNorm[idxNorm][0];
                normals[2][1]=sphNorm[idxNorm][1];
                normals[2][2]=sphNorm[idxNorm][2];
                vertices[2][0]=sphVert[idxVert][0]*(4+spL)*r0;
                vertices[2][1]=sphVert[idxVert][1]*(4+spL)*r0;
                vertices[2][2]=sphVert[idxVert++][2]*(4+spL)*r0; 
                
                normals[3][0]=sphNorm[idxNorm][0];
                normals[3][1]=sphNorm[idxNorm][1];
                normals[3][2]=sphNorm[idxNorm++][2];
                vertices[3][0]=sphVert[idxVert][0]*(4+spL)*r0;
                vertices[3][1]=sphVert[idxVert][1]*(4+spL)*r0;
                vertices[3][2]=sphVert[idxVert++][2]*(4+spL)*r0; 
                
                glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
                
                //LEFT            
                normals[0][0]=sphNorm[idxNorm][0];
                normals[0][1]=sphNorm[idxNorm][1];
                normals[0][2]=sphNorm[idxNorm][2];            
                vertices[0][0]=sphVert[idxVert][0]*(4+spL)*r0;
                vertices[0][1]=sphVert[idxVert][1]*(4+spL)*r0;
                vertices[0][2]=sphVert[idxVert++][2]*(4+spL)*r0; 
                
                normals[1][0]=sphNorm[idxNorm][0];
                normals[1][1]=sphNorm[idxNorm][1];
                normals[1][2]=sphNorm[idxNorm][2];
                vertices[1][0]=sphVert[idxVert][0]*(4+spL)*r0;
                vertices[1][1]=sphVert[idxVert][1]*(4+spL)*r0;
                vertices[1][2]=sphVert[idxVert++][2]*(4+spL)*r0; 
                
                normals[2][0]=sphNorm[idxNorm][0];
                normals[2][1]=sphNorm[idxNorm][1];
                normals[2][2]=sphNorm[idxNorm][2];
                vertices[2][0]=sphVert[idxVert][0]*(4)*r0;
                vertices[2][1]=sphVert[idxVert][1]*(4)*r0;
                vertices[2][2]=sphVert[idxVert++][2]*(4)*r0; 
                
                normals[3][0]=sphNorm[idxNorm][0];
                normals[3][1]=sphNorm[idxNorm][1];
                normals[3][2]=sphNorm[idxNorm++][2];
                vertices[3][0]=sphVert[idxVert][0]*(4)*r0;
                vertices[3][1]=sphVert[idxVert][1]*(4)*r0;
                vertices[3][2]=sphVert[idxVert++][2]*(4)*r0; 
                
                glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
                
                
                //RIGHT
                normals[0][0]=sphNorm[idxNorm][0];
                normals[0][1]=sphNorm[idxNorm][1];
                normals[0][2]=sphNorm[idxNorm][2];            
                vertices[0][0]=sphVert[idxVert][0]*(4+spL)*r0;
                vertices[0][1]=sphVert[idxVert][1]*(4+spL)*r0;
                vertices[0][2]=sphVert[idxVert++][2]*(4+spL)*r0; 
                
                normals[1][0]=sphNorm[idxNorm][0];
                normals[1][1]=sphNorm[idxNorm][1];
                normals[1][2]=sphNorm[idxNorm][2];
                vertices[1][0]=sphVert[idxVert][0]*(4+spL)*r0;
                vertices[1][1]=sphVert[idxVert][1]*(4+spL)*r0;
                vertices[1][2]=sphVert[idxVert++][2]*(4+spL)*r0; 
                
                normals[2][0]=sphNorm[idxNorm][0];
                normals[2][1]=sphNorm[idxNorm][1];
                normals[2][2]=sphNorm[idxNorm][2];
                vertices[2][0]=sphVert[idxVert][0]*(4)*r0;
                vertices[2][1]=sphVert[idxVert][1]*(4)*r0;
                vertices[2][2]=sphVert[idxVert++][2]*(4)*r0; 
                
                normals[3][0]=sphNorm[idxNorm][0];
                normals[3][1]=sphNorm[idxNorm][1];
                normals[3][2]=sphNorm[idxNorm++][2];
                vertices[3][0]=sphVert[idxVert][0]*(4)*r0;
                vertices[3][1]=sphVert[idxVert][1]*(4)*r0;
                vertices[3][2]=sphVert[idxVert++][2]*(4)*r0; 
                
                glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
                
                //FRONT
                normals[0][0]=sphNorm[idxNorm][0];
                normals[0][1]=sphNorm[idxNorm][1];
                normals[0][2]=sphNorm[idxNorm][2];            
                vertices[0][0]=sphVert[idxVert][0]*(4+spL)*r0;
                vertices[0][1]=sphVert[idxVert][1]*(4+spL)*r0;
                vertices[0][2]=sphVert[idxVert++][2]*(4+spL)*r0; 
                
                normals[1][0]=sphNorm[idxNorm][0];
                normals[1][1]=sphNorm[idxNorm][1];
                normals[1][2]=sphNorm[idxNorm][2];
                vertices[1][0]=sphVert[idxVert][0]*(4+spL)*r0;
                vertices[1][1]=sphVert[idxVert][1]*(4+spL)*r0;
                vertices[1][2]=sphVert[idxVert++][2]*(4+spL)*r0; 
                
                normals[2][0]=sphNorm[idxNorm][0];
                normals[2][1]=sphNorm[idxNorm][1];
                normals[2][2]=sphNorm[idxNorm][2];
                vertices[2][0]=sphVert[idxVert][0]*(4)*r0;
                vertices[2][1]=sphVert[idxVert][1]*(4)*r0;
                vertices[2][2]=sphVert[idxVert++][2]*(4)*r0; 
                
                normals[3][0]=sphNorm[idxNorm][0];
                normals[3][1]=sphNorm[idxNorm][1];
                normals[3][2]=sphNorm[idxNorm++][2];
                vertices[3][0]=sphVert[idxVert][0]*(4)*r0;
                vertices[3][1]=sphVert[idxVert][1]*(4)*r0;
                vertices[3][2]=sphVert[idxVert++][2]*(4)*r0; 
                
                glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
                
                //BACK
                normals[0][0]=sphNorm[idxNorm][0];
                normals[0][1]=sphNorm[idxNorm][1];
                normals[0][2]=sphNorm[idxNorm][2];            
                vertices[0][0]=sphVert[idxVert][0]*(4+spL)*r0;
                vertices[0][1]=sphVert[idxVert][1]*(4+spL)*r0;
                vertices[0][2]=sphVert[idxVert++][2]*(4+spL)*r0; 
                
                normals[1][0]=sphNorm[idxNorm][0];
                normals[1][1]=sphNorm[idxNorm][1];
                normals[1][2]=sphNorm[idxNorm][2];
                vertices[1][0]=sphVert[idxVert][0]*(4+spL)*r0;
                vertices[1][1]=sphVert[idxVert][1]*(4+spL)*r0;
                vertices[1][2]=sphVert[idxVert++][2]*(4+spL)*r0; 
                
                normals[2][0]=sphNorm[idxNorm][0];
                normals[2][1]=sphNorm[idxNorm][1];
                normals[2][2]=sphNorm[idxNorm][2];
                vertices[2][0]=sphVert[idxVert][0]*(4)*r0;
                vertices[2][1]=sphVert[idxVert][1]*(4)*r0;
                vertices[2][2]=sphVert[idxVert++][2]*(4)*r0; 
                
                normals[3][0]=sphNorm[idxNorm][0];
                normals[3][1]=sphNorm[idxNorm][1];
                normals[3][2]=sphNorm[idxNorm++][2];
                vertices[3][0]=sphVert[idxVert][0]*(4)*r0;
                vertices[3][1]=sphVert[idxVert][1]*(4)*r0;
                vertices[3][2]=sphVert[idxVert++][2]*(4)*r0; 
                
                glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
                
                
            }        
        glPopMatrix();
    }
	/* Disable Vertex Pointer */
    glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	
    //    glDisable(GL_BLEND);
	
    /* Pop The Matrix */
    glPopMatrix();
    
    glDisable(GL_LIGHT0);    
    glDisable( GL_LIGHTING );
    glDisable(GL_COLOR_MATERIAL);
    
}


void RenderUtils::DrawSpectrum3DMorph(short int *spectrumDataL,short int *spectrumDataR,uint ww,uint hh,float angle,int mode,int deviceType,int nb_spectrum_bands) {
	GLfloat x1,x2,x3,x4,y1,y2,y3,y4,z1,z2,spL,spR;   
    GLfloat cr,cg,cb,tr,tg,tb;  
	//////////////////////////////
	glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
	
    //	glEnable(GL_BLEND);
    //	glBlendFunc(GL_ONE, GL_ONE);
    
	
	const float aspectRatio = (float)ww/(float)hh;
	const float _hw = 0.1f;
	const float _hh = _hw/aspectRatio;
	glFrustumf(-_hw, _hw, -_hh, _hh, 1.0f, (SPECTRUM_DEPTH-1)*SPECTRUM_ZSIZE+220.0f);
    glPushMatrix();                     /* Push The Modelview Matrix */
    glTranslatef(0.0, 0.0, -180.0);      /* Translate 50 Units Into The Screen */
	if ((mode==3)||(mode==6)) glRotatef(angle/30.0f, 0, 0, 1);
	if ((mode==2)||(mode==5)) glRotatef(90.0f, 0, 0, 1);
    /* Begin Drawing Quads, setup vertex array pointer */
    glVertexPointer(3, GL_FLOAT, 0, vertices);
	glColorPointer(4, GL_FLOAT, 0, vertColor);
    /* Enable Vertex Pointer */
    glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	for (int i=0;i<nb_spectrum_bands;i++) {
		oldSpectrumDataL[SPECTRUM_DEPTH-1][i]=((float)spectrumDataL[i]/128.0f<24?(float)spectrumDataL[i]/128.0f:24);
		oldSpectrumDataR[SPECTRUM_DEPTH-1][i]=((float)spectrumDataR[i]/128.0f<24?(float)spectrumDataR[i]/128.0f:24);
	}
	
	vertColor[0][3]=vertColor[1][3]=vertColor[2][3]=vertColor[3][3]=1;
	
	for (int j=1;j<SPECTRUM_DEPTH;j++) {
		for (int i=0; i<nb_spectrum_bands; i++) {
			oldSpectrumDataL[j-1][i]=oldSpectrumDataL[j][i]*SPECTRUM_DECREASE_FACTOR;
			oldSpectrumDataR[j-1][i]=oldSpectrumDataR[j][i]*SPECTRUM_DECREASE_FACTOR;
			z1=-(j-1)*(SPECTRUM_ZSIZE);
			if (mode<=3) z2=z1-(SPECTRUM_ZSIZE)*0.9f;
			else z2=z1*0.9f;
			if (z1>0) z1=0;
			if (z2>0) z2=0;
			spL=oldSpectrumDataL[j][i];
			spR=oldSpectrumDataR[j][i];
			tg=spR*2/8; if (tg<0) tg=0; if (tg>255) tg=255;
			tb=spR*1/8; if (tb<0) tb=0; if (tb>255) tb=255;
			tr=spR*3/8; if (tr<0) tr=0; if (tr>255) tr=255;
			tr=tr-(tg+tb)/2;if (tr<0) tr=0;
			cr=tg/3;
			cg=tr/3;
			cb=tb;
			
			x1=(25)*cos( (((float)i+0.0f)/(nb_spectrum_bands))*3.146);
			x3=(25)*cos( (((float)i+1.0f)/(nb_spectrum_bands))*3.146);
			
			x2=(25-spL)*cos( (((float)i+0.5f)/(nb_spectrum_bands))*3.146)+(x1-x3)/2;//(25-spL)*cos( (((float)i+0.0f)/(nb_spectrum_bands))*3.146);
			x4=(25-spL)*cos( (((float)i+0.5f)/(nb_spectrum_bands))*3.146)-(x1-x3)/2;//(25-spL)*cos( (((float)i+1.0f)/(nb_spectrum_bands))*3.146);
			
			y1=(25)*sin( (((float)i+0.0f)/(nb_spectrum_bands))*3.146 );
			y3=(25)*sin( (((float)i+1.0f)/(nb_spectrum_bands))*3.146 );
			
			y2=(25-spL)*sin( (((float)i+0.5f)/(nb_spectrum_bands))*3.146 )+(y1-y3)/2;//(25-spL)*sin( (((float)i+0.0f)/(nb_spectrum_bands))*3.146 );
			y4=(25-spL)*sin( (((float)i+0.5f)/(nb_spectrum_bands))*3.146 )-(y1-y3)/2;//(25-spL)*sin( (((float)i+1.0f)/(nb_spectrum_bands))*3.146 );
			
			vertColor[0][0]=cr;vertColor[0][1]=cg;vertColor[0][2]=cb;
			vertices[0][0]=x1;
			vertices[0][1]=y1;
			vertices[0][2]=z1;   /* Set z Value Of First Vertex */
			vertColor[1][0]=cr;vertColor[1][1]=cg;vertColor[1][2]=cb;
			vertices[1][0]=x3;
			vertices[1][1]=y3;
			vertices[1][2]=z1;   /* Set z Value Of Second Vertex */
			cr=tb;
			cg=tr/3;
			cb=tg;
			vertColor[2][0]=cr;vertColor[2][1]=cg;vertColor[2][2]=cb;
			vertices[2][0]=x2;
			vertices[2][1]=y2;
			vertices[2][2]=z1;   /* Set z Value Of Second Vertex */
			vertColor[3][0]=cr;vertColor[3][1]=cg;vertColor[3][2]=cb;
			vertices[3][0]=x4;
			vertices[3][1]=y4;
			vertices[3][2]=z1;   /* Set z Value Of First Vertex */
			/* Render The Quad */
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
			cr*=0.25f;
			cg*=0.25f;
			cb*=0.25f;
			vertColor[0][0]=cr;vertColor[0][1]=cg;vertColor[0][2]=cb;
			vertices[0][0]=x2;
			vertices[0][1]=y2;
			vertices[0][2]=z1;   /* Set z Value Of First Vertex */
			vertColor[1][0]=cr;vertColor[1][1]=cg;vertColor[1][2]=cb;
			vertices[1][0]=x2;
			vertices[1][1]=y2;
			vertices[1][2]=z2;   /* Set z Value Of Second Vertex */
			
			vertColor[2][0]=cr;vertColor[2][1]=cg;vertColor[2][2]=cb;
			vertices[2][0]=x4;
			vertices[2][1]=y4;
			vertices[2][2]=z1;   /* Set z Value Of Second Vertex */
			vertColor[3][0]=cr;vertColor[3][1]=cg;vertColor[3][2]=cb;
			vertices[3][0]=x4;
			vertices[3][1]=y4;
			vertices[3][2]=z2;   /* Set z Value Of First Vertex */
			/* Render The Quad */
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
			
			
			tg=spR*2/8; if (tg<0) tg=0; if (tg>255) tg=255;
			tb=spR*1/8; if (tb<0) tb=0; if (tb>255) tb=255;
			tr=spR*3/8; if (tr<0) tr=0; if (tr>255) tr=255;
			tr=tr-(tg+tb)/2;if (tr<0) tr=0;
			cr=tg/3;
			cg=tr/3;
			cb=tb;
			
			
            /*			x1=(25)*cos( (((float)i+0.0f)/(nb_spectrum_bands))*3.146);
             x2=(25-spR)*cos( (((float)i+0.0f)/(nb_spectrum_bands))*3.146);
             x3=(25)*cos( (((float)i+1.0f)/(nb_spectrum_bands))*3.146);
             x4=(25-spR)*cos( (((float)i+1.0f)/(nb_spectrum_bands))*3.146);
             y1=-(25)*sin( (((float)i+0.0f)/(nb_spectrum_bands))*3.146 );
             y2=-(25-spR)*sin( (((float)i+0.0f)/(nb_spectrum_bands))*3.146 );
             y3=-(25)*sin( (((float)i+1.0f)/(nb_spectrum_bands))*3.146 );
             y4=-(25-spR)*sin( (((float)i+1.0f)/(nb_spectrum_bands))*3.146 );*/
			
			x1=(25)*cos( (((float)i+0.0f)/(nb_spectrum_bands))*3.146);
			x3=(25)*cos( (((float)i+1.0f)/(nb_spectrum_bands))*3.146);
			
			x2=(25-spR)*cos( (((float)i+0.5f)/(nb_spectrum_bands))*3.146)+(x1-x3)/2;//(25-spL)*cos( (((float)i+0.0f)/(nb_spectrum_bands))*3.146);
			x4=(25-spR)*cos( (((float)i+0.5f)/(nb_spectrum_bands))*3.146)-(x1-x3)/2;//(25-spL)*cos( (((float)i+1.0f)/(nb_spectrum_bands))*3.146);
			
			y1=-(25)*sin( (((float)i+0.0f)/(nb_spectrum_bands))*3.146 );
			y3=-(25)*sin( (((float)i+1.0f)/(nb_spectrum_bands))*3.146 );
			
			y2=-(25-spR)*sin( (((float)i+0.5f)/(nb_spectrum_bands))*3.146 )+(y1-y3)/2;//(25-spL)*sin( (((float)i+0.0f)/(nb_spectrum_bands))*3.146 );
			y4=-(25-spR)*sin( (((float)i+0.5f)/(nb_spectrum_bands))*3.146 )-(y1-y3)/2;//(25-spL)*sin( (((float)i+1.0f)/(nb_spectrum_bands))*3.146 );
			
			
			
			vertColor[0][0]=cr;vertColor[0][1]=cg;vertColor[0][2]=cb;
			vertices[0][0]=x1;
			vertices[0][1]=y1;
			vertices[0][2]=z1;   /* Set z Value Of First Vertex */
			vertColor[1][0]=cr;vertColor[1][1]=cg;vertColor[1][2]=cb;
			vertices[1][0]=x3;
			vertices[1][1]=y3;
			vertices[1][2]=z1;   /* Set z Value Of Second Vertex */
			cr=tg;
			cg=tb;
			cb=tb/3;
			vertColor[2][0]=cr;vertColor[2][1]=cg;vertColor[2][2]=cb;
			vertices[2][0]=x2;
			vertices[2][1]=y2;
			vertices[2][2]=z1;   /* Set z Value Of Second Vertex */
			vertColor[3][0]=cr;vertColor[3][1]=cg;vertColor[3][2]=cb;
			vertices[3][0]=x4;
			vertices[3][1]=y4;
			vertices[3][2]=z1;   /* Set z Value Of First Vertex */
			/* Render The Quad */
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
			cr*=0.25f;
			cg*=0.25f;
			cb*=0.25f;
			vertColor[0][0]=cr;vertColor[0][1]=cg;vertColor[0][2]=cb;
			vertices[0][0]=x2;
			vertices[0][1]=y2;
			vertices[0][2]=z1;   /* Set z Value Of First Vertex */
			vertColor[1][0]=cr;vertColor[1][1]=cg;vertColor[1][2]=cb;
			vertices[1][0]=x2;
			vertices[1][1]=y2;
			vertices[1][2]=z2;   /* Set z Value Of Second Vertex */
			
			vertColor[2][0]=cr;vertColor[2][1]=cg;vertColor[2][2]=cb;
			vertices[2][0]=x4;
			vertices[2][1]=y4;
			vertices[2][2]=z1;   /* Set z Value Of Second Vertex */
			vertColor[3][0]=cr;vertColor[3][1]=cg;vertColor[3][2]=cb;
			vertices[3][0]=x4;
			vertices[3][1]=y4;
			vertices[3][2]=z2;   /* Set z Value Of First Vertex */
			/* Render The Quad */
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
            
		}
	}
	/* Disable Vertex Pointer */
    glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	
    //	glDisable(GL_BLEND);
    
	
    /* Pop The Matrix */
    glPopMatrix();
}

#define MIDIFX_LEN 60
int data_midifx_len=MIDIFX_LEN;
unsigned char data_midifx_note[MIDIFX_LEN][256];
unsigned char data_midifx_ch[MIDIFX_LEN][256];
unsigned char data_midifx_vol[MIDIFX_LEN][256];
unsigned char data_midifx_st[MIDIFX_LEN][256];
int data_midifx_first=1;


#define VOICE_FREE	(1<<0)
#define VOICE_ON	(1<<1)
#define VOICE_SUSTAINED	(1<<2)
#define VOICE_OFF	(1<<3)
#define VOICE_DIE	(1<<4)

unsigned int data_midifx_col[16]={
    0xFF5512,0x761AFF,0x21ff94,0xffb129,
    0xcb30ff,0x38ffe4,0xfffc40,0xff47ed,
    0x4fd9ff,0xc7ff57,0xff5eb7,0x66a8ff,
    0x9cff6e,0xff7591,0x7d88ff,0x85ff89};


void RenderUtils::DrawMidiFX(int *data,uint ww,uint hh,int deviceType,int horiz_vert,int note_display_range, int note_display_offset,int fx_len) {
	LineVertex *ptsB;
	int cr,cg,cb,ca;
    int index;
    int band_width,ofs_band;
    int line_width;
    
    if (fx_len!=data_midifx_len) {
        data_midifx_len=fx_len;
        data_midifx_first=1;
    }
    
    //if first launch, clear buffers
    if (data_midifx_first) {
        data_midifx_first=0;
        for (int i=0;i<data_midifx_len;i++) {
            memset(data_midifx_note[i],0,256);
        }
    }
    //update old ones
    for (int j=0;j<data_midifx_len-1;j++) {
        memcpy(data_midifx_note[j],data_midifx_note[j+1],256);
        memcpy(data_midifx_ch[j],data_midifx_ch[j+1],256);
        memcpy(data_midifx_vol[j],data_midifx_vol[j+1],256);
        memcpy(data_midifx_st[j],data_midifx_st[j+1],256);
    }
    //add new one
    for (int i=0;i<256;i++) {
        int note=data[i];
        data_midifx_note[data_midifx_len-1][i]=note&0xFF;
        data_midifx_ch[data_midifx_len-1][i]=(note>>8)&0xFF;
        data_midifx_st[data_midifx_len-1][i]=(note>>24)&0xFF;
        data_midifx_vol[data_midifx_len-1][i]=(note>>16)&0xFF;        
        
    }
    
	
	ptsB=(LineVertex*)malloc(sizeof(LineVertex)*2*256);
	
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
    
    if (horiz_vert==0) {//Horiz
        band_width=ww/data_midifx_len;
        ofs_band=(ww-band_width*data_midifx_len)>>1;
        line_width=hh/note_display_range;
    } else { //vert
        band_width=hh/data_midifx_len;
        ofs_band=(hh-band_width*data_midifx_len)>>1;
        line_width=ww/note_display_range;
    }
    
	
	glDisable(GL_BLEND);
    
    glVertexPointer(2, GL_SHORT, sizeof(LineVertex), &ptsB[0].x);
    glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(LineVertex), &ptsB[0].r);
    
    for (int j=0;j<data_midifx_len;j++) {
        if (j!=data_midifx_len-1-MIDIFX_OFS) glLineWidth(line_width);
        else glLineWidth(line_width+2);
        index=0;
        for (int i=0; i<256; i++) {        
            if (data_midifx_note[j][i]) {
                int ch=data_midifx_ch[j][i];
                int vol=data_midifx_vol[j][i];
                int st=data_midifx_st[j][i];            
                int pos=(data_midifx_note[j][i])*line_width-note_display_offset;
                cr=data_midifx_col[ch&0xF]>>16;
                cg=(data_midifx_col[ch&0xF]>>8)&0xFF;
                cb=data_midifx_col[ch&0xF]&0xFF;
                if (ch&0x10) { //if channel is >= 16, reversed palette is used
                    cr^=0xFF;
                    cg^=0xFF;
                    cb^=0xFF;
                }            
                cr=(cr*vol>>6);
                cg=(cg*vol>>6);
                cb=(cb*vol>>6);
                if ((j==data_midifx_len-1-MIDIFX_OFS)&&(st&(VOICE_ON))) {
                    cr=255;//(cr+255*3)>>2;
                    cg=255;//(cg+255*3)>>2;
                    cb=255;//(cb+255*3)>>2;
                }
                
                if (cr>255) cr=255;
                if (cg>255) cg=255;
                if (cb>255) cb=255;
                
                if (vol) {
                    //ca=vol*vol; if(ca>255) ca=255;
                    ca=255;
                    if (horiz_vert==0) { //horiz
                        if ((pos>=0)&&(pos<hh)) {
                            ptsB[index++] = LineVertex(j*band_width+ofs_band, pos,cr,cg,cb,ca);
                            ptsB[index++] = LineVertex(j*band_width+band_width+ofs_band, pos,cr,cg,cb,ca);
                        }
                    } else {
                        if ((pos>=0)&&(pos<ww)) {
                            ptsB[index++] = LineVertex(pos,j*band_width+ofs_band,cr,cg,cb,ca);
                            ptsB[index++] = LineVertex(pos,j*band_width+band_width+ofs_band,cr,cg,cb,ca);
                        }
                    }
                }
            }		
        }
        glDrawArrays(GL_LINES, 0, index);
        
    }
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	glEnable(GL_BLEND);
	
	//current playing line
    //    230,76,153
    cr=120;
    cg=100;
    cb=200;
    if (horiz_vert==0) {
        ptsB[0] = LineVertex((data_midifx_len-MIDIFX_OFS-1)*band_width+(band_width>>1)+ofs_band, 0,cr,cg,cb,120);
        ptsB[1] = LineVertex((data_midifx_len-MIDIFX_OFS-1)*band_width+(band_width>>1)+ofs_band, hh, cr,cg,cb,120);
    } else {
        ptsB[0] = LineVertex( 0,(data_midifx_len-MIDIFX_OFS-1)*band_width+(band_width>>1)+ofs_band,cr,cg,cb,120);
        ptsB[1] = LineVertex(ww,(data_midifx_len-MIDIFX_OFS-1)*band_width+(band_width>>1)+ofs_band,  cr,cg,cb,120);
        
    }
	glLineWidth(band_width);
	glDrawArrays(GL_LINES, 0, 2);
    
    if (horiz_vert==0) {
        ptsB[0] = LineVertex((data_midifx_len-MIDIFX_OFS-1)*band_width+ofs_band, 0,cr,cg,cb,40);
        ptsB[1] = LineVertex((data_midifx_len-MIDIFX_OFS-1)*band_width+ofs_band, hh, cr,cg,cb,40);
        ptsB[2] = LineVertex((data_midifx_len-MIDIFX_OFS)*band_width+ofs_band, 0,cr,cg,cb,160);
        ptsB[3] = LineVertex((data_midifx_len-MIDIFX_OFS)*band_width+ofs_band, hh, cr,cg,cb,160);
    } else {
        ptsB[0] = LineVertex(0,(data_midifx_len-MIDIFX_OFS-1)*band_width+ofs_band,cr,cg,cb,40);
        ptsB[1] = LineVertex(ww,(data_midifx_len-MIDIFX_OFS-1)*band_width+ofs_band,  cr,cg,cb,40);
        ptsB[2] = LineVertex(0,(data_midifx_len-MIDIFX_OFS)*band_width+ofs_band,cr,cg,cb,160);
        ptsB[3] = LineVertex(ww,(data_midifx_len-MIDIFX_OFS)*band_width+ofs_band, cr,cg,cb,160);
        
    }
	glLineWidth(2.0f);
	glDrawArrays(GL_LINES, 0, 4);
    
    glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisable(GL_BLEND);
	
	free(ptsB);
    
}