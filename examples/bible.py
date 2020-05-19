"""
bible.py -
"""

import sys
import pysword

def main():
    manager = pysword.SWMgr()
    module = manager.getModule(sys.argv[1] if len(sys.argv) > 1 else "KJV")

    module.setKey(sys.argv[2] if len(sys.argv) > 2 else "Jn.3.16")

    key = pysword.VerseKey(module.getKey())
    curVerse = key.getVerse()
    curChapter = key.getChapter()
    curBook = key.getBook()

    key.setVerse(1)
    module.setKey(key)

    while (key.getBook() == curBook and key.getChapter() == curChapter and
            not module.popError()):
        if key.getVerse() == curVerse:
            print("* ", end="")

        print(f"{key.getVerse()} {module.stripText()}")
        key += 1
        module.setKey(key)

if __name__ == "__main__":
    main()
