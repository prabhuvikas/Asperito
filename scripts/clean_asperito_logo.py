#!/usr/bin/env python3
"""Clean only unwanted background speckles from the original director logo.

The original artwork is retained as branding/asperito-original.jpg. This is a
repeatable, non-generative operation and preserves internal gold details.
"""
from pathlib import Path
import numpy as np
from PIL import Image

ROOT=Path(__file__).resolve().parents[1]
source=ROOT/"branding/asperito-original.jpg"
img=np.asarray(Image.open(source).convert("RGB")).copy()
height,width=img.shape[:2]
if width!=1254 or height!=1254:
    raise ValueError(f"Unexpected logo dimensions: {width}x{height}")
r,g,b=[img[:,:,k].astype(np.int16) for k in range(3)]
# Recognize the main gold perimeter, never the stray saturated red pixels.
gold=(r>140)&(g>100)&(g>b+34)&(r<g*1.9)
result=img.copy()
result[:40,:,:]=0
result[1223:,:,:]=0
for y in range(40,1223):
    left_edges=[]
    right_edges=[]
    for row in range(max(40,y-2),min(1222,y+2)+1):
        xx=np.flatnonzero(gold[row])
        if xx.size:
            left_edges.append(int(xx[0]))
            right_edges.append(int(xx[-1]))
    if not left_edges: result[y,:,:]=0;continue
    lo=max(0,int(np.median(left_edges))-1)
    hi=min(width-1,int(np.median(right_edges))+1)
    result[y,:lo,:]=0
    result[y,hi+1:,:]=0
    # Remove bright red JPEG edge halos near the icon outline only.
    for start,end in [(max(0,lo-3),min(width,lo+8)),
                      (max(0,hi-7),min(width,hi+4))]:
        c=result[y,start:end,:].astype(np.int16)
        bad=(c[:,0]>95)&(c[:,0]>c[:,1]*1.55)&(c[:,1]<115)&(c[:,0]>c[:,2]*1.35)
        result[y,start:end,:][bad]=0
ys,xs=np.indices((height,width))
perimeter=(xs<110)|(xs>1135)|(ys<110)|(ys>1150)
c=result.astype(np.int16)
red_fringe=perimeter&(c[:,:,0]>110)&(c[:,:,1]<125)&(c[:,:,0]>c[:,:,1]*1.5)&(c[:,:,0]>c[:,:,2]*1.25)
result[red_fringe]=0
clean=Image.fromarray(result,"RGB")
app=ROOT/"FrameGuide/Assets.xcassets"
app_png=app/"AppIcon.appiconset/icon.png"
app_jpeg=app/"DirectorLogo.imageset/director.jpg"
site=ROOT/"docs"
clean.resize((1024,1024),Image.Resampling.LANCZOS).save(app_png,optimize=True)
clean.save(app_jpeg,quality=95,subsampling=0,optimize=True)
clean.save(site/"director.jpg",quality=95,subsampling=0,optimize=True)
clean.save(site/"asperito-logo.png",optimize=True)
clean.resize((96,96),Image.Resampling.LANCZOS).save(site/"asperito-favicon.png",optimize=True)
assert Image.open(app_png).size==(1024,1024)
assert Image.open(site/"asperito-logo.png").size==(1254,1254)
assert (np.array(clean)[:20,:,:] == 0).all()
assert (np.array(clean)[-20:,:,:] == 0).all()
print("Prepared clean Asperito logo for app icon, onboarding, website and favicon.")
