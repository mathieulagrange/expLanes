
if (!Array.prototype.multiplyBy) {
    Array.prototype.multiplyBy = function(f) {
	var a = f; 
	if (!a.length) a = [a];
	var l = a.length;
	if (l>this.length) l = this.length;
	for (var i=0; i<l; i++) this[i] *= a[i];
	for (var i=l; i<this.length; i++) this[i] *= a[l-1];
    }
}

if (!Array.prototype.add) {
    Array.prototype.add = function(f) {
	var a = f; 
	if (!a.length) a = [a];
	var l = a.length;
	if (l>this.length) l = this.length;
	for (var i=0; i<l; i++) this[i] += a[i];
	for (var i=l; i<this.length; i++) this[i] += a[l-1];
    }
}

if (!Array.prototype.copy) {
    Array.prototype.copy = function() {
	var n = [];
	for (var i=0; i<this.length; i++) n[i] = this[i];
	return n;
    }
}



if (!Function.prototype.curry) {
    Function.prototype.curry = function() {
	if (arguments.length<1) return this;
	var __method = this;
	var args = Array.prototype.slice.call(arguments);
	return function() {
	    return __method.apply(this, args.concat(Array.prototype.slice.call(arguments)));
	}
    }
}

if (!Function.prototype.bind) {
    Function.prototype.bind = function(object) {
	var __method = this;
	return function() {
	    return __method.apply(object, arguments);
	}
    }
}

if (!Object.prototype.clone) {
    Object.prototype.clone = function () {
	var target = {};
	for (var i in this) {
	    if (this.hasOwnProperty(i)) {
		target[i] = this[i];
	    }
	}
	return target;
    }
}

if (!Object.prototype.inherit) {
    Object.prototype.inherit = function(baseConstructor) {
	this.prototype = baseConstructor.prototype.clone();
	this.prototype.constructor = this;
    };
}

if (!Date.now)
    Date.now = function now() {return new Date().getTime();}


function UserException (message) {
   this.message = message;
   this.name = "UserException";
}

// Defining a subclass, cheat sheet :

// function Subclass (sameParams) {
//     Superclass.call(this, sameParams);
//     this.otherStuff = "Hi there!";
// }
// Subclass.inherit(Superclass);

// Subclass.prototype.newFun = function () {
//     console.log(this.otherStuff);
// }

// Subclass.prototype.existingFun = function (sameParams) {
//     do_stuff();
//     Superclass.prototype.existingFun.call(this, sameParams); // if needed
//     do_stuff();
// }


function pageCoordinates (elem) {
    var res = {};
    res.x = 0;
    res.y = 0;
    if (elem.offsetParent) {
	do {
	    res.x += elem.offsetLeft;
	    res.y += elem.offsetTop;
        }while (elem = elem.offsetParent);
    }
    return res;
}

function preprocessEvent (e, dontBlock) {
    if (!e) e = window.event;
    if (typeof dontBlock == "undefined" || !dontBlock) {
	if (e.stopPropagation) e.stopPropagation();
	else e.cancelBubble = true;
	if (e.preventDefault) e.preventDefault();
    }
    if (!e.target) e.target = e.srcElement;
    if (e.target.nodeType == 3) // defeat Safari bug
	e.target = target.parentNode;
    return e;
}

function stopEvent (e) {
    if (e.stopPropagation) e.stopPropagation();
    else e.cancelBubble = true;
    if (e.preventDefault) e.preventDefault();
}

// Taken from MDN : create optimized versions of rapid-fire events, that are called at most once per redraw
;(function() {
    var throttle = function(type, name) {
        var running = false;
        var func = function() {
            if (running) { return; }
            running = true;
            requestAnimationFrame(function() {
                window.dispatchEvent(new CustomEvent(name));
                running = false;
            });
        };
        window.addEventListener(type, func);
    };
    throttle ("scroll", "optimizedScroll");
})();


// Web Audio stuff

