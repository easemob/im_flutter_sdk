
#!/bin/bash

flutter clean

FILE_NAME=agora_chat_sdk

rm -rf example/ios/.symlinks
rm -rf ../${FILE_NAME}
python update_to_agora.py -s ./ -t ../${FILE_NAME}
