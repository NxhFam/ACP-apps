# Small Python script to extract details about exceptions. Basically a copy of traceback.py,
# which doesn’t crash if `linecache.getline()` refuses to work with files with non-UTF 
# characters. Don’t you just love Python? Even stardard core library for getting exception 
# tracebacks doesn’t work properly.

import linecache

def __s_format_list(extracted_list):
  list = []
  for filename, lineno, name, line in extracted_list:
    item = '  File "%s", line %d, in %s\n' % (filename,lineno,name)
    if line:
      item = item + '    %s\n' % line.strip()
    list.append(item)
  return list

def __s_extract_tb(tb, limit=None):
  if limit is None:
    limit = 10
  list = []
  n = 0
  while tb is not None and (limit is None or n < limit):
    f = tb.tb_frame
    lineno = tb.tb_lineno
    co = f.f_code
    filename = co.co_filename
    name = co.co_name
    line = None
    try:
      linecache.checkcache(filename)
      line = linecache.getline(filename, lineno, f.f_globals)
      if line: line = line.strip()
      else: line = None
    except:
      line = None
    list.append((filename, lineno, name, line))
    tb = tb.tb_next
    n = n+1
  return list

def __s_format_tb(tb, limit=None):
  return __s_format_list(__s_extract_tb(tb, limit))

__s_cause_message = (
  "\nThe above exception was the direct cause "
  "of the following exception:\n")

__s_context_message = (
  "\nDuring handling of the above exception, "
  "another exception occurred:\n")

def __s_iter_chain(exc, custom_tb=None, seen=None):
  if seen is None:
    seen = set()
  seen.add(exc)
  its = []
  context = exc.__context__
  cause = exc.__cause__
  if cause is not None and cause not in seen:
    its.append(__s_iter_chain(cause, False, seen))
    its.append([(__s_cause_message, None)])
  elif (context is not None and
      not exc.__suppress_context__ and
      context not in seen):
    its.append(__s_iter_chain(context, None, seen))
    its.append([(__s_context_message, None)])
  its.append([(exc, custom_tb or exc.__traceback__)])
  for it in its:
    for x in it:
      yield x

def __s_format_exception(etype, value, tb, limit=None, chain=True):
  list = []
  if chain:
    values = __s_iter_chain(value, tb)
  else:
    values = [(value, tb)]
  for value, tb in values:
    if isinstance(value, str):
      list.append(value + '\n')
      continue
    if tb:
      list.append('Traceback (most recent call last):\n')
      list.extend(__s_format_tb(tb, limit))
    list.extend(__s_format_exception_only(type(value), value))
  return list

def __s_format_exception_only(etype, value):
  if etype is None:
    return [__s_format_final_exc_line(etype, value)]

  stype = etype.__name__
  smod = etype.__module__
  if smod not in ("__main__", "builtins"):
    stype = smod + '.' + stype

  if not issubclass(etype, SyntaxError):
    return [__s_format_final_exc_line(stype, value)]

  lines = []
  filename = value.filename or "<string>"
  lineno = str(value.lineno) or '?'
  lines.append('  File "%s", line %s\n' % (filename, lineno))
  badline = value.text
  offset = value.offset
  if badline is not None:
    lines.append('    %s\n' % badline.strip())
    if offset is not None:
      caretspace = badline.rstrip('\n')
      offset = min(len(caretspace), offset) - 1
      caretspace = caretspace[:offset].lstrip()
      caretspace = ((c.isspace() and c or ' ') for c in caretspace)
      lines.append('    %s^\n' % ''.join(caretspace))
  msg = value.msg or "<no detail available>"
  lines.append("%s: %s\n" % (stype, msg))
  return lines

def __s_format_final_exc_line(etype, value):
  valuestr = __s_some_str(value)
  if value is None or not valuestr:
    line = "%s\n" % etype
  else:
    line = "%s: %s\n" % (etype, valuestr)
  return line

def __s_some_str(value):
  try:
    return str(value)
  except:
    return '<unprintable %s object>' % type(value).__name__

# This is the function that will be called
def __s_pretty_traceback(exc_type, exc_value, exc_tb):
  try:
    return ''.join(__s_format_exception(exc_type, exc_value, exc_tb))
  except:
    import traceback
    return 'Failed to get traceback:\n' + traceback.format_exc()
