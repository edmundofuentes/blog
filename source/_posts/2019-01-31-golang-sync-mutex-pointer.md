---
title: Enabling NTP Time Synchronization in Ubuntu 18.04
tags:
    - golang
    - concurrency
categories:
    - golang
draft: yes
---



Running production code, one day at random under an abnormally high system load one of our main services panicked.
 
```
fatal error: concurrent map read and map write
```


Testing for race conditions is _very_ important.

We audited our code a lot by ______

and we fully __ employ__ the appropiate `mutex.Lock()` and `mutex.Unlock()` whenever a concurrent map read 
or write could be expected.


Our main struct ..

```golang
type Server struct {
    m       map[int]string
    mutex   sync.Mutex
}
```

```golang
func (server *Server) Worker(feed <-chan interface{}) {
    for {
        job := <-feed
        
        server.mutex.Lock()
        // execute processJob()
        // operates on the server.m map
        // ...
        // ...
        server.mutex.Unlock()
    }
}
```

Can you spot the error?

The error was that in our `Server` struct we were declaring the `mutex` field as a value, not a pointer.

The actual implementation of the `sync.Mutex.Lock()` method is a _pointer receiver_ [`func (m *Mutex) Lock()`] in order to be able to modify the mutex's internal atomic lock state. This means that when Go executes the call on a _value_ such as our `server.mutex`, it is actually calling `(&server.mutex).Lock()` as a convenience for the programmer.

Even thought we are operating on a Server pointer reference inside the `Worker()` method, we would get a _copy_ of the actual mutex when accessing through `server.mutex`.  <-- WHY?!?!

Every time we called, we are referencing the Server instance as a _copy_, which means that we were also getting a new copy of the mutex. However, maps are references (pointers) by default, so we would get a brand new copy of the mutex and the actual unique map.

This means that we were correctly locking and unlocking _a_ mutex, but each worker was operating on _its own copy_ of a mutex, negating the intended purpose of protecting the map from concurrent access.

In our tests we didn't catch any instance of this race condition, but with a high load on our service and enough time we eventually got this panic.


Therefore, in this case the correct `Server` struct declaration should be:
```golang
type Server struct {
    m       map[int]string
    mutex   &sync.Mutex // <- pointer!
}
```


Also, don't forget to always initialize pointers:

```golang
mutex := &sync.Mutex{}
```

Or with the older convention, which I personally find cleaner and more explicit.

```golang
mutex := new(sync.Mutex)
```


References:
- https://gobyexample.com/mutexes
- https://golang.org/pkg/sync/#Mutex