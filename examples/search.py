"""
search.py -
"""

import sys
import pysword

def main():
    manager = pysword.SWMgr()
    module = manager.getModule(sys.argv[2] if len(sys.argv) > 2 else "KJV")
    key = module.doSearch(sys.argv[1], pysword.SEARCHTYPE_MULTIWORD)

    while not key.popError():
        print(key.getText())
        key.increment()

if __name__ == "__main__":
    main()
