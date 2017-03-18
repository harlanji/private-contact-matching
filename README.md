# Bloom Friend Finder

## Overview

This project begins with a riddle.

Q: Why do we have to upload our address book to a server to be matched to our friends?

A: We don't.

## What's here?

* iOS Client
* Demo Node.js Server

## How do I use it?

1. `node index.js` will start a server on port `0.0.0.0:3000`. Be sure to create a DB table from `schema.sql` and configure it.

2. Add the files in `objc-src` to your project. Make sure `lib` gets copied with `bloom-filter.js` since it'll be loaded by the App at runtime.

3. Run the demo... clean method is to `#import "Demo.h"` and add the line `friendfinder_demo()` in your `didFinishLaunchingWithOptions`. You will probably change the API location--there may be a demo server available--see `Demo.m`:


## How does it work?

We use the ability of Bloom filters to remember if it has been shown a value without being able to recall the value itself. This optimization was originally to save space but we can use it for privacy. We use the data structure as a message format.

1. Create an empty Bloom Filter (A)
2. Iterate the address book, format each phone number and insert it into A
3. Transfer the data for A to the matching server with your id N.
4. The server stores it.
5. Create an empty Bloom Filter (B)
6. Iterate the known IDs on the server, format each number and insert it into B if it's contained in A
7. The server returns B to the client.
8. Iterate the address book and see if it is contained in B.
9. Items in the address book and B are probably matches!

Mutual matches are found when you make a request to another endpoint with just an ID

1. The client requests matches for an ID
2. Create an empty Bloom Filter (C)
3. Iterate all stored bloom filters, and see if it `contains` the ID
4. if the stored filter contains the ID then add it to C.
5. The server returns C to the client.

Each request is not much bigger than transferring the entire contents of the address book.

## Status, or what's left?

This was extremely hacked together over a couple of days... needs some cleanup. But concept is proven. 

1. Android version
2. Cleanup Bloom implementation -- currently hacked from the NPM module for use on both platforms and expand to Android.
