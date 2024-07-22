# Batcher

Batcher is a base class that distributes dynamically sized batches of input data to forked child processes for parallel processing.

## Install

### CPAN/M

`# TODO`

### Manual

1. Clone the repository `git clone https://github.com/selftaught/Batcher.git`
2. Cd into the repo root and generate a makefile: `perl Makefile.pl`
3. Make it: `make && make test && make install`

## Usage

 Using Batcher is simple. Inherit Batcher in a subclass and then implement a few hooks that `Batcher::run` depends on.

- `batch_count()` - provides the total number of batchs
- `batch_next($next_idx)` - provides the next batch of data given the next index
- `batch_size()` - provides the number of items in a batch
- `batch_result($result)` - provides the next result to process

Browse [examples](./examples) for implementation examples.

## Performance

## Contributing

1. Fork the repository
2. Create feature branch (git checkout -b feature/adding-xyz)
3. Create PR to main when feature branch is ready for review

### Tests

### Publishing to CPAN

```sh
perl Makefile.PL && make dist && make clean
cpan-upload -u <PAUSEUSERNAME> Batcher-$VERSION.tar.gz
```

## Issues

If you're a mac user and encounter the following error:
`
objc[62121]: +[NSString initialize] may have been in progress in another thread when fork() was called.
`

you may need to disable initialize fork safey for this to work.
```sh
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
```
