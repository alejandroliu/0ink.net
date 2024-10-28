import select
import socket
import sys

path = 'socket'

client = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
client.connect(path)

while True:
  rds = [ client.fileno(), sys.stdin.fileno() ]
  r,_,_ = select.select(rds, [], [])
  if client.fileno() in r:
    data = client.recv(4096)
    if len(data) == 0: sys.exit(0)
    if data[-1] == '\n': data = data[:-1]
    print(f'Read {len(data)} {data}')
  if sys.stdin.fileno() in r:
    print('Reading stdin')
    data = sys.stdin.readline()
    if len(data) == 0: sys.exit(0)
    client.sendall(data.encode())
