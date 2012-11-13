Basic gist of subscribing to a PubSubHubbub goes like this:

1. Fetch the Blog url
2. Look for blog's rss / atom feed
3. set this as hub.topic
4. Fetch blog feed URL
5. Look for rel="hub"
6. Post hub data (subscribe) to this URL, asynchronously
7. Listen for verification response
8. Echo back challenge
9. Ensure success
