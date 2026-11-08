"use strict";
const guides=[
{id:"thirds",title:"Rule of Thirds",description:"Bring balance to the ordinary. Position subjects along intersections and let the composition breathe."},
{id:"goldenGrid",title:"Golden Ratio",description:"Find the natural proportions that make a frame feel effortless. Discover balance that draws the eye."},
{id:"goldenSpiral",title:"Golden Spiral",description:"Create a visual journey. Let curves, subjects and spaces lead the viewer through your photograph."},
{id:"center",title:"Center Cross",description:"Embrace symmetry. Give your subject an unmistakable point of focus."},
{id:"diagonal",title:"Diagonal Guides",description:"Add energy and intention. Use diagonal movement to give still scenes a sense of life."},
{id:"square",title:"Square Grid",description:"Build structure. Compare spacing and repetition at a glance."},
{id:"horizon",title:"Horizon Level",description:"Bring the world into alignment. Perfect for seascapes, skylines, and open roads."},
{id:"eyeLine",title:"Portrait Eye Line",description:"Create expressive portraits by thoughtfully positioning your subject's eyes."},
{id:"safeArea",title:"Social Safe Area",description:"Compose for the crop. Keep the important parts of the frame where they belong."},
{id:"perspective",title:"Perspective Lines",description:"Find the vanishing point and let architecture, roads and leading lines tell a story."},
{id:"cinematic",title:"Cinematic Frame",description:"Think widescreen. Explore mood and narrative through a cinematic frame."},
{id:"custom",title:"Custom Grid",description:"No rules but yours. Customize the number of grid rows and columns."},
{id:"leadingLines",title:"Leading Lines",description:"Manually position a vanishing point and follow the converging guides toward your subject."},
{id:"reflection",title:"Symmetry & Reflection",description:"Choose a vertical or horizontal axis for architecture, mirrors and water reflections."},
{id:"goldenTriangle",title:"Golden Triangle",description:"Find dynamic balance across an elegant diagonal and two supporting divisions."},
{id:"frameWithinFrame",title:"Frame Within Frame",description:"Adjust an inner frame to compose through doorways, arches and windows."},
{id:"negativeSpace",title:"Negative Space",description:"Position your subject, then leave intentional breathing room in the direction it faces."},
{id:"sCurve",title:"S-Curve",description:"Follow the natural flow of winding roads, rivers and walking paths."}
];
const prefersReduced=window.matchMedia("(prefers-reduced-motion: reduce)").matches;
const guideTitle=document.querySelector("#guide-title"),guideDescription=document.querySelector("#guide-description");
const guideIndex=document.querySelector("#guide-index"),guideImage=document.querySelector("#guide-image"),guideDevice=document.querySelector("#guide-device");
let activeGuide="thirds",pending=null;
const imageCache=new Map();
guides.forEach(g=>{const img=new Image();img.src="./screenshots/overlay-"+g.id+".png";imageCache.set(g.id,img)});
function chooseGuide(id){
  const idx=guides.findIndex(g=>g.id===id);if(idx<0)return;
  activeGuide=id;const guide=guides[idx];
  document.querySelectorAll("[data-guide]").forEach(b=>{const selected=b.dataset.guide===id;b.classList.toggle("is-active",selected);b.setAttribute("aria-pressed",String(selected))});
  guideIndex.textContent=String(idx+1).padStart(2,"0");
  guideTitle.textContent=guide.title;guideDescription.textContent=guide.description;
  if(pending)clearTimeout(pending);
  if(!prefersReduced)guideDevice.classList.add("is-switching");
  pending=window.setTimeout(()=>{
    guideImage.src=imageCache.get(id)?.src||"./screenshots/overlay-"+id+".png";
    guideImage.alt=guide.title+" composition guide in the actual Asperito iPhone Simulator app";
    guideDevice.classList.remove("is-switching");
  },prefersReduced?0:150);
}
document.querySelectorAll("[data-guide]").forEach(b=>b.addEventListener("click",()=>chooseGuide(b.dataset.guide)));
chooseGuide(activeGuide);
const nav=document.querySelector(".site-nav");
window.addEventListener("scroll",()=>nav.classList.toggle("is-scrolled",window.scrollY>40),{passive:true});
const observer=window.IntersectionObserver&&!prefersReduced?new IntersectionObserver(entries=>{entries.forEach(e=>{if(e.isIntersecting){e.target.classList.add("is-visible");observer.unobserve(e.target)}})},{threshold:.12,rootMargin:"0px 0px -35px 0px"}):null;
document.querySelectorAll(".observe").forEach(e=>{if(observer)observer.observe(e);else e.classList.add("is-visible")});
const carousel=document.querySelector("#screen-carousel");
for(const [id,direction] of [["screens-prev",-1],["screens-next",1]]){
  const button=document.getElementById(id);
  button?.addEventListener("click",()=>carousel.scrollBy({left:direction*300,behavior:prefersReduced?"instant":"smooth"}));
}
carousel?.addEventListener("keydown",event=>{if(!["ArrowRight","ArrowLeft"].includes(event.key))return;event.preventDefault();carousel.scrollBy({left:(event.key==="ArrowRight"?1:-1)*300,behavior:prefersReduced?"instant":"smooth"})});
document.querySelector("#year").textContent=String(new Date().getFullYear());


