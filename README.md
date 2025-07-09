# zshrc

## 安裝docker
```bash
curl -fssL https://get.docker.com -o install-docker.sh
sudo sh install-docker.sh

```
## 匯入映像檔
```bash
docker load mynordic_matter.tar

```
## 指令
```bash
docker run -it --rm -v ~/DD1/work/playground/homekit:/home/myuser/Nordic_SDK/v2.4.0/homekit  mynoridc_matter 

```
## 原始碼
將nordic-homekit-sdk.tar.gz解壓之後,放在叫homekit的目錄裡。其它命名的目錄也可以，只是在上面的指令部份改成如下面，[source code DIR]為解壓後的目錄
docker run -it --rm -v [source code DIR]:/home/myuser/Nordic_SDK/v2.4.0/homekit  --device=/dev/ttyUSB0 --privileged mynoridc_matter 

## 編輯與編譯
在[source code DIR]裡編輯即可，編譯的部份，可進入docker裡編譯及燒錄

### 若使用dockerfile編譯映像檔
請注意dockfile裡的註示

