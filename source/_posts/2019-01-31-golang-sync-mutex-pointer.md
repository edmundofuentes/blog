---
title: Enabling NTP Time Synchronization in Ubuntu 18.04
tags:
    - golang
    - concurrency
categories:
    - golang
draft: yes
---



Running production code, one day at random under a small system load

one of our main servers panicked.
 
```
fatal error: concurrent map read and map write
```


Testing for race conditions is _very_ important.

We audited our code a lot by ______

the appropiate `mutex.Lock()` and `mutex.Unlock()` whenever a concurrent map read 
or write was expected.

Our main struct ..

```golang
type Server struct {
    m       map[int]string
    mutex   sync.Mutex
}
```

```golang
func (server *Server) Worker() {
    for {
        job := <-feed
        
        server.mutex.Lock()
        processJob() // operates on the server.m map
        server.mutex.Unlock()
    }
}
```

Can you spot the error?

The correct declaration

Since it was a _pointer_ declaration not a 


You can initialize a 

```golang
mutex := &sync.Mutex{}
```

or with the older convention, which I personally find cleaner.

```golang
mutex := new(sync.Mutex)
```


References:
- https://gobyexample.com/mutexes
- https://golang.org/pkg/sync/#Mutex