function dBToAmp (db) {
    if (!db) return 1; // Silent fallback if db is undefined
    if (db<-79.9) return 0; 
    return Math.pow(10, db/20);
}

function noteToFreq (note) {
    return 440*Math.pow(2, (note-69)/12);
}

function smoothParameterChange (audioParam, nv, time, smooth) {
    if (typeof(smooth) == "undefined") smooth = .1;
    audioParam.cancelScheduledValues(time);
    audioParam.setValueAtTime(audioParam.value, time);
    audioParam.linearRampToValueAtTime(nv, time+smooth);
}

function anchorAudioParam (audioParam, time) {
    audioParam.cancelScheduledValues(time);
    audioParam.setValueAtTime(audioParam.value, time);
}

function circleAngle (centerX, centerY, pointX, pointY) {
    if (pointX == centerX) {
	if (pointY<centerY) return -Math.PI/2;
	else return Math.PI/2;
    }
    var tangent = (pointY-centerY)/(pointX-centerX);
    var angle = ((pointX >= centerX) ? Math.atan(tangent) : Math.PI+Math.atan(tangent));
    while (angle > Math.PI) angle -= 2*Math.PI;
    return angle;
}

function viewAngle (centerX, centerY, point1X, point1Y, point2X, point2Y) {
    var a1 = circleAngle(centerX, centerY, point1X, point1Y);
    var a2 = circleAngle(centerX, centerY, point2X, point2Y);
    var a = a2-a1;
    while (a > Math.PI) a-= 2*Math.PI;
    return a;
}

function lineSymmetry (xO, yO, xA, yA, xB, yB) {
    if (xA == xB)
	return [2*xA-xO, yO];
    if (yA == yB)
	return [xO, 2*yA-yO];
    var dx = xB-xA;
    var dy = yB-yA;
    var k2 = (xO-xA-(dx/dy)*(yO-yA))/(dy+dx*dx/dy);
    return [xO-2*k2*dy, yO+2*k2*dx];
}

function mod (a, b) {
    return ((a%b)+b)%b;
}

function preciseTimeout (f, dt, audioContext) {
    console.log(dt+" / "+audioContext.currentTime);
    var targetTime = dt/1000+audioContext.currentTime;
    setTimeout(function(t, f, ac) {
	setTimeout (f, 1000*(t-ac.currentTime));
    }.curry(targetTime, f, audioContext), 1000*(targetTime-audioContext.currentTime-.5));
}

hex = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'];

function rgbComponentsToHash (r, g, b) {
    var res = "#";
    r *= 255;
    g *= 255;
    b *= 255;
    res += hex[Math.floor(r/16)] + "" + hex[Math.floor(r%16)]
    res += hex[Math.floor(g/16)] + "" + hex[Math.floor(g%16)]
    res += hex[Math.floor(b/16)] + "" + hex[Math.floor(b%16)]
    return res;
}

function HslToRGB(h, s, l) {
    h = (h + 360) % 360;
    var hh = h/60;
    var c = s * (1 - Math.abs(2*l-1));
    var x = c * (1 - Math.abs((hh % 2) - 1));
    var m = l - c/2;
    switch (Math.floor(hh)) {
    case 0 : return [c+m, x+m, m];
    case 1 : return [x+m, c+m, m];
    case 2 : return [m, c+m, x+m];
    case 3 : return [m, x+m, c+m];
    case 4 : return [x+m, m, c+m];
    case 5 : return [c+m, m, x+m];
    }
}

function HslToHash (h, s, l) {
    var rgb = HslToRGB(h, s, l);
    return rgbComponentsToHash(rgb[0], rgb[1], rgb[2]);
}

