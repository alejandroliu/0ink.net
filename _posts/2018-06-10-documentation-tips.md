---
ID: "1075"
post_author: "2"
post_date: "2017-03-24 11:00:44"
post_date_gmt: "0000-00-00 00:00:00"
post_title: Documentation tips
post_excerpt: ""
post_status: draft
comment_status: open
ping_status: open
post_password: ""
post_name: ""
to_ping: ""
pinged: ""
post_modified: "2017-03-24 11:00:44"
post_modified_gmt: "2017-03-24 11:00:44"
post_content_filtered: ""
post_parent: "0"
guid: https://0ink.net/?p=1075
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: 10 tips for maiking documentation crystal clear
---

So you've some written excellent documentation. Now what? Now it's
time to go back and edit it. When you first sit down to write your
documentation, you want to focus on what you're trying to say instead
of how you're saying it, but once that first draft is done it's time
to go back and polish it up a little.

One of my favorite ways to edit is to read what I've written aloud.
That's the best way to catch awkward phrasing or sentence structure
that might not stand out when you're reading it to yourself. If it
sounds good when you read it aloud, it probably is. If your
documentation happens to include instructions, you can watch someone
try to follow them. This provides good feedback on what steps are
missing or unclear, particularly if the person is unfamiliar with the
subject.

## Active vs. passive voice

You should prefer the active voice in most cases. It's okay to be
direct. How do you check for passive voice? Insert the words
"by zombies". For example, it is much clearer to say
"If you click 'yes', you will delete your data" instead of "If you
click 'yes', data will be deleted." Apply the zombie test to these two
examples:

* "If you click 'yes', you will delete your data by zombies."
* "If you click 'yes', data will be deleted by zombies."

In the first example there is no doubt that you are the actor. The
second example shows that there is room for misinterpretation. Make it
very clear what actors perform actions.

## Eliminate jargon

Some jargon terms are unavoidable, but for the sake of clarity you
should avoid them as much as possible. Linking to the definition of a
term the first time you use it is acceptable, and you should also
write your own brief definition. You don't want to rely on the
availability of external sites, or make your readers jump through too
many hoops to understand your documentation.

## Check for common mistakes

Question everything you think you know, and take advantage of having
the world at your fingertips and look up everything. For example,
"e.g." means "for example" and "i.e." means "in other words".
"Effect" is a noun (except when it isn't, as the
[comic xkcd demonstrates](https://xkcd.com/326/)), and "affect" is a
verb. Use "which" when a clause can be removed from the sentence
without a change in meaning, and "that" when it cannot.

## Remove dangling modifiers

You have created a dangling modifier when it is unclear which object
is being modified by a word or phrase. A classic example is "Hungry,
the leftover food was devoured". Is Hungry the name of the food? Add
a comma after "food" if that is your meaning. If not, rewrite it to
make your meaning unambiguous: "Your author was hungry and devoured
the leftover food." Organize your sentences carefully; don't force your
readers to guess your meaning.

## Check your style guide

If your project or company has a style guide for documentation, check
that what you've written conforms to it. One common mistake is the
inappropriate abbreviation of company and project names.

## Avoid unclear words

Do you know how many times I deleted words like "often" and "some"
while writing this article? I don't know exactly how many, but I know
it's a non-zero number. Use words with specific meanings. This is
particularly important when you're trying to convince your reader that
what you're telling them is important. If I say "Following these tips
will make your writing better", that's less convincing than "Following
these tips will increase financial contributions to your project by
45%." If you catch yourself using vague words, ask yourself if you
really understand your topic, or if perhaps you're trying to hide
something.

## Check the word order

The English language does not have a formally-defined ordering
structure for modifying nouns, but there is an informal structure
which is described in this [Tweet by Matthew Anderson](https://twitter.com/MattAndersonNYT/status/772002757222002688):
Opinion-size-age-shape-color-origin-material-purpose Noun. It's
something native English speakers know, but don't know we know. Peter
Sokolowski replied with advice to [Put the "nounier" words closer to the noun](https://twitter.com/PeterSokolowski/status/773186018317131776).
If that doesn't help you read the discussion to his reply, which has
numerous examples and explanations.

## Remove words like "just" and "simply"

Technology is not as simple as we like to pretend it is. If you tell
your readers that something is simple and then they can't do it, what
are they to think of themselves? Unless you're writing an infomercial
for the latest must-have kitchen gadget, leave out those words.

## Check your pronouns

When you say "we", who do you really mean? I have seen documentation
written in what I call "cooking show style", where "Next we click the
whatchamadoozit to fribble the wozulator." When you're writing in a
support context it is especially important to be clear who does what.
If you tell someone "We can change that setting", they expect that
you will do it for them, and not that they can do it with your
guidance. As a general rule, I avoid using first person (I/we) except
when I am talking about myself as the author or the organization I am
representing. When in doubt, refer to yourself in the third person
(e.g. "The author suggests you refer to yourself in the third person").
It might sound overly formal, but it is clear.

## Remove split infinitives

Don't put words in between "to" and a verb. Your documentation is on
a mission to go boldly where no docs have done before. (Starship
captains are excused from this rule).


Reference: [opensource life](https://opensource.com/life/16/11/tips-for-clear-documentation)




