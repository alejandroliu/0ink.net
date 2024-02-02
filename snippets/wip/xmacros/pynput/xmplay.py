
import sys
import tkinter as tk

class Message(tk.Frame):
  def __init__(self, master,text):
    super().__init__(master)

    self.pack(padx = 10, pady = 10)
    self.message = tk.Message(self, text = text)
    self.message.pack(padx = 10, pady = 10, side = 'top')

    self.okbtn = tk.Button(self,text = ' Ok ', command = self.dok)
    self.okbtn.pack(padx = 10, pady = 10)

    master.bind('<Key-Return>', self.b_close )
    master.bind('<Key-Escape>', self.b_close )

  def dok(self):
    self.quit()

  def b_close(self, event):
    self.quit()

  def run(msg, delay = None):
    root = tk.Tk()
    root.option_add('*Font', 'Helvetica 14 bold')
    # ~ root.wm_overrideredirect(True)
    # ~ root.wm_resizable(False,False)
    root.eval('tk::PlaceWindow . center')

    notice = Message(root,msg)
    if not delay is None:
      notice.after(delay, lambda notice: notice.quit(), notice)
    notice.mainloop()
    root.wm_withdraw()


class InputNum(tk.Frame):
  def __init__(self, master):
    super().__init__(master)
    self.pack(padx=10,pady=10);

    lb = tk.Label(self,text='Repeat: ')
    lb.grid(row = 0, column = 0)

    self.vcount = tk.IntVar()
    self.vcount.set(1)

    self.input = tk.Entry(self, textvariable = self.vcount)
    self.input.grid(row = 0, column = 1)
    self.input.focus()
    self.input.icursor(1)
    self.input.selection_range(0,1)

    self.done = False
    self.okbtn = tk.Button(self,text = ' Ok ', command = self.dok)
    self.okbtn.grid(row = 1, column = 0, columnspan = 2, padx = 10, pady = 10)

    master.bind('<Key-Return>', self.b_enter )
    master.bind('<Key-Escape>', self.b_escape )

  def dok(self):
    print(self.vcount.get())
    self.done = True
    self.quit()

  def b_escape(self, event):
    self.quit()
  def b_enter(self,event):
    self.dok()

  def run():
    root = tk.Tk()
    root.option_add('*Font', 'Helvetica 14')
    root.option_add('*Button.font', 'Helvetica 14 bold')
    root.eval('tk::PlaceWindow . center')

    dlg = InputNum(root)
    dlg.mainloop()
    root.wm_withdraw()
    return dlg.done, dlg.vcount.get()


def args(runme):
  if len(sys.argv) == 1:
    runme()
  elif len(sys.argv) == 2 and sys.argv[1] == 'q':
    # Ask for count
    okcancel, count = InputNum.run()
    print('ok={0} count={1}'.format(okcancel, count))
    if okcancel:
      for x in range(0,count):
        runme()
  elif len(sys.argv) > 2 and sys.argv[1] == 'm':
    Message.run(sys.argv[2])
  else:
    print("Usage: {cmd} [q]");

if __name__ == '__main__':
  def doit():
    print('doing it')
  args(doit)
