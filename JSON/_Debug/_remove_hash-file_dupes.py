# Removing dupes with hash files in the name if it matches the base file
# Yamagami 2022-02-18

# Requirement: The script must run in the parent folder where the Unity Asset extracted folders are (i.e. same directory where TextAsset/, Texture2D/, etc. resides)

import hashlib
import os
import os.path
import re
import sys

for subdir, dirs, files in os.walk("./"):       # Lists the dir and files in the current
    for dir in dirs:                            # Going through the dir separately
        if dir=="TextAsset_out": continue
        for file in os.listdir(dir):            # Going in to each directory
            Match = re.search("^([^#]+) #\d+(\..+)$", file)
            if Match:
                baseFile = dir + "/" + Match.group(1) + Match.group(2)

                # Debugging:
                ## print(file+" == "+baseFile)
                ## print(hashlib.md5(open(dir+"/"+file,'rb').read()).hexdigest()+" == "+hashlib.md5(open(dir+"/"+baseFile,'rb').read()).hexdigest())
                
                # If the MD5 hashes of the content of the file with # in its name and its base file are identical, delete it
                # If the base filename is missing or the content is different, it is kept
                
                if(os.path.exists(baseFile) and (hashlib.md5(open(dir+"/"+file,'rb').read()).hexdigest()+" == "+hashlib.md5(open(baseFile,'rb').read()).hexdigest())):
                    os.remove(dir+"/"+file)
                    print("Removed "+file+" (matched MD5 for "+baseFile+")")
        