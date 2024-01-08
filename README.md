# twitter-analysis
this repo uses powershell to transform your twitter data dump into a more useful dataset.

## usage
extract.ps1 tweets.js

this command prunes superfluous fields from your data dump, builds an associative array of tweets, and then writes that new dataset to review.json. only three fields from tweets.js are preserved (noted below).

## fields filtered
- id: passthrough from tweets.js
- created: this is the `created_at` field
- text: this is the `full_text` field

## example
in my case, tweets.js was 25.4 MB (for an archive with 15,418 tweets).

> Processing tweets.js...
> Records: 15418
> Streamlined 15418 tweets with 1729592 bytes of content into review.json.

review.json was trimmed down to 8.8 MB by throwing away metadata that doesn't matter that much

note that my actual tweets are only 1.7 MB, so there's still a fair amount of json bloat to squeeze out. i plan to do that with a phext conversion step in the near future. stay tuned in!

--will