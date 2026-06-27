#!/bin/bash
set -ou exitecho

echo "Construindo driver aic8800d80..."

# 1. Identifica a versão exata do kernel presente na imagem OCI do Bazzite
KVER=$(ls /usr/lib/modules | head -n 1)

# 2. Instala os pacotes de desenvolvimento necessários
rpm-ostree install kernel-devel kernel-headers gcc make git

# 3. Clona e compila o driver do seu link
git clone https://github.com/shenmintao/aic8800d80.git /tmp/aic8800
cd /tmp/aic8800/drivers/aic8800
make KERNEL_RELEASE=$KVER KDIR=/usr/lib/modules/$KVER/build

# 4. Copia o módulo compilado (.ko) para a pasta de módulos extras do kernel
mkdir -p /usr/lib/modules/$KVER/extra
cp aic8800_fdrv.ko /usr/lib/modules/$KVER/extra/

# 5. Copia o firmware
cp -r ../../fw/aic8800D80 /usr/lib/firmware/

# 6. Atualiza a árvore de módulos da imagem
depmod -a -b /usr $KVER