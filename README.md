# Batcher

Batcher is a perl base class that defines a hook interface for processing results of a query or dataset in parallel using forks.

## Usage

Define a new class that derives from Batcher. The derivative needs to implement a few hooks Batcher depends on. They provide Batcher with the result page size, total number of pages, the next page of results and a result processor. Those hooks are as follows:

- `page_count()` - provides the total number of pages comprise the data set
- `page_next($next_idx)` - provides the next page of data given the next index
- `page_size()` - provides the number of items in a page
- `process_result($result)` - provides the next result to process

