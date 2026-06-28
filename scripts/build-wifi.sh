#!/usr/bin/env bash
set -e

# Define a versão do kernel atual
KVER=$(ls /usr/lib/modules | head -n 1)

echo "Baixando e compilando driver AIC8800..."

# Cria uma pasta temporária para o clone
mkdir -p /tmp/aic_build
cd /tmp/aic_build

# Baixa o repositório diretamente do GitHub
git clone https://github.com/shenmintao/aic8800d80 .

# Entra na pasta do driver
cd drivers/aic8800

# Compila o módulo
make ARCH=x86_64

# Cria as pastas de destino no sistema de arquivos da imagem
mkdir -p /usr/lib/modules/$KVER/extra/aic8800
mkdir -p /usr/lib/firmware/aic8800D80

# Copia os módulos compilados
cp aic8800_fdrv/aic8800_fdrv.ko /usr/lib/modules/$KVER/extra/aic8800/
cp aic_load_fw/aic_load_fw.ko /usr/lib/modules/$KVER/extra/aic8800/

# Copia os firmwares (ajustado para copiar da estrutura do repo baixado)
cp ../../fw/aic8800D80/* /usr/lib/firmware/aic8800D80/

# Registra os módulos e configura o carregamento automático
depmod -a -b /usr $KVER
echo "aic8800_fdrv" > /usr/lib/modules-load.d/aic8800.conf

# Limpeza
rm -rf /tmp/aic_build

echo "Driver compilado, instalado e registrado com sucesso."