function MersenneTwister (seed) {
    if (seed == undefined) {seed = new Date().getTime();} 
    /* Period parameters */  
    this.N = 624;
    this.M = 397;
    this.MATRIX_A = 0x9908b0df;   /* constant vector a */
    this.UPPER_MASK = 0x80000000; /* most significant w-r bits */
    this.LOWER_MASK = 0x7fffffff; /* least significant r bits */
    
    this.mt = new Array(this.N); /* the array for the state vector */
    this.mti=this.N+1; /* mti==N+1 means mt[N] is not initialized */

    this.init_genrand = function(s) {
	this.mt[0] = s >>> 0;
	for (this.mti=1; this.mti<this.N; this.mti++) {
	    var s = this.mt[this.mti-1] ^ (this.mt[this.mti-1] >>> 30);
	    this.mt[this.mti] = (((((s & 0xffff0000) >>> 16) * 1812433253) << 16) + (s & 0x0000ffff) * 1812433253) + this.mti;
	    this.mt[this.mti] >>>= 0;
	}
    }

    this.init_by_array = function(init_key, key_length) {
	this.init_genrand(19650218);
	var i=1, j=0, k = (this.N>key_length ? this.N : key_length);
	for (; k; k--) {
	    var s = this.mt[i-1] ^ (this.mt[i-1] >>> 30)
	    this.mt[i] = (this.mt[i] ^ (((((s & 0xffff0000) >>> 16) * 1664525) << 16) + ((s & 0x0000ffff) * 1664525)))
		+ init_key[j] + j; /* non linear */
	    this.mt[i] >>>= 0; /* for WORDSIZE > 32 machines */
	    i++; j++;
	    if (i>=this.N) { this.mt[0] = this.mt[this.N-1]; i=1; }
	    if (j>=key_length) j=0;
	}
	for (k=this.N-1; k; k--) {
	    var s = this.mt[i-1] ^ (this.mt[i-1] >>> 30);
	    this.mt[i] = (this.mt[i] ^ (((((s & 0xffff0000) >>> 16) * 1566083941) << 16) + (s & 0x0000ffff) * 1566083941))
		- i; /* non linear */
	    this.mt[i] >>>= 0; /* for WORDSIZE > 32 machines */
	    i++;
	    if (i>=this.N) { this.mt[0] = this.mt[this.N-1]; i=1; }
	}
	this.mt[0] = 0x80000000; /* MSB is 1; assuring non-zero initial array */ 
    }

    this.genrand_int32 = function() {
	var y, mag01 = new Array(0x0, this.MATRIX_A);

	if (this.mti >= this.N) { /* generate N words at one time */
	    var kk;
	    if (this.mti == this.N+1)   /* if init_genrand() has not been called, */
		this.init_genrand(5489); /* a default initial seed is used */
	    for (kk=0;kk<this.N-this.M;kk++) {
		y = (this.mt[kk]&this.UPPER_MASK)|(this.mt[kk+1]&this.LOWER_MASK);
		this.mt[kk] = this.mt[kk+this.M] ^ (y >>> 1) ^ mag01[y & 0x1];
	    }
	    for (;kk<this.N-1;kk++) {
		y = (this.mt[kk]&this.UPPER_MASK)|(this.mt[kk+1]&this.LOWER_MASK);
		this.mt[kk] = this.mt[kk+(this.M-this.N)] ^ (y >>> 1) ^ mag01[y & 0x1];
	    }
	    y = (this.mt[this.N-1]&this.UPPER_MASK)|(this.mt[0]&this.LOWER_MASK);
	    this.mt[this.N-1] = this.mt[this.M-1] ^ (y >>> 1) ^ mag01[y & 0x1];
	    
	    this.mti = 0;
	}
	y = this.mt[this.mti++];
	/* Tempering */
	y ^= (y >>> 11);
	y ^= (y << 7) & 0x9d2c5680;
	y ^= (y << 15) & 0xefc60000;
	y ^= (y >>> 18);
	return y >>> 0;
    }
 
    /* generates a random number on [0,0x7fffffff]-interval */
    this.randInt = function() {
	return (this.genrand_int32()>>>1);
    }

    /* generates a random number on [0,1)-real-interval */
    this.random = function() {
	return this.genrand_int32()*(1.0/4294967296.0); 
    }
    
    this.init_genrand(seed);
}  

