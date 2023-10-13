# [Short Unique ID (UUID) Generating Library](https://www.npmjs.com/package/short-unique-id)
### rewrote with dart


Tiny no-dependency library for generating random or sequential UUID of any length
with exceptionally minuscule probabilities of duplicate IDs.

```dart
final uid = ShortUniqueId(SUIDicionaries.hex);
// or
final uid = ShortUniqueId.alphanum(length: 10);
// or
final uid = ShortUniqueId.custom(['a','b', 'c']);

uid.rnd() // p0ZoB1FwH6
uid.rnd() // mSjGCTfn8w
uid.rnd() // yt4Xx5nHMB
// ...

```

For example, using the default dictionary of numbers and letters (lower and upper case):

```
  0,1,2,3,4,5,6,7,8,9,
  a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,
  A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z
```

- if you generate a unique ID of 16 characters (half of the standard UUID of 32 characters)
- generating 100 unique IDs **per second**

#### It would take **~10 thousand years** to have a 1% probability of at least one collision!

To put this into perspective:

- 73 years is the (global) average life expectancy of a human being
- 120 years ago no human ever had set foot on either of the Earth's poles
- 480 years ago Nicolaus Copernicus was still working on his theory of the Earth revolving around the Sun
- 1000 years ago there was no such thing as government-issued paper money (and wouldn't be for about a century)
- 5000 years ago the global population of humans was under 50 million (right now Mexico has a population of 127 million)

You can calculate duplicate/collision probabilities using the included functions:

- [availableUUIDs()]()
- [approxMaxBeforeCollision()]()
- [collisionProbability()]()

