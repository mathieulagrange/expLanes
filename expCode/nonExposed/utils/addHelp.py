#!/usr/bin/python

import sys,os,re,shutil

f = re.compile('function\s*(.+=)?\s*(\S+)\s*\((.*)\)')

commentedFile=[];
done = False;

file = open('test.m', 'w')

for line in open(sys.argv[1], 'r'):
        fm = f.match(line)
	file.write(line)
        if fm and not done:
		commentedFile.append(line)
		done = True
		name = fm.group(2)
		if fm.group(1):
			outputs =  filter(None, re.split('[\W]+', fm.group(1)))
		else:
			outputs = [];
		inputs =  filter(None, re.split('[\W]+', fm.group(3)))
		print outputs
		print name
		print inputs
		file.write(name+'\n')


