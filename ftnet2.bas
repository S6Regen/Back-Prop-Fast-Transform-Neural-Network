#include "vecops12.bas"
#include "xfile.bas"
type ftnet
    veclen as ulongint
	depth as ulongint
	hash as ulongint
	rate as single
	parameters(any) as single
	values(any) as single
	errorvec(any) as single
    declare sub init(veclen as ulongint,depth as ulongint,rate as single, hash as ulongint)
    declare sub recall(resultvec as single ptr,invec as single ptr)
    declare sub train(targetvec as single ptr,invec as single ptr)
    declare sub sizememory()
    declare sub load()
    declare sub save()
end type

sub ftnet.init(veclen as ulongint,depth as ulongint,rate as single,hash as ulongint)
   this.veclen=veclen
   this.depth=depth
   this.hash=hash
   this.rate=rate
   sizememory()
   for i as ulongint=0 to ubound(parameters)
      parameters(i)=0.5!  'constant
   next
end sub

sub ftnet.sizememory()
    redim parameters(2*depth*veclen-1)
    redim values(depth*veclen-1)
    redim errorvec(veclen-1)
end sub

sub ftnet.recall(resultvec as single ptr,invec as single ptr)
	dim as single ptr params=@parameters(0),vs=@values(0)
	adjust(resultvec,invec,1!,veclen)
	hashflip(resultvec,resultvec,hash,veclen)	
	for i as ulongint=0 to depth-1
	   whtqscale(resultvec,2!,veclen)
	   copy(vs,resultvec,veclen):vs+=veclen
	   for j as ulongint=0 to veclen-1
	     dim as ulongint b=iif(resultvec[j]<0!,0,1)
	     resultvec[j]*=params[b]:params+=2
	   next
	next
	whtq(resultvec,veclen)
end sub

sub ftnet.train(targetvec as single ptr,invec as single ptr)
	dim as single ptr ev=@errorvec(0),params=@parameters(2*veclen*(depth-1))
	dim as single ptr vs=@values(veclen*(depth-1))
	recall(ev,invec)
	subtract(ev,targetvec,ev,veclen)
	scale(ev,ev,rate,veclen)
	for i as longint=depth-1 to 0 step -1
	  whtq(ev,veclen)
	  for j as ulongint=0 to veclen-1
	    dim as single v
	    dim as ulongint b
	    if vs[j]<0! then
	      v=-1!
	      b=0
	    else
	      v=1!
	      b=1
	    end if
	    params[j*2+b]+=v*ev[j]
	    ev[j]*=iif(params[j*2+b]<0!,-1!,1!)
	  next
	  params-=2*veclen
	  vs-=veclen
	next
end sub  
	    
sub ftnet.load()
   xfile.load(veclen)
   xfile.load(depth)
   xfile.load(hash)
   xfile.load(rate)
   sizememory()
   xfile.load(parameters())
end sub

sub ftnet.save()
   xfile.save(veclen)
   xfile.save(depth)
   xfile.save(hash)
   xfile.save(rate)
   xfile.save(parameters())
end sub
	
