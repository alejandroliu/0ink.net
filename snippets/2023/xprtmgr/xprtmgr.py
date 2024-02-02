
import tkinter as tk
from tkinter import ttk
from tkinter import messagebox
import sys
from threading import Thread
import time
import cups
from collections import namedtuple
import os
import subprocess
import tooltip

PrinterQueue = namedtuple('PrinterQueue', 'id name options')
PrinterJob = namedtuple('PrinterJob', 'id attributes')

__dir__ = os.path.dirname(__file__) + '/'
print(__dir__)
PLAY_BUTTON = __dir__ + 'icons8-play-48.png'
PAUSE_BUTTON = __dir__ + 'icons8-pause-48.png'
ACCEPT_BUTTON = __dir__ + 'icons8-accept-48.png'
REJECT_BUTTON = __dir__ + 'icons8-x-48.png'
PRINT_BUTTON = __dir__ + 'icons8-print-48.png'
DOC_BUTTON = __dir__ + 'icons8-document-48.png'
DOCS_BUTTON = __dir__ + 'icons8-documents-48.png'
INFO_BUTTON = __dir__ + 'icons8-info-48.png'
PRINTMGR_ICON = __dir__ + 'icons8-print_mgr-48.png'

COMMANDS = {
  'enable': ('sudo','cupsenable'),
  'disable': ('sudo', 'cupsdisable'),
  'accept': ('sudo', 'cupsaccept'),
  'reject': ('sudo', 'cupsreject'),
  'lprm': ('sudo', 'lprm' ),
}

def time_interval(tt):
  try:
    tt = time.time() - int(tt)
  except Exception:
    return tt

  if tt > 86400:
    i = int(tt / 86400)
    if i == 1:
      txt = 'one day'
    else:
      txt = '{:,} days'.format(i)
  elif tt > 3600:
    i = int(tt/3600)
    if i == 1:
      txt = 'one hour'
    else:
      txt = '{} hours'.format(i)
  elif tt > 60:
    i = int(tt/60)
    if i == 1:
      txt = 'one minute'
    else:
      txt = '{} minutes'.format(i)
  else:
    txt = 'a few seconds'
  txt = txt + ' ago'
  return txt

def make_list(rows, rw, *args):
  row = []
  i = 0
  for x in args:
    row.append(x)
    if len(row) > len(rw):
      rw.append(len(x))
    else:
      if len(x) > rw[i]: rw[i] = len(x)
    i += 1
  rows.append(row)

def make_format(rw):
  fmt = ''
  i = 0
  for x in rw:
    if len(fmt) > 0: fmt += '  '
    fmt += '{%d:%d}' % (i, x)
    i += 1
  return fmt

