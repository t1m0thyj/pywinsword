"""
install.py -
"""

import sys
import pysword

def main():
    manager = pysword.SWMgr()
    pysword.
    installer = pysword.InstallMgr()
    installer.setUserDisclaimerConfirmed(True)
    install_source = pysword.InstallSource("FTP")
    install_source.caption = pysword.SWBuf("CrossWire", len("CrossWire"))
    install_source.source = pysword.SWBuf("ftp.crosswire.org", len("ftp.crosswire.org"))
    install_source.directory = pysword.SWBuf("/pub/sword/raw", len("/pub/sword/raw"))
    installer.installModule(manager, None, sys.argv[1], install_source)

if __name__ == "__main__":
    main()
