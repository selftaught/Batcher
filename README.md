# Batcher

Batcher is a base class that implements forking to distribute pages of results for parallel processing across multiple processes. Occassionally, I have to iterate a large dataset and perform actions on resources that can take seconds to perform sometimes. Most of the systems I develop and contribute to are developed in perl and dont allow for installing 3rd party modules very easily in production environments.

## Usage

Define a new class that derives from Batcher. The derivative needs to implement a few hooks Batcher depends on. They let you provide Batcher with the page size, total number of pages, the next page and a result processor. Those hooks are -

- `page_count()` - return the total number of pages comprise the data set
- `page_next($next_idx)` - return the next page of data given the next index
- `page_size()` - return the number of items in a page
- `process_result($result)` - process the next result