class PrinterView(ttk.Frame):
  POLL_WAIT = 3

  def printer_states(opts):
    state  = opts['printer-state']
    try:
      state = int(state)
    except Exception:
      return 'error'
    # See: https://github.com/apple/cups/blob/859ea4481c85a2dd6157396a22b3c8b3b726e06b/cups/cupspm.md#basic-destination-information
    if state == 3:
      return 'idle'
    elif state == 4:
      return 'printing'
    elif state == 5:
      return 'stopped'
    else:
      return 'error'


  def poll_printers(pycups):
    qs = pycups.getDests()
    i = 0
    ret = []
    for ref,attr in qs.items():
      q = PrinterQueue(i, attr.name, attr.options)
      ret.append(q)
      i += 1
    return ret

  def dump_queues(queues):
    for q in queues:
      print('{id} {name}:'.format(id=q.id, name=q.name))
      for k,v in q.options.items():
        print('    {k}: {v} ({t})'.format(k=k,v=v, t=type(v)))

  def update(self):
    # ~ PrinterView.dump_queues(self.cups_dests)
    cur = self.print_list.curselection()

    rows = []
    rw = []
    for q in self.cups_dests:
      make_list(rows, rw,
        q.name,
        'active' if q.options['printer-is-accepting-jobs'] == 'true' else 'inactive',
        PrinterView.printer_states(q.options),
        time_interval(q.options['printer-state-change-time'])
      )
    fmt = make_format(rw)

    i = 0
    for q in rows:
      self.print_list.delete(i)
      self.print_list.insert(i, fmt.format(*q))
      i += 1
    self.print_list.delete(i, tk.END)

    for i in cur:
      self.print_list.selection_set(i)

    self.queue_select(None)


  def printer_poller(self):
    pycups = cups.Connection()

    while True:
      self.cups_dests = PrinterView.poll_printers(pycups)
      self.after_idle(self.update)
      time.sleep(PrinterView.POLL_WAIT)

  def queue_select(self,e):
    for i,j in self.commands.items():
      j[0]['state'] = tk.DISABLED
    for i in self.print_list.curselection():
      for x,j in self.commands.items():
        j[0]['state'] = tk.NORMAL

      qd = self.cups_dests[i]
      state = PrinterView.printer_states(qd.options)
      # ~ print('state: %s' % state)
      if state == 'stopped':
        # ~ print('PLAY button')
        self.commands['enable'][0]['image'] = self.commands['enable'][1]
      elif state == 'printing' or state == 'idle':
        # ~ print('PAUSE button')
        self.commands['enable'][0]['image'] = self.commands['enable'][2]
      else:
        self.commands['enable'][0]['state'] = tk.DISABLED

      if qd.options['printer-is-accepting-jobs'] == 'true':
        self.commands['accept'][0]['image'] = self.commands['accept'][2]
      else:
        self.commands['accept'][0]['image'] = self.commands['accept'][1]
        self.commands['test'][0]['state'] = tk.DISABLED

      break

  def printer_info(self):
    for i in self.print_list.curselection():
      q = self.cups_dests[i]
      print(q)

      if q.options['device-uri'].startswith('hp:'):
        subprocess.Popen(['hp-toolbox'],close_fds = True)
        break

      rows = []
      rw = []
      txt = ''
      for k,v in q.options.items():
        make_list(rows, rw,
          '{k}: '.format(k=k),
          v,
          ' ({t})'.format(t=type(v)),
        )
        if len(rows) > 20: break
      fmt = make_format(rw)
      for row in rows:
        txt += fmt.format(*row) + '\n'

      messagebox.showinfo(q.name, txt)
      break




  def accept(self):
    for i in self.print_list.curselection():
      q = self.cups_dests[i]
      print(q)

      if q.options['printer-is-accepting-jobs'] == 'true':
        cmd = list(COMMANDS['reject'])
      else:
        cmd = list(COMMANDS['accept'])
      cmd.append(q.name)
      print(cmd)
      subprocess.run(cmd)


  def enable(self):
    for i in self.print_list.curselection():
      q = self.cups_dests[i]
      print(q)

      state = PrinterView.printer_states(q.options)
      print('state: %s' % state)
      if state == 'stopped':
        cmd = list(COMMANDS['enable'])
      elif state == 'printing' or state == 'idle':
        cmd = list(COMMANDS['disable'])
      else:
        return
      cmd.append(q.name)
      print(cmd)
      subprocess.run(cmd)

  def test_print(self):
    for i in self.print_list.curselection():
      qd = self.cups_dests[i]

      if messagebox.askokcancel(title = 'Print Test Page',
                      message = 'Are you sure you want to print a test page on printer {}?'.format(qd.name)):
        try:
          pycups = cups.Connection()
          job_id = pycups.printTestPage(qd.name)
          print(job_id)
          messagebox.showinfo('Print Test Page', 'Jop queued (JobId: {0})'.format(job_id))
        except Exception:
          messagebox.showerror('Print Test Page', 'Error submitting print job')

  def __init__(self,master):
    super().__init__(master, name = 'printer_view')

    self.cups_dests = dict()

    self.commands = {}
    t = ttk.Frame(self, name = 'tools')
    t.pack(side = tk.TOP, fill = tk.X)

    b = ttk.Button(t, name = 'enable', state = tk.DISABLED,
                command = lambda: self.enable()) # Enable/Disable
    b.pack(side = tk.LEFT)
    self.commands['enable'] = [
      b,
      tk.PhotoImage(file = PLAY_BUTTON).subsample(2,2),
      tk.PhotoImage(file = PAUSE_BUTTON).subsample(2,2),
    ]
    b['image'] = self.commands['enable'][1]
    tooltip.ToolTip(b, msg = 'Enable or Disable printing')

    b = ttk.Button(t, name ='accept', state = tk.DISABLED,
                command = lambda: self.accept()) # Accept/Reject
    b.pack(side = tk.LEFT)
    self.commands['accept'] = [
      b,
      tk.PhotoImage(file = ACCEPT_BUTTON).subsample(2,2),
      tk.PhotoImage(file = REJECT_BUTTON).subsample(2,2),
    ]
    b['image'] = self.commands['accept'][1]
    tooltip.ToolTip(b, msg = 'Accept or Reject print jobs')

    b = ttk.Button(t, name ='test', state = tk.DISABLED,
                command = lambda: self.test_print()) # Print Test Page
    b.pack(side = tk.LEFT)
    self.commands['test'] = [
      b,
      tk.PhotoImage(file = PRINT_BUTTON).subsample(2,2),
    ]
    b['image'] = self.commands['test'][1]
    tooltip.ToolTip(b, msg = 'Print test page')

    b = ttk.Button(t, name ='info', state = tk.DISABLED,
                command = lambda: self.printer_info()) # Print Test Page
    b.pack(side = tk.LEFT)
    self.commands['info'] = [
      b,
      tk.PhotoImage(file = INFO_BUTTON).subsample(2,2),
    ]
    b['image'] = self.commands['info'][1]
    tooltip.ToolTip(b, msg = 'Device information')

    f = ttk.Frame(self,name = 'printers_frame')
    f.pack(side = tk.TOP, fill = tk.BOTH ,expand = True)
    sb = tk.Scrollbar(f)
    sb.pack(side = tk.RIGHT, fill = tk.Y)
    self.print_list = tk.Listbox(f,
                        name = 'printers',
                        height = 10,
                        width = 40)
    self.print_list.pack(expand = True, fill  = tk.BOTH, side=tk.LEFT)

    self.print_list.config(xscrollcommand=sb.set)
    sb.config(command=self.print_list.yview)

    self.print_list.bind('<<ListboxSelect>>', lambda e: self.queue_select(e))

    poller = Thread(target=self.printer_poller)
    poller.start()

