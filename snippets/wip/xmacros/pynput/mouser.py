import sys

sys.path.append('pynput-1.7.6/lib')
from pynput import mouse

limits = [ None, None, None, None ]
x_min = 0
y_min = 1
x_max = 2
y_max = 3

def on_move(x, y):
  if limits[x_min] is None: limits[x_min] = x
  if x < limits[x_min]: limits[x_min] = x
  if limits[x_max] is None: limits[x_max] = x
  if x > limits[x_max]: limits[x_max] = x
  if limits[y_min] is None: limits[y_min] = y
  if y < limits[y_min]: limits[y_min] = y
  if limits[y_max] is None: limits[y_max] = y
  if y > limits[y_max]: limits[y_max] = y

  print('Pointer {xy} [{x_min},{y_min},{x_max},{y_max}]'.format(
          xy = (x,y),
          x_min = limits[x_min],
          y_min = limits[y_min],
          x_max = limits[x_max],
          y_max = limits[y_max],
        ))

def on_click(x, y, button, pressed):
  if pressed:
    limits[x_min] = None
    limits[y_min] = None
    limits[x_max] = None
    limits[y_max] = None

    # ~ print('{0} at {1}'.format(
        # ~ 'Pressed' if pressed else 'Released',
        # ~ (x, y)))
    # ~ if not pressed:
        # ~ # Stop listener
        # ~ return False

def on_scroll(x, y, dx, dy):
  pass
    # ~ print('Scrolled {0} at {1}'.format(
        # ~ 'down' if dy < 0 else 'up',
        # ~ (x, y)))

# Collect events until released
with mouse.Listener(
        on_move=on_move,
        on_click=on_click,
        on_scroll=on_scroll) as listener:
    listener.join()

# ...or, in a non-blocking fashion:
listener = mouse.Listener(
    on_move=on_move,
    on_click=on_click,
    on_scroll=on_scroll)
listener.start()
