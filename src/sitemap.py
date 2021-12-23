#
# Hack posts
#
from pprint import pprint

# ~ import glob
# ~ import subprocess
import sys
import argparse
import re

def read_file(fpath):
  with open(fpath,'r') as fp:
    return fp.read()

def write_file(fpath,txt):
  if isinstance(txt,str):
    with open(fpath,'w') as fp:
      fp.write(txt)
  else:
    with open(fpath,'w') as fp:
      for l in txt:
        fp.write(l + "\n")

meta_re = re.compile(r'<meta name="([^"]*)" content="([^"]*)">')
# ~ meta_re = re.compile(r'<meta name=')

def read_meta(fpath,cut=0):
  ret = { 'fpath': fpath }
  if cut:
    ret['fpath'] = '/'.join(fpath.split('/')[cut:])

  with open(fpath,'r') as fp:
    for line in fp:
      mv = meta_re.search(line)
      if mv:
        ret[mv.group(1)] = mv.group(2)
  return ret


def gen_xml(urls, prefix):
  sitemap_xml = []
  sitemap_xml.append('<?xml version="1.0" encoding="UTF-8"?>')
  sitemap_xml.append('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">')
  for fpath in sitemap:
    if not 'int-title' in sitemap[fpath]: continue
    sitemap_xml.append(' <url>')
    sitemap_xml.append('  <loc>{prefix}{path}</loc>'.format(
                          prefix=prefix, path=sitemap[fpath]['fpath']
                        ))
    if 'revised' in sitemap[fpath]:
      sitemap_xml.append('  <lastmod>{rev}</lastmod>'.format(
                          rev=sitemap[fpath]['revised']
                        ))
    sitemap_xml.append(' </url>')

  sitemap_xml.append('</urlset>')
  return sitemap_xml

def gen_html(urls, prefix):
  html = []
  html.append('<!DOCTYPE html>')
  html.append('<html lang="en">')
  html.append(' <head>')
  html.append('  <meta charset="utf-8">')
  html.append('  <title>Sitemap</title>')
  html.append('  <!-- link rel="stylesheet" href="style.css" -->')
  html.append('  <!-- script src="script.js" --><!-- /script -->')
  html.append(' </head>')
  html.append(' <body>')
  html.append('  <h1>Sitemap</h1>')
  html.append('  <ul>')
  html.append('   <li><a href="/">Home</a></li>')
  html.append('   <li><a href="/sitemap.xml">XML Sitemap</a></li>')
  html.append('  </ul>')

  sect = {}

  for fpath in sitemap:
    if not 'int-title' in sitemap[fpath]: continue
    sname = sitemap[fpath]['fpath'].split('/')[0]
    if sname in sect:
      sect[sname].append(fpath)
    else:
      sect[sname] = [ fpath ]

  for ss in sorted(sect):
    html.append('  <h2>{section}</h2>'.format(section=ss))
    html.append('  <ul>')

    if ss == 'posts': sect[ss].sort(reverse=True)

    for fpath in sect[ss]:
      html.append('   <li>')
      html.append('    <a href="{prefix}{path}">{title}</a>'.format(
                  prefix=prefix, path=sitemap[fpath]['fpath'],
                  title=sitemap[fpath]['int-title']))
      if 'revised' in sitemap[fpath]:
        html.append('    <em>(updated {date})</em>'.format(date=sitemap[fpath]['revised']))
      elif 'date' in sitemap[fpath]:
        html.append('    <em>(posted {date})</em>'.format(date=sitemap[fpath]['date']))
      if 'description' in sitemap[fpath]:
        html.append('    <br>{desc}'.format(desc=sitemap[fpath]['description']))
      html.append('   </li>')

    html.append('  </ul>')

  html.append(' </body>')
  html.append('</html>')

  return html

if __name__ == "__main__":
  cli = argparse.ArgumentParser(prog='sitemap',
                                description = 'Sitemap generator')
  cli.add_argument('-p','--strip',help = 'strip from path',
                    type=int,default=0)
  cli.add_argument('--prefix',help='URL prefix',default='file://')
  cli.add_argument('--xml',help='Generate xml sitemap')
  cli.add_argument('--html',help='Generate html sitemap')
  cli.add_argument('files',nargs='*',help='files to process')

  args = cli.parse_args()
  # ~ sys.stderr.write(str(args)+'\n')

  sitemap = {}

  for fpath in args.files:
    # ~ itxt = read_file(pg)
    if '/1111/' in fpath: continue
    ret = read_meta(fpath,args.strip)
    sitemap[fpath] = ret

  if args.xml:
    sitemap_xml = gen_xml(sitemap,args.prefix)
    write_file(args.xml, sitemap_xml)

  if args.html:
    html = gen_html(sitemap,'/')
    write_file(args.html, html)
