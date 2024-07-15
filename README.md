# Batcher

Batcher is a base class that abstracts away the code needed to divvy up a dataset into groupings of batch numbers that then get handed off to forked child processes for for parallel processing.

## Install

## Usage

Create a new class that subclasses Batcher. The subclass needs to implement a few hooks Batcher `run` depends on. `run` depends on you overriding the hook to provide the result batch size, the total number of batchs, the next batch of results and a result processor which every result is passed to.

- `batch_count()` - provides the total number of batchs
- `batch_next($next_idx)` - provides the next batch of data given the next index
- `batch_size()` - provides the number of items in a batch
- `process_result($result)` - provides the next result to process

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