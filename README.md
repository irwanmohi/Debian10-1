# Debian10
CYBERTIZE SETUP MANAGER [VPS]

Cara guna:
1. Log masuk ke VPS anda.
2. Masukkan perintah: wget "https://github.com/cybertize-dev/Debian-10/archive/refs/heads/main.zip"
3. Pasang pakej unzip dengan cara: apt-get -y install unzip
4. Masukkan perintah: unzip main.zip
5. Masuk ke dalam folder yang kamu baru saja unzip. (Sekiranya anda tidak pasti nama folder anda boleh periksa fail & folder dengan cara masukkan perintah: ls) Untuk masuk ke dalam folder masukkan perintah: cd <folder> CTH: cd Debian-10
6. Masukkan perintah: chmod +x install
7. Masukkan perintah: bash install atau ./install

Untuk senaraikan menu script sila masukkan perintah: bash install help atau ./install help

Contoh penggunaan:
  Disini saya akan dan ingin install package dropbear. Untuk install package dropbear, dengan itu saya akan masukkan perintah: bash install dropbear atau ./install dropbear
  Begitu juga dengan scripts lain yang tersenarai dalam installation menu. 


Senarai pakej dan ports:
  openssh [-p 22]
  dropbear [-p 8695] [-p 5968]
  openvpn [-p 6545] [-p 5456]
  squid [-p 4613] [-p 3164]
  badvpn [-p 7300]
  shadowsocks [-p 6242] [-p 2426]
  wireguard [-p 3576] [-p 6753]
  webmin [-p 10000]
