# Batcher

Batcher is a base class that abstracts away the code needed to divvy up a dataset into groupings of page numbers that then get handed off to forked child processes for for parallel processing.

Child processes fetch the data for the given page number through the `batch_next` hook that must be implemented.

## Usage

Create a new class that subclasses Batcher. The subclass needs to implement a few hooks Batcher depends on which provide the result page size, the total number of pages, the next page of results and a result processor:

- `batch_count()` - provides the total number of pages comprise the data set
- `batch_next($next_idx)` - provides the next page of data given the next index
- `batch_size()` - provides the number of items in a page
- `process_result($result)` - provides the next result to process

## Contributing

1. Fork the repository
2. Create feature branch (git checkout -b feature/adding-xyz)
3. Create PR to main when feature branch is ready for review

### Tests

### Publishing to CPAN

Prepare distribution
```sh
perl Makefile.PL && make dist && make clean
```

Upload
```sh
cpan-upload -u <PAUSEUSERNAME> Batcher-$VERSION.tar.gz
```