// The gesture sequence is an honest, stylized SVG explanation. The underlying
// screenshot stays fixed; only the translucent guide and finger markers move.
// No attempt is made to simulate the actual iOS multitouch recognizer in a browser.
const gestureSection=document.querySelector("#gesture");
const replayButton=document.querySelector("#gesture-replay");
const pauseButton=document.querySelector("#gesture-pause");
const gestureAngle=document.querySelector("#gesture-angle");
const gestureStatus=document.querySelector("#gesture-status");
let gesturePaused=prefersReduced;
let gestureFrame=null;
let gestureStart=null;
let gestureElapsed=0;
const gestureDuration=5200;
function gestureTick(timestamp){
  if(!gestureSection||gesturePaused)return;
  if(gestureStart===null)gestureStart=timestamp;
  gestureElapsed=(timestamp-gestureStart)%gestureDuration;
  const fraction=gestureElapsed/gestureDuration;
  // Match the CSS motion: 0° hold, turn to 58°, then hold the final position.
  const p=fraction<.14?0:fraction>.67?1:(fraction-.14)/.53;
  const eased=p<.5?4*p*p*p:1-Math.pow(-2*p+2,3)/2;
  gestureAngle.textContent=Math.round(eased*58)+"°";
  gestureStatus.textContent=fraction>.72?"ANGLE SAVED FOR THIS GUIDE":"TWO-FINGER ROTATION";
  gestureFrame=requestAnimationFrame(gestureTick);
}
function beginGesture(){
  if(!gestureSection)return;
  if(gestureFrame!==null)cancelAnimationFrame(gestureFrame);
  gestureFrame=null;
  gestureStart=null;
  gestureElapsed=0;
  gestureAngle.textContent="0°";
  gestureStatus.textContent="TWO-FINGER ROTATION";
  gestureSection.classList.remove("gesture-active");
  // Reflow deliberately restarts the matching SVG/CSS keyframe animation.
  void gestureSection.offsetWidth;
  if(!gesturePaused){
    gestureSection.classList.add("gesture-active");
    gestureFrame=requestAnimationFrame(gestureTick);
  }
}
function toggleGesturePause(paused){
  gesturePaused=paused;
  gestureSection?.classList.toggle("gesture-paused",paused);
  pauseButton?.setAttribute("aria-pressed",String(paused));
  if(pauseButton)pauseButton.textContent=paused?"Play animation":"Pause animation";
  if(paused){
    if(gestureFrame!==null)cancelAnimationFrame(gestureFrame);
    gestureFrame=null;
  }else beginGesture();
}
replayButton?.addEventListener("click",()=>{
  if(gesturePaused)toggleGesturePause(false);
  else beginGesture();
});
pauseButton?.addEventListener("click",()=>toggleGesturePause(!gesturePaused));
if(gestureSection){
  if(prefersReduced){
    gestureSection.classList.add("gesture-reduced");
    gestureAngle.textContent="58°";
    gestureStatus.textContent="GUIDE ORIENTATION SAVED";
    toggleGesturePause(true);
  }else{
    const gestureObserver=new IntersectionObserver(entries=>{
      const visible=entries.some(e=>e.isIntersecting);
      if(visible&&!gesturePaused&&!gestureSection.classList.contains("gesture-active"))beginGesture();
      if(!visible){
        if(gestureFrame!==null)cancelAnimationFrame(gestureFrame);
        gestureFrame=null;
        gestureSection.classList.remove("gesture-active");
        gestureStart=null;
      }
    },{threshold:.12});
    gestureObserver.observe(gestureSection);
  }
}
