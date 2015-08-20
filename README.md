# camly

Simple one-to-one network chat in ocaml. Purpose being to investigate
the language and it's tools.

# Build

```
$ ./configure && make
```

# Run

```
$ ./echo.native
```

# Test

You can use netcat to test the echo. Just type something after running:

```
$ nc 127.0.0.1 8765
```
