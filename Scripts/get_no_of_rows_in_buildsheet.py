#!/usr/bin/python

import xlrd
buildsheet = xlrd.open_workbook('buildsheet.xlsx')

# Load the server details sheet by name
srv_det_sheet = buildsheet.sheet_by_name('Server List')

no_of_row = srv_det_sheet.nrows
print(no_of_row)