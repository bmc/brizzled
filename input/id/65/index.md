template: article.html
title: Error Message of the Day
tags: software, oracle
date: 2007-07-12

I'm looking into an issue with Oracle's text search capability. (We use it
in our product, when running against Oracle.) I was manually experimenting
with a different form of a query, and I got this beauty of an error
message:

    Error code 29908, SQL state 99999: ORA-29908: missing primary invocation for ancillary operator

Yay.

That's a nearly perfect example of a terrible error message. I know what
every single word in that message means, but put them together like that,
and it might as well be [an alien language][].

[an alien language]: http://www.kli.org/
