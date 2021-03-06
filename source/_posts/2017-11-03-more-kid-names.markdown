---
layout: post
title: 'Seriously, who names their kid "Aragorn?"'
date: 2017-11-03 19:45
comments: true
categories: [data,naming]
---

As noted in a [prior post](/blog/2016/12/29/tammy/),
I happen to have 
[first name popularity data from the Social Security Administration](https://www.ssa.gov/OACT/babynames/limits.html)
lying around. (In my job at [Databricks](https://databricks.com/), we
sometimes use that data in demos and training curriculum.)

While chatting idly with a co-worker, about the names people choose for their
children, it occurred to me to search for a particular _set_ of first names,
specifically, names from J.R.R. Tolkien's _Lord of the Rings_.

Was anyone _so_ enamored with the books, and the Peter Jackson movies, that
they chose to name their kids after Middle Earth characters?

I think you already know the answer to that question.

<!-- more -->

The data includes first names and the number of people with that first name,
divided by year, as recorded by the United States Social Security
Administration (SSA). It covers the years 1880 through 2016. For privacy
reasons, The SSA only includes first names that occur at least five times in a
year.

So, without further ado, let's start with:

## The Fellowship

There are no **Frodos**, **Boromirs**, **Gimlis**, or **Meriadocs** at all.

There _are_ some **Pippins**, but, until 2016 they're all girls; it's probably
fair to assume the girls are _not_ named after
[Master Peregrin Took](https://en.wikipedia.org/wiki/Peregrin_Took). However,
5 boys named Pippin were born in 2016. I also found more than a few boys named
**Peregrin**, not to be confused with the differently-spelled 
[Peregrine falcon](https://en.wikipedia.org/wiki/Peregrine_falcon).

{% imgpopup /images/2017-11-03-more-kid-names/peregrin.png 75% Peregrin-Pippin %}

There are more than a few **Aragorns**. _(Seriously?)_

{% imgpopup /images/2017-11-03-more-kid-names/aragorn.png 75% Aragorn %}

And, a few parents saw fit to name their sons **Samwise**.

{% imgpopup /images/2017-11-03-more-kid-names/samwise.png 75% Samwise %}

Perhaps more surprising is that there were 7 boys born in 2003 and 6 boys born
in 2015 whose parents chose to name them **Legolas**.

{% imgpopup /images/2017-11-03-more-kid-names/legolas.png 75% Legolas %}

The boys born in 2003 would be about 14 now. I hope they're surviving
adolescence okay.

And, of course, there's **Gandalf**. No one would name his son Gandalf,
right? 

_Wrong_. The parents of 5 boys born in 1970 chose Gandalf as the perfect name
for their little boys. At least no one chose **Mithrandir**.

## Bilbo

Old Bilbo kicked the whole thing off, really. So, what about him?

Oddly, there are quite a few people named Bilbo. All were born before _LOTR_
was published.

{% imgpopup /images/2017-11-03-more-kid-names/bilbo.png 75% Bilbo %}

## Other elves

**Galadriel** charmed the parents of baby girls throughout the years:

{% imgpopup /images/2017-11-03-more-kid-names/galadriel.png 75% Galadriel %}

**Arwen** has had a nice long run as a girl's name, as well.

{% imgpopup /images/2017-11-03-more-kid-names/arwen.png 50% Arwen %}

Unsurprisingly, no one opted for **Celeborn**. (Or, if they did, the kid never
got a Social Security card.)

I half-expected at least a _few_ people to name their boys **Elrond**, but
that name didn't show up, either.

## Rohan and Gondor

I found no people named **Éomer** or **Théodred**, and, no surprise, none
called **Gríma**. But **Éowyn** rivals Galadriel and Arwen:

{% imgpopup /images/2017-11-03-more-kid-names/eowyn.png 75% Éowyn %}

And there are a few young boys in the United States named **Théoden**:

{% imgpopup /images/2017-11-03-more-kid-names/theoden.png 75% Théoden %}

(Is "Ted" a legitimate nickname for Théoden?)

**Faramir** seems like a nice honorable name, doesn't it? No one chose that
one, either. **Denethor** is also missing, which is probably a good thing.

## Anyone else?

Before you ask, no, no one who got a Social Security card was cursed with the
name **Sauron** or **Saruman**, at least not up to 2014. And there are no
**Radagasts**, **Gollums** or **Smeagols**, either. (I was _really_ hoping to
find a few Radagasts.)

## _The Hobbit_

For the hell of it, I threw in the Dwarves from _The Hobbit_, **Fili**,
**Kili**, **Oin**, **Gloin**, **Bifur**, **Bofur**, **Bombur**, **Dori**,
**Nori**, **Dwalin**, **Balin**, **Dain**, **Nain**, **Thorin**. Of course,
it's entirely possible that parents chose names like Bain and Dain for other
reasons.

{% imgpopup /images/2017-11-03-more-kid-names/hobbit-1.png 50% Dwarves %}

I got hits for Dain, Nain, Nori, Fili, Kili, Balin and Thorin.

I dropped out the names that are legitimate first names in cultures outside
the United States:

* Dain (Latvia and Lithuania)
* Balin (India, from Hindi)
* Nori (Japan)

That left Nain, Fili, Kili and Thorin.

{% imgpopup /images/2017-11-03-more-kid-names/hobbit-2.png 50% Dwarves %}

I found graphing Fili and Kili together to be... well, a little strange,
frankly.

{% imgpopup /images/2017-11-03-more-kid-names/fili-kili.png 50% Fili-Kili %}

But, check out all the Thorins! 

{% imgpopup /images/2017-11-03-more-kid-names/thorin.png 50% Thorin %}

There were 5 boys named Thorin born in 1968; they'd be just shy of 50 now.
Meanwhile, 114 Thorins were born in 2014, 156 were born in 2015, and 136 were
born in 2016. **That's 406 Thorins in just three years.** Who _does_ this?

I guarantee at least one joker gave some young Thorin an oaken shield—or,
even better, a log—as a first birthday present.

## Conclusion

I really cannot think of a conclusion to this silly exercise, other than to
make a humble request: If you're one of the 47-year-old Gandalfs born in 1970,
send a photo, man.

## Notes

I performed this analysis using
[Apache Spark 2.2](https://spark.apache.org), on
[Databricks Community Edition](https://community.cloud.databricks.com/).
You can create your own _free_ Community Edition account at
<https://databricks.com/ce>.

If you want to play with this data yourself, I have a Databricks notebook that
will download the Social Security Data, massage it, and save it as a Parquet
file, for easy analysis with Apache Spark. You can import the notebook
directly into Databricks, as described
[here](https://docs.databricks.com/user-guide/notebooks/index.html#importing-notebooks).
You'll want this [notebook link](/attachments/2016-12-29/SSA-Names-ETL.scala).
A more readable HTML version, which shows the output from a run (and which can
also be directly imported into Databricks) is
[here](/attachments/2016-12-29/SSA-Names-ETL.html).
