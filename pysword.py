from Sword import *

_SWKey = SWKey
_SWMgr = SWMgr
_SWModule = SWModule
_ListKey = ListKey
_VerseKey = VerseKey

class SWKey(_SWKey):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def popError(self):
        return bool(ord(_SWKey.popError(self)))

    def __iadd__(self, steps):
        if steps > 0:
            self.increment(steps)
        elif steps < 0:
            self.decrement(-steps)
        return self

    def __isub__(self, steps):
        if steps > 0:
            self.decrement(steps)
        elif steps < 0:
            self.increment(-steps)
        return self

class ListKey(SWKey, _ListKey):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

class VerseKey(SWKey, _VerseKey):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def getBook(self):
        return ord(_VerseKey.getBook(self))

class SWModule(_SWModule):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def doSearch(self, *args, **kwargs):
        key = _SWModule.doSearch(self, *args, **kwargs)
        key.__class__ = ListKey
        return key

    def popError(self):
        return bool(ord(_SWModule.popError(self)))

    def renderText(self, *args, **kwargs):
        return str(_SWModule.renderText(self, *args, **kwargs))

    def setKey(self, key):
        if isinstance(key, str):
            key = SWKey(key)
        return bool(ord(_SWModule.setKey(self, key)))

class SWMgr(_SWMgr):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def getModule(self, *args, **kwargs):
        module = _SWMgr.getModule(self, *args, **kwargs)
        module.__class__ = SWModule
        return module

SEARCHTYPE_REGEX = 0
SEARCHTYPE_PHRASE = -1
SEARCHTYPE_MULTIWORD = -2
SEARCHTYPE_ENTRY_ATTRIB = -3
