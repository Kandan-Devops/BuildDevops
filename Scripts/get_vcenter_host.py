#!/usr/bin/python

import xlrd

# Open the buildsheet
buildsheet = xlrd.open_workbook('buildsheet.xlsx')

# Load the server details sheet by name
srv_det_sheet = buildsheet.sheet_by_name('Server List')

#Arguments passed in cmdline 
row=int(sys.argv[1])

#Fetching inputs from buildsheet
vcenter_host =  srv_det_sheet.cell_value(row, 13)
print(vcenter_host)