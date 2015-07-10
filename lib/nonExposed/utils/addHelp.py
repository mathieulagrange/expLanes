#!/usr/bin/python

import sys,os,re,shutil

f = re.compile('function\s*(.+=)?\s*(\S+)\s*\((.*)\)')

commentedFile=[];
done = False;

file = open(sys.argv[1]+'.tmp', 'w')

for line in open(sys.argv[1], 'r'):
        fm = f.match(line)
	file.write(line)
        if fm and not done:
		commentedFile.append(line)
		done = True
		name = fm.group(2)
		if fm.group(1):
                        out = fm.group(1)+' '
			outputs =  filter(None, re.split('[\W]+', fm.group(1)))
		else:
                        out = ''
			outputs = [];
		inputs =  filter(None, re.split('[\W]+', fm.group(3)))
		file.write('% '+name+'\n%\t'+out+name+'('+fm.group(3)+')\n')
                for i in inputs:
                        file.write('%\t- '+i+': \n')lolo
                for o in outputs:
                        if o not in inputs:
                                file.write('%\t-- '+o+': \n')
                file.write('\n')
                file.write('%\tCopyright (c) 2014 Mathieu Lagrange (mathieu.lagrange@cnrs.fr)\n')
                file.write('%\tSee licence.txt for more information.\n\n')

os.rename(sys.argv[1]+'.tmp', sys.argv[1])
