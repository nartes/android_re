import io
import numpy
import os
import re
import pandas

os.system(
    r"""gdisk -l tmp/image.dat | awk '{print $2,$3}'""" +
    r""" | grep -P '^\d+' > build/image.dat.offsets""")

t = io.open('build/image.dat.offsets', 'r').read()
o = numpy.array([int(x, 10) for x in re.compile(
    r'\s+').split(t) if len(x) > 0]).reshape(-1, 2)
z = pandas.DataFrame(
    {'beg': o[:, 0], 'end': o[:, 1], 'num': range(o.shape[0])})
z['num'] += 1
for i, p in z.iterrows():
    os.system(
        ('dd if=tmp/image.dat bs=512 skip=%d count=%d ' +
         'of=build/image-part-%d.dat')
        % (p['beg'], p['end'] - p['beg'] + 1, p['num']))
