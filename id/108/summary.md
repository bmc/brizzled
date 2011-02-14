In a collaborative [Rails][] development effort, we use [AuthLogic][] for
authentication, providing the typical [email activation][] capability that
pretty much everyone on the web uses these days. By default, the email is
routed through my client's email service. For local testing, though, I'd
rather just route those emails through my in-home local SMTP server. It's
faster, it's totally contained within my LAN, and it bypasses my main email
server's [greylisting][].

[Rails]: http://www.rubyonrails.org/
[AuthLogic]: https://github.com/binarylogic/authlogic
[email activation]: https://github.com/matthooks/authlogic-activation-tutorial
[greylisting]: http://greylisting.org/

