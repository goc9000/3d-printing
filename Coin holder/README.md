Coin Holder
===========

Design (C) Copyright 2016-present Cristian Dinu (<goc9000@gmail.com>); Licensed under the GPLv3.


Motivation
----------

In my travels I've collected a number of souvenirs and mementos, some of which are coins from various countries. Initially they were lumped in a box together with other tiny souvenirs, but this makes it difficult to consult them whenever I'm feeling nostalgic. I've decided to build a dedicated container for them, with the following characteristics:

- As compact as possible (space in the souvenir boxes is at a premium)
- Structured so that coins are kept organized, by country and type (main set or variants), so that they can be consulted easily
- Coins should be held securely so they can't move around in the container or fall out while in storage


Construction
------------

The basic unit of construction is the *sheet*, a flat piece with two rows of holes where the coins go, kind of like a drawer in a commode. A sheet generally stores all coins for a given country, thus each country has at least one sheet with the main denominations, as well as a number of other sheets with variants of the above.

Within a sheet, a coin is stored within a hole with the same radius and thickness as the coin. The hole continues to the other side of the sheet, with a slightly smaller radius than that of the coin. Thus, each coin is vertically supported along its edge by a sliver of material, while leaving its center exposed so that it can be easily pushed out of the sheet using one's finger.

Each sheet is fitted with a hole in its corner such that all sheets can be brought together along a cylinder called a *pylon* emanating from a base sheet. The whole construct is topped off by another sheet without holes, which attaches to the top of the pylon via a simple friction joint.

When all sheets are closed, the whole construct occupies a rectangular volume in space. Note that in this state all coins are held securely in place as they are surrounded by material from all sides (either from their own sheet or the one above). When one wishes to consult the coins from a given country, one pulls on the corresponding sheet's tab, and it pivots around the pylon, exposing the coins for inspection.

Some attention is needed with the tolerances to account for the mating between these parts:

- Coins vs. their holes in each sheet (should have moderate friction, ideally so that coins don't fall out if the sheet is turned upside down, but they can be removed easily if pushed)
- A sheet's hole vs the pylon (should have moderate friction, such that it can be easily pivoted but ideally doesn't pivot on its own when gravity pulls on it)
- The friction joint where the top attaches to the pylon (should have high friction so that the attachment is secure)


First Print Notes
-----------------

- First printed Nov 2016
- Printed using ABS
- Detail is very good, the text on the tabs is very legible
- Friction in the top-to-pylon joint is satisfactory, would have liked even more if possible
- Friction of the sheets vs the pylon is OK, but a bit inconsistent
- Friction of the coins vs their holes is very inconsistent. Some coins fit snugly with high friction, others loosely such that they would fall out if the sheet were overturned. This could be explained by the official dimensions not being accurate enough for some countries' coins, but given that this occurs even within coins for the same country, I suspect the real reason is natural variance in the sizes of each minted coin.
- **A serious problem occured with the 50p and 20p UK coins, which are pentagonal**. I thought the official diameter corresponds to the radius of the pentagon, but it doesn't. As a result, these coins would not fit in their holes and I had to manually adjust the holes later. Should find out what the proper radius is and adjust the specs.
  - Later edit: in the meantime, I found out that the shape for these coins is called a *Reuleaux heptagon* (i.e. 7-sided polygon, not a pentagon like it first seemed to me). This is an interesting shape in that it is not a circle, but it has a constant diameter allthroughout, where by diameter we mean the largest distance between any two points. The coins were designed this way so that they would still fit through slots of the same size, while being different in shape from the coins they replaced. A coin of this shape however will not fit into a circle with the same diameter, which is what caused the problem. I have adjusted the program so that it creates Reuleaux heptagon-shaped holes for these particular coins.
- **Flaw**: I didn't account for the fact that in reality the sheets will come out ever so slightly thicker than in theory, which causes them to stack up to a height somewhat taller than the pylon. Luckily, the friction joint compensates for this, but I should add a tolerance for this in the design.
- **Flaw**: I also didn't account for the friction between the sheets themselves, which is higher than I expected, likely due to the noise patterns on the face of each sheet. As a result, when a drawer is pivoted, the others around it will tend to pivot as well unless held in place. Maybe vapor-polishing these will help.
