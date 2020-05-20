#include "ftnet2.bas"
#include "rnd256.bas"
#include "image.bas"
#include "file.bi"

#define IMGFolder "photos"
#define VALRatio .75
#define NETFile "ftnet2.dat"
#define Title "FTNet 2"

#define IMGSize 64 ' edge size of image

#define NETDepth 6
#define NETHash 123456
#define NETRate 0.0001!
#define NETSize 4*IMGSize*IMGSize

'
screenres 400,400,32
windowtitle(Title)
dim as ftnet net
dim as single work(NETSize)
if fileExists(NETFile) then
	print "Loading Network..."
	xfile.openfile(NETFile)
	net.load()
	xfile.closefile()
else
	print "Creating Network..."
	net.init(NETSize,NETDepth,NETRate,NETHash)
end if
print "Loading training images..."
dim as single images()
dim as ulong imgrecall=loadimages(IMGFolder,images(),IMGSize)
dim as ulong imgtrain=VALRatio*imgrecall
dim as ulong rcount
dim as ulongint iteration
	  
	  
dim as boolean training,recall
do
  var k=inkey()
  if cbool(k="t" or k="T") and not recall then  'bug in FB forces weird statement
    cls
    if training then
      xfile.openfile(NETFile)
      net.save()
      xfile.closefile()
    end if
    training=not training
  end if
  if cbool(k="r" or k="R") and not training then recall=not recall
  if k=chr(27) then exit do
  if (not training) and (not recall) then
   cls
   print "R to Recall. T to Train."
   sleep 300
  end if
  if training then
    for i as ulong=0 to imgtrain-1
      net.train(@images(i*NETSize),@images(i*NETSize))
	next
	iteration+=1
	if (iteration mod 25)=0 then
	  cls
	  print "Iterations:",iteration
	  dim as single sum
	  for i as ulong=0 to imgtrain-1
	    net.recall(@work(0),@images(i*NETSize))
	    sum+=errorl2(@work(0),@images(i*NETSize),NETSize)
	  next
	  print "Cost:",sum
	end if
  end if
  if recall then
    cls
    print "Recall",rcount,iif(rcount<imgtrain,"T set","Val set")
    net.recall(@work(0),@images(rcount*NETSize))
	presentimage(100,100,@work(0),IMGSize)
	rcount+=1
	if rcount=imgrecall then rcount=0
	sleep 2000
  end if
loop

