import tkinter as Tk

def callback(event):
  print(f'{event.x}x{event.y}')


root = Tk.Tk()
def get_mouse_pos():
  print(root.winfo_pointerxy())
  root.after(100,get_mouse_pos)

get_mouse_pos()
# ~ root.bind('<Motion>', callback)
root.mainloop()

