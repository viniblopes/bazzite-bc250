#!/bin/bash
set -ou exitecho

echo "Construindo modificações do BC250..."

KVER=$(ls /usr/lib/modules | head -n 1)

# Instala dependências de compilação (caso o script do wifi não tenha rodado antes ou precise de extras)
rpm-ostree install kernel-devel kernel-headers gcc make git dkms

# ==========================================
# 1. Empacotando: bc250-40cu-unlock
# ==========================================
echo "Construindo bc250-40cu-unlock..."
git clone https://github.com/RadeonOpenCompute/bc250-40cu-unlock.git /tmp/bc250-unlock # Ajuste a URL exata do seu fork/repo
cd /tmp/bc250-unlock

# Se for um módulo de kernel:
make KERNEL_RELEASE=$KVER KDIR=/usr/lib/modules/$KVER/build
cp *.ko /usr/lib/modules/$KVER/extra/

# Se incluir regras do udev ou scripts executáveis:
# cp rules.udev /etc/udev/rules.d/
# cp unlock-script.sh /usr/bin/


# ==========================================
# 2. Empacotando: bc250_smu_oc
# ==========================================
echo "Construindo bc250_smu_oc..."
git clone https://github.com/AlgumUsuario/bc250_smu_oc.git /tmp/bc250-smu # Ajuste a URL exata
cd /tmp/bc250-smu

# Compilação típica de binário em C/C++ (ajuste conforme o Makefile do repo)
make

# Move o executável para o diretório de binários da imagem
cp bc250_smu_oc /usr/bin/
chmod +x /usr/bin/bc250_smu_oc

# Se houver um serviço systemd para aplicar o OC no boot:
# cp bc250_smu_oc.service /usr/lib/systemd/system/
# systemctl enable bc250_smu_oc.service

# ==========================================
# Limpeza e atualização de módulos
# ==========================================
depmod -a -b /usr $KVER