class JobView(ttk.Frame):
  POLL_WAIT = 3

  def job_poller(self):
    pycups = cups.Connection()

    prinfo = {}
    # Cache printer URIs
    printers = pycups.getPrinters()
    for pr,dat in printers.items():
      print(dat)
      prinfo[dat['printer-uri-supported']] = { 'name': pr }
      for k in ('printer-location', 'printer-info',
                  'printer-make-and-model', 'device-uri'):
        prinfo[dat['printer-uri-supported']][k] = dat[k]
    print(prinfo)

    while True:
      self.cups_jobs = JobView.poll_jobs(pycups, prinfo)
      self.after_idle(self.update)
      time.sleep(JobView.POLL_WAIT)

  def poll_jobs(pycups,prt):
    jobs = pycups.getJobs()

    ret = []
    for jid in jobs:
      attrs = pycups.getJobAttributes(jid).copy()
      attrs['printer'] = prt[attrs['job-printer-uri']]
      if not 'document-name-supplied' in attrs:
        attrs['document-name-supplied'] = '*unknown*'
      ret.append(PrinterJob(jid, attrs))

    return ret

  def dump_jobs(jobs):
    for q in jobs:
      print('{id}:'.format(id=q.id))
      for k,v in q.attributes.items():
        print('    {k}: {v} ({t})'.format(k=k,v=v, t=type(v)))


  def update(self):
    # ~ JobView.dump_jobs(self.cups_jobs)
    cur = self.job_list.curselection()

    rows = []
    rw = []
    for j in self.cups_jobs:
      make_list(rows, rw,
        str(j.id),
        j.attributes['document-name-supplied'],
        ' ({0:,} KB) '.format(j.attributes['job-k-octets']),
        j.attributes['printer']['name'],
      )
    fmt = make_format(rw)

    i = 0
    for q in rows:
      self.job_list.delete(i)
      self.job_list.insert(i, fmt.format(*q))
      i += 1
    self.job_list.delete(i, tk.END)

    for i in cur:
      self.job_list.selection_set(i)

    self.job_select(None)



  def job_select(self,e):
    for i,j in self.commands.items():
      j[0]['state'] = tk.DISABLED

    if len(self.cups_jobs) > 0:
      self.commands['cancel_all'][0]['state'] = tk.NORMAL

    for i in self.job_list.curselection():
      self.commands['cancel'][0]['state'] = tk.NORMAL
      jd = self.cups_jobs[i]

      x = self.job_list.get(i)
      print(x)
      print(jd)


      # ~ qd = self.cups_jobs[i]
      # ~ state = PrinterView.printer_states(qd.options)
      # ~ print('state: %s' % state)
      # ~ if state == 'stopped':
        # ~ print('PLAY button')
        # ~ self.commands['enable'][0]['image'] = self.commands['enable'][1]
      # ~ elif state == 'printing' or state == 'idle':
        # ~ print('PAUSE button')
        # ~ self.commands['enable'][0]['image'] = self.commands['enable'][2]
      # ~ else:
        # ~ self.commands['enable'][0]['state'] = tk.DISABLED

      # ~ if qd.options['printer-is-accepting-jobs'] == 'true':
        # ~ self.commands['accept'][0]['image'] = self.commands['accept'][2]
      # ~ else:
        # ~ self.commands['accept'][0]['image'] = self.commands['accept'][1]
        # ~ self.commands['test'][0]['state'] = tk.DISABLED

      break



  def cancel_job(self):
    cmd = list(COMMANDS['lprm'])
    for i in self.job_list.curselection():
      self.commands['cancel'][0]['state'] = tk.NORMAL
      jd = self.cups_jobs[i]
      cmd.append( str(jd.id) )

    if len(cmd) > len(COMMANDS['lprm']):
      print(cmd)
      print(type(cmd))
      subprocess.run(cmd)

  def cancel_all(self):
    cmd = list(COMMANDS['lprm'])

    for j in self.cups_jobs:
      cmd.append(str(j.id))
    if len(cmd) > len(COMMANDS['lprm']):
      if messagebox.askokcancel(title = 'Cancel All Jobs',
                message = 'Are you sure you want to all print jobs?'):
        print(cmd)
        print(type(cmd))
        subprocess.run(cmd)


  def __init__(self,master):
    super().__init__(master, name = 'job_view')

    self.cups_dests = dict()

    self.commands = {}
    t = ttk.Frame(self, name = 'tools')
    t.pack(side = tk.TOP, fill = tk.X)

    b = ttk.Button(t, name = 'cancel', state = tk.DISABLED,
                command = lambda: self.cancel_job())
    b.pack(side = tk.LEFT)
    self.commands['cancel'] = [
      b,
      tk.PhotoImage(file = DOC_BUTTON).subsample(2,2),
    ]
    b['image'] = self.commands['cancel'][1]
    tooltip.ToolTip(b, msg = 'Cancel selected job')

    b = ttk.Button(t, name = 'cancel_all', state = tk.DISABLED,
                command = lambda: self.cancel_all())
    b.pack(side = tk.LEFT)
    self.commands['cancel_all'] = [
      b,
      tk.PhotoImage(file = DOCS_BUTTON).subsample(2,2),
    ]
    b['image'] = self.commands['cancel_all'][1]
    tooltip.ToolTip(b, msg = 'Cancel ALL jobs')


    f = ttk.Frame(self,name = 'jobs_frame')
    f.pack(side = tk.TOP, fill = tk.BOTH, expand = True)
    sb = tk.Scrollbar(f)
    sb.pack(side = tk.RIGHT, fill = tk.Y)
    self.job_list = tk.Listbox(f,
                        name = 'jobs',
                        height = 10,
                        width = 40)
    self.job_list.pack(expand = True, fill  = tk.BOTH, side=tk.LEFT)

    self.job_list.config(xscrollcommand=sb.set)
    sb.config(command=self.job_list.yview)

    self.job_list.bind('<<ListboxSelect>>', lambda e: self.job_select(e))

    poller = Thread(target=self.job_poller)
    poller.start()


class XPrtMgr(tk.Toplevel):
  def quit(self):
    self.wm_withdraw()
    sys.exit(0)

  def __init__(self, master):
    super().__init__(master, name = 'xprtmgr')

    self.wm_title('XPrtMgr')
    self.wm_iconphoto(False, tk.PhotoImage(file = PRINTMGR_ICON))
    self.protocol('WM_DELETE_WINDOW', lambda: self.quit())

    self.tabs = ttk.Notebook(self, name ='notebook')
    self.tabs.pack(expand = True, fill = tk.BOTH)

    self.tab1 = PrinterView(self.tabs)
    self.tab2 = JobView(self.tabs)

    self.tabs.add(self.tab1, text = 'Printers')
    self.tabs.add(self.tab2, text = 'Jobs')


root = tk.Tk()
root.option_add('*Font','Helvetica 12')
root.option_add('*printers.font', 'Monosans 12 bold')
root.option_add('*jobs.font', 'Monosans 12 bold')
root.wm_withdraw()
app = XPrtMgr(root)
root.mainloop()


