FROM ubuntu:22.04

# === 安裝開發工具與相依套件 ===
RUN apt update && apt install -y \
		git vim cmake ninja-build gperf  zsh \
		fonts-powerline  fonts-noto-color-emoji  fonts-font-awesome \
		locales libglib2.0-0 libx11-xcb1 libxcomposite1 libxcursor1 libxdamage1 \
		libxrandr2 libasound2 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 libgbm1 \
		libgtk-3-0 libpango-1.0-0 libpangocairo-1.0-0 libxkbfile1 libsecret-1-0 libxss1 libnss3 \
		libxshmfence1 flex bison \ 
		ccache dfu-util device-tree-compiler \
		wget python3-pip python3-venv python3-dev \
		python3-setuptools python3-wheel \
		xz-utils file make gcc g++ unzip \
		libncurses-dev libusb-1.0-0 libssl-dev \
		libglib2.0-dev libpixman-1-dev udev \
		lsb-release curl sudo && \
		apt-get clean && rm -rf /var/lib/apt/lists/*

# 設定語系（避免 locale 警告），若使用FROM ubuntu:20.04 要把下面的註示打開
#RUN locale-gen en_US.UTF-8
#ENV LANG=en_US.UTF-8
#ENV LANGUAGE=en_US:en
#ENV LC_ALL=en_US.UTF-8

# === 建立使用者 devuser 並加入 dialout 群組 ===
RUN useradd -ms /bin/zsh myuser && usermod -aG dialout myuser
USER myuser
WORKDIR /home/myuser

# 安裝 oh-my-zsh（非互動式）
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# 安裝 Powerlevel10k 主題
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /home/myuser/.oh-my-zsh/custom/themes/powerlevel10k

# 設定 oh-my-zsh 預設主題為 powerlevel10k
RUN sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' /home/myuser/.zshrc

#安裝oh-my-zsh 插件
		RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
		RUN git clone https://github.com/zsh-users/zsh-completions.git   ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions


# 複製簡單的 powerlevel10k 設定檔，避免首次啟動時互動設定
		RUN echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> /home/myuser/.zshrc

# 下載簡單的 powerlevel10k 設定檔（可選）
		RUN curl -fsSL https://raw.githubusercontent.com/romkatv/powerlevel10k/refs/heads/master/config/p10k-rainbow.zsh -o /home/myuser/.p10k.zsh

# 下載 zshrc
		RUN curl -fsSL https://raw.githubusercontent.com/ChangMK/ESP32_matter_zshrc/refs/heads/main/.zshrc -o /home/myuser/.zshrc
		
# === 安裝 west（Zephyr/Nordic 工具）安裝toolchain時會花很久時間,可能1小時===
ENV PATH="/home/myuser/.local/bin:${PATH}"
RUN pip3 install west && \
echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.zshrc
RUN mkdir -p /home/myuser/Nordic_SDK/v2.4.0
COPY --chmod=0755 ./nrfutil /home/myuser/Nordic_SDK/
RUN cd /home/myuser/Nordic_SDK && \
./nrfutil install toolchain-manager && \
./nrfutil toolchain-manager install --ncs-version v2.5.0 && \
 echo 'source /home/myuser/Nordic_SDK/v2.4.0/zephyr/zephyr-env.sh' >> ~/.zshrc && \
 ./nrfutil install nrf5sdk-tools device completion suit

# === 初始化 nRF Connect SDK（v2.4.0）與 Matter ===

RUN cd /home/myuser/Nordic_SDK && \
west init -m https://github.com/nrfconnect/sdk-nrf --mr v2.4.0 v2.4.0 && \
cd v2.4.0 && \
west config manifest.group-filter +homekit
# === west update 這裡需要手動執行===
## 執行 west update
#```bash
# docker run -it --rm mynoridc_matter 
#```
# 進入docker後
#```bash
#cd Nordic_SDK/v2.4.0 && \
#west update
#```
#更新期間會要求輸入git homekit的帳號密碼，直接Enter兩次。最後更新完成時會顯示
#```bash
#ERROR: update failed for project homekit
#```
# === 預設進入 zsh 開發環境 ===
CMD ["zsh"]
