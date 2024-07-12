# Batcher

Batcher is a data batching API designed to distribute paged data across a specified number of forks for processing.

## Usage

Define a new class that derives from Batcher. The derivative needs to implement a few hooks Batcher depends on. Those hooks are to provide Batcher with the page size, total number of pages, the next page and a result processor.


A few hooks need to be implemented in the derived class in order for Batcher to work. Those hooks are - `page_count`, `page_next`, `page_size` and `process_result`.