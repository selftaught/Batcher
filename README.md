# Batcher

Batcher is a base class that abstracts away the code required to break up a dataset into pages and distribute those pages across a number of forks for parallel processing.

## Usage

Create a new class that subclasses Batcher. The subclass needs to implement a few hooks Batcher depends on which provide Batcher with the result page size, total number of pages, the next page of results and a result processor. Those hooks are as follows:

- `page_count()` - provides the total number of pages comprise the data set
- `page_next($next_idx)` - provides the next page of data given the next index
- `page_size()` - provides the number of items in a page
- `process_result($result)` - provides the next result to process

## Contributing

1. Fork the repository
2. Create feature branch (git checkout -b feature/adding-xyz)
3. Make some changes and commit them
4. Push changes to remote feature branch
5. Create PR to main when feature branch is ready for review

### Tests
### Publishing to CPAN

## License
