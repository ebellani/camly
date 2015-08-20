# camly

Simple one-to-one network chat in ocaml. Purpose being to investigate
the language and it's tools.

# Build

```
$ ./configure && make
```

# Run

Start a server by running:

```
$ ./chat.native
```

Start a client by running:

```
$ ./chat.native -server false
```

Just type things in the terminal for each process. This should print
the text in the other side.
