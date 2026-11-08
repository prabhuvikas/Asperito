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


// Real Simulator screen recording; no fabricated web overlay or rotated SVG.
// The video includes Asperito's native camera chrome, teaching controls, and
// animated SwiftUI composition guide. Browser controls manage playback only.
const gestureSection=document.querySelector("#gesture");
const gestureVideo=document.querySelector("#gesture-video");
const replayButton=document.querySelector("#gesture-replay");
const pauseButton=document.querySelector("#gesture-pause");
function setGesturePlayback(playing){
  if(!gestureVideo)return;
  pauseButton?.setAttribute("aria-pressed",String(!playing));
  if(pauseButton)pauseButton.textContent=playing?"Pause animation":"Play animation";
  if(playing){
    const result=gestureVideo.play();
    if(result&&typeof result.catch==="function"){
      result.catch(()=>{pauseButton?.setAttribute("aria-pressed","true");if(pauseButton)pauseButton.textContent="Play animation"});
    }
  }else gestureVideo.pause();
}
replayButton?.addEventListener("click",()=>{
  if(!gestureVideo)return;
  gestureVideo.currentTime=0;
  setGesturePlayback(true);
});
pauseButton?.addEventListener("click",()=>setGesturePlayback(gestureVideo.paused));
if(gestureVideo){
  if(prefersReduced){
    setGesturePlayback(false);
  }else if("IntersectionObserver" in window){
    const obs=new IntersectionObserver(entries=>{
      if(entries.some(entry=>entry.isIntersecting))setGesturePlayback(true);
      else setGesturePlayback(false);
    },{threshold:0.15});
    obs.observe(gestureSection);
  }else setGesturePlayback(true);
}
