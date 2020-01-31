# pywinsword

Builds Python bindings on Windows for [The SWORD Engine](http://www.crosswire.org/sword/software/swordapi.jsp)

## Building

Install the following prerequisites and run `build.sh`:
* [Git Bash for Windows](https://git-scm.com/download/win)
* [Python 3.8](https://www.python.org/downloads/) (32-bit, installed on PATH)
* [Visual Studio 2017 Build Tools](https://visualstudio.microsoft.com/thank-you-downloading-visual-studio/?sku=BuildTools&rel=15) (with Windows 8.1 SDK & Universal CRT SDK components)

## Testing

Install a Bible text module like KJV from [here](http://www.crosswire.org/sword/modules/ModDisp.jsp?modType=Bibles). Then try running some commands:

```python
>>> import Sword
>>> Sword.SWMgr
<class 'Sword.SWMgr'>
>>> swmgr = Sword.SWMgr('path_to_modules_folder')
>>> swmgr.getModule('KJV')
<Sword.SWModule; proxy of <Swig Object of type 'sword::SWModule *' at 0x4e3ba70> >
>>> kjv_module = swmgr.getModule('KJV')
>>> verse_key = kjv_module.createKey()
>>> verse_key.setText('Genesis 12:3')
>>> kjv_module.setKey(verse_key)
'\x00'
>>> kjv_module.getKeyText()
'Genesis 12:3'
>>> kjv_module.getRawEntry()
'<w lemma="strong:H01288" morph="strongMorph:TH8762">And I will bless</w> <w lemma="strong:H01288" morph="strongMorph:TH8764">them that bless</w> <w lemma="strong:H0779" morph="strongMorph:TH8799">thee, and curse</w> <w lemma="strong:H07043" morph="strongMorph:TH8764">him that curseth</w> <w lemma="strong:H04940">thee: and in thee shall all families</w> <w lemma="strong:H0127">of the earth</w> <w lemma="strong:H01288" morph="strongMorph:TH8738">be blessed</w>.'
>>> str(kjv_module.renderText())
'<w  savlm="strong:H01288">And I will bless</w> <w  savlm="strong:H01288">them that bless</w> <w  savlm="strong:H0779">thee, and curse</w> <w  savlm="strong:H07043">him that curseth</w> <w savlm="strong:H04940">thee: and in thee shall all families</w> <w savlm="strong:H0127">of the earth</w> <w  savlm="strong:H01288">be blessed</w>.'
>>> kjv_module.stripText()
'And I will bless them that bless thee, and curse him that curseth thee: and in thee shall all families of the earth be blessed.'
>>> kjv_module.increment()
>>> kjv_module.getKeyText()
'Genesis 12:4'
>>> kjv_module.stripText()
'\nSo Abram departed, as the LORD had spoken unto him; and Lot went with him: and Abram was seventy and five years old when he departed out of Haran.'
>>> verse_key
<Sword.SWKey; proxy of <Swig Object of type 'sword::SWKey *' at 0x50bc030> >
>>> verse_key.setText('Rev 22:21')
>>> kjv_module.setKey(verse_key)
'\x00'
>>> kjv_module.stripText()
'The grace of our Lord Jesus Christ be with you all. Amen.\n'
>>> kjv_module.increment()
>>> kjv_module.popError()
'\x01'
>>> kjv_module.decrement()
>>> kjv_module.popError()
'\x00'
```
