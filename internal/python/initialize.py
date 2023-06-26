ARG_LOGGING_ACTIVE = False

if False:
  with open('R:/log.txt', 'w') as fp:
    fp.write('-- started --\n')

  def log(key, msg):
    with open('R:/log.txt', 'a') as log:
      log.write(str(key) + ': ' + str(msg) + '\n')
else:
  def log(key, msg):
    pass

try:
  import sys
  if ARG_ENABLE_CACHE:
    sys.dont_write_bytecode = False

  if ARG_ENABLE_REDIRECTS:
    from importlib.machinery import SourceFileLoader, ExtensionFileLoader

    class RedirectFinder():    
      def __init__(self, path):
        self.path = path
        self.base = baseFinder(path)

      def invalidate_caches(self):
        self.base.invalidate_caches()

      def find_module(self, fullname):
        loader, portions = self.find_loader(fullname)
        return loader

      def find_loader(self, fullname):
        log('finder.find_loader', fullname)
        if fullname == 'lib.sim_info' or fullname == 'third_party.sim_info':
          return (SourceFileLoader(fullname, 'extension/internal/python/lib/sim_info.py'), ['extension/internal/python/lib'])
        if fullname == '_ctypes':
          return (ExtensionFileLoader(fullname, 'extension/internal/python/lib/_ctypes.pyd'), ['extension/internal/python/lib'])
        return self.base.find_loader(fullname)

      def __repr__(self):
        return "RedirectFinder(%r)" % (self.path,)

    baseFinder = sys.path_hooks[1]
    sys.path_hooks[1] = RedirectFinder

  log('ready', 'ok')
except:
  import traceback
  log('error', traceback.format_exc())