# Batcher

Batcher is a data batching module designed to distribute paged data across a specified number of forks for parallel processing.

## Usage

Define a new class that derives from Batcher. The derivative needs to implement a few hooks Batcher depends on. They let you provide Batcher with the page size, total number of pages, the next page and a result processor. Those hooks are - `page_count`, `page_next`, `page_size` and `process_result`.