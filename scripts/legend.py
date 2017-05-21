#!/usr/bin/env python
#vim: syntax=python tabstop=2 expandtab

__author__ = "Mahesh Vangala"
__email__ = "<vangalamaheshh@gmail.com>"
__date__ = "May, 21, 2017"

"""
  Prints legend as separate png

  Due to lack of documentation to add
  external ring color as legend in graphlan
  this scripts supports generating such legend
  image.
"""

import matplotlib.pyplot as pylab
from cycler import cycler

fig = pylab.figure()
figlegend = pylab.figure(figsize=(3,2))
ax = fig.add_subplot(111)
#lines = ax.plot(range(10), pylab.randn(10), range(10), pylab.randn(10))
ax.set_prop_cycle(cycler('color',['red', 'black', 'yellow']))
lines = ax.plot(1,2,3,4,5,6) 
figlegend.legend(lines, ('one', 'two'), 'center')
#fig.show()
#figlegend.show()
figlegend.savefig('legend.png')
