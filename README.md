# Batcher

Batcher is a perl base class that provides a hook interface for processing results of a query or dataset in parallel via forks.

## Usage

Define a new class that derives from Batcher. The derivative needs to implement a few hooks Batcher depends on. They let you provide Batcher with the page size, total number of pages, the next page and a result processor. Those hooks are -

- `page_count()` - return the total number of pages comprise the data set
- `page_next($next_idx)` - return the next page of data given the next index
- `page_size()` - return the number of items in a page
- `process_result($result)` - process the next result

