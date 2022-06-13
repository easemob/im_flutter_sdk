
#!/bin/bash

flutter clean

FILE_NAME=chat_flutter_sdk
 
rm -rf ../${FILE_NAME}
python update_to_agora.py -s ./ -t ../${FILE_NAME}
