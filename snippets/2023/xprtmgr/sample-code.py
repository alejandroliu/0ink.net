#
# Printer manager
#
# - printers (status)
# - jobs
# - ink levels
#
# enable/disable | accept/reject
# Print test page
# cancel job, all jobs
#
# https://github.com/apple/cups/blob/859ea4481c85a2dd6157396a22b3c8b3b726e06b/cups/cupspm.md
#

import cups

conn = cups.Connection()

# ~ printers = conn.getPrinters()
# ~ for pr in printers:
  # ~ print(pr)
  # ~ for k in printers[pr]:
    # ~ print('  {k}: {v}'.format(k=k,v=printers[pr][k]))
  # ~ attr = conn.getPrinterAttributes(name = pr)
  # ~ print('Attributes:')
  # ~ for k,v in attr.items():
    # ~ print('    {k}: {v}'.format(k=k,v=v))

# ~ dests = conn.getDests()
# ~ for dd,yy in dests.items():
  # ~ print(dd)
  # ~ if yy.is_default: print('  DEFAULT')
  # ~ print('  NAME: {0}'.format(yy.name))
  # ~ for k,v in yy.options.items():
    # ~ print('    {k}: {v}'.format(k=k,v=v))


jobs = conn.getJobs()
for j,i in jobs.items():
  print(j)
  print(i)
  a = conn.getJobAttributes(j)
  for k,v in a.items():
    print('  {k}: {v}'.format(k=k,v=v))