function hannWindow (nP) {
    /*
     * This function calculates the Hanning
     * window coefficients
     * nP = number of window points (Even)
     */
    var wr = new Float32Array(nP);
    var nOn2 = nP/2;
    wr[0] = 0;
    wr[nOn2] = 2;
    for (var j=1; j<nOn2; j++) {
	wr[nOn2+j] = 1+Math.cos(Math.PI*j/nOn2);     // cos^2(n*pi/N) = 0.5+0.5*cos(n*2*pi/N)
	wr[nOn2-j] = wr[nOn2+j];
    }
    return wr;
}


function fft (ar, ai, ind) {
    /*=========================================
     * Calculate the floating point complex FFT
     * ind = +1 => FORWARD FFT
     * ind = -l => INVERSE FFT
     * Data is passed in nPair Complex pairs
     * where nPair is power of 2 (2^N)
     * data is indexed from 0 to nPair-1
     * Real data in ar
     * Imag data in ai.
     *
     * Output data is returned in the same arrays,
     * DC in bin 0, +ve freqs in bins 1..nPair/2
     * -ve freqs in nPair/2+1 .. nPair-1.
     *
     * ref: Rabiner & Gold
     * "THEORY AND APPLICATION OF DIGITAL
     *  SIGNAL PROCESSING" p367
     *
     * Translated to JavaScript by A.R.Collins
     * <http://www.arc.id.au>
     *========================================*/

    var nPair = ar.length;

    var Num1, Num2, i, j, k, L, m, Le, Le1,
        Tr, Ti, Ur, Ui, Xr, Xi, Wr, Wi, Ip;

    function isPwrOf2(n) {
	for (var p=2; p<20; p++)
            if (Math.pow(2,p) === n)
		return p;
	return -1;
    }

    m = isPwrOf2(nPair);
    if (m<0)
    {
      alert("nPair must be power of 2 from 4 to 4096");
      return;
    }

    Num1 = nPair-1;
    Num2 = nPair/2;
    // if IFT conjugate prior to transforming:
    if (ind < 0)
    {
      for(i = 0; i < nPair; i++)
      {
        ai[i] *= -1;
      }
    }

    j = 0;    // In place bit reversal of input data
    for(i = 0; i < Num1; i++)
    {
      if (i < j)
      {
        Tr = ar[j];
        Ti = ai[j];
        ar[j] = ar[i];
        ai[j] = ai[i];
        ar[i] = Tr;
        ai[i] = Ti;
      }
      k = Num2;
      while (k < j+1)
      {
        j = j-k;
        k = k/2;
      }
      j = j+k;
    }

    Le = 1;
    for(L = 1; L <= m; L++)
    {
      Le1 = Le;
      Le += Le;
      Ur = 1;
      Ui = 0;
      Wr = Math.cos(Math.PI/Le1);
      Wi = -Math.sin(Math.PI/Le1);
      for(j = 1; j <= Le1; j++)
      {
        for(i = j-1; i <= Num1; i += Le)
        {
          Ip = i+Le1;
          Tr = ar[Ip]*Ur-ai[Ip]*Ui;
          Ti = ar[Ip]*Ui+ai[Ip]*Ur;
          ar[Ip] = ar[i]-Tr;
          ai[Ip] = ai[i]-Ti;
          ar[i] = ar[i]+Tr;
          ai[i] = ai[i]+Ti;
        }
        Xr = Ur*Wr-Ui*Wi;
        Xi = Ur*Wi+Ui*Wr;
        Ur = Xr;
        Ui = Xi;
      }
    }
    // conjugate and normalise
    if(ind<0)
    {
      for(i=0; i<nPair; i++)
      {
        ai[i] *= -1;
      }
    }
    else
    {
      for(i=0; i<nPair; i++)
      {
        ar[i] /= nPair;
        ai[i] /= nPair;
      }
    }